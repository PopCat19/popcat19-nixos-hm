{ pkgs, lib, ... }:

let
  # Backup script that handles configuration.nix backup with rotation
  # This creates a self-contained backup that works even if system_modules/ is missing
  backupScript = pkgs.writeShellScriptBin "backup-config" ''
    #!/bin/bash
    set -euo pipefail
    
    CONFIG_DIR="/etc/nixos"
    CONFIG_FILE="$CONFIG_DIR/configuration.nix"
    BACKUP_PREFIX="$CONFIG_DIR/configuration.nix.bak"
    MAX_BACKUPS=3
    SYSTEM_MODULES_DIR="$CONFIG_DIR/system_modules"
    
    # Function to rotate backups
    rotate_backups() {
      # Remove oldest backup if it exists (bak3)
      if [[ -f "$BACKUP_PREFIX.3" ]]; then
        rm -f "$BACKUP_PREFIX.3"
      fi
      
      # Shift existing backups
      for i in $(seq 2 -1 1); do
        if [[ -f "$BACKUP_PREFIX.$i" ]]; then
          mv "$BACKUP_PREFIX.$i" "$BACKUP_PREFIX.$((i + 1))"
        fi
      done
      
      # Move current backup to bak1 if it exists
      if [[ -f "$BACKUP_PREFIX" ]]; then
        mv "$BACKUP_PREFIX" "$BACKUP_PREFIX.1"
      fi
    }
    
    # Function to create backup with system_modules content inlined
    create_backup() {
      local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
      
      # Start backup file with header
      cat > "$BACKUP_PREFIX" << EOF
    # Configuration backup created on $timestamp
    # This backup includes the original configuration.nix with system_modules content inlined
    # Original system_modules imports are commented out and replaced with inline content
    # This backup is self-contained and will work even if system_modules/ directory is missing
    
    EOF
      
      # Process original configuration.nix
      if [[ -f "$CONFIG_FILE" ]]; then
        echo "# === ORIGINAL CONFIGURATION.NIX ===" >> "$BACKUP_PREFIX"
        
        # Read and process the original file line by line
        local in_imports=false
        local brace_count=0
        
        while IFS= read -r line; do
          # Track if we're inside the imports section
          if [[ "$line" =~ ^[[:space:]]*imports[[:space:]]*=[[:space:]]*\[ ]]; then
            in_imports=true
            echo "$line" >> "$BACKUP_PREFIX"
            continue
          fi
          
          # Check if we're closing the imports section
          if [[ "$in_imports" == true && "$line" =~ ^[[:space:]]*\]\;[[:space:]]*$ ]]; then
            in_imports=false
            echo "$line" >> "$BACKUP_PREFIX"
            continue
          fi
          
          # If we're in imports and it's a system_modules import, comment it out
          if [[ "$in_imports" == true && "$line" =~ ^[[:space:]]*\./system_modules/ ]]; then
            echo "    # $line  # COMMENTED OUT - Content inlined below" >> "$BACKUP_PREFIX"
          else
            echo "$line" >> "$BACKUP_PREFIX"
          fi
        done < "$CONFIG_FILE"
        
        # Remove the closing brace temporarily to add system_modules content
        sed -i '$d' "$BACKUP_PREFIX"
        
        # Add system_modules content inline if directory exists
        if [[ -d "$SYSTEM_MODULES_DIR" ]]; then
          echo "" >> "$BACKUP_PREFIX"
          echo "  # =========================================" >> "$BACKUP_PREFIX"
          echo "  # SYSTEM MODULES CONTENT (INLINED)" >> "$BACKUP_PREFIX"
          echo "  # =========================================" >> "$BACKUP_PREFIX"
          echo "" >> "$BACKUP_PREFIX"
          
          # Process each system module in alphabetical order
          for module_file in "$SYSTEM_MODULES_DIR"/*.nix; do
            if [[ -f "$module_file" && "$(basename "$module_file")" != "backup-config.nix" ]]; then
              local module_name=$(basename "$module_file")
              echo "  # === Content from $module_name ===" >> "$BACKUP_PREFIX"
              
              # Extract the content between the outermost braces, preserving indentation
              local temp_content=$(mktemp)
              sed -n '/^{/,/^}$/p' "$module_file" | sed '1d;$d' > "$temp_content"
              
              # Add the content with proper indentation
              while IFS= read -r content_line; do
                echo "$content_line" >> "$BACKUP_PREFIX"
              done < "$temp_content"
              
              rm -f "$temp_content"
              echo "" >> "$BACKUP_PREFIX"
            fi
          done
        else
          echo "" >> "$BACKUP_PREFIX"
          echo "  # WARNING: system_modules directory not found at backup time" >> "$BACKUP_PREFIX"
          echo "  # Original imports were preserved but may not work without the modules" >> "$BACKUP_PREFIX"
          echo "" >> "$BACKUP_PREFIX"
        fi
        
        # Close the configuration
        echo "}" >> "$BACKUP_PREFIX"
        
        # Make the backup file readable
        chmod 644 "$BACKUP_PREFIX"
        
      else
        echo "Error: $CONFIG_FILE not found" >&2
        return 1
      fi
    }
    
    # Main execution
    echo "Creating configuration backup with system_modules content inlined..."
    
    # Rotate existing backups
    rotate_backups
    
    # Create new backup
    if create_backup; then
      echo "✓ Backup created successfully at $BACKUP_PREFIX"
      echo "✓ Backup rotation: keeping last $MAX_BACKUPS backups"
      
      # List current backups with sizes
      echo ""
      echo "Current backups:"
      for i in $(seq 1 $MAX_BACKUPS); do
        if [[ -f "$BACKUP_PREFIX.$i" ]]; then
          local backup_date=$(stat -c %y "$BACKUP_PREFIX.$i" | cut -d' ' -f1,2 | cut -d'.' -f1)
          local backup_size=$(stat -c %s "$BACKUP_PREFIX.$i")
          echo "  - $BACKUP_PREFIX.$i (created: $backup_date, size: $backup_size bytes)"
        fi
      done
      if [[ -f "$BACKUP_PREFIX" ]]; then
        local backup_date=$(stat -c %y "$BACKUP_PREFIX" | cut -d' ' -f1,2 | cut -d'.' -f1)
        local backup_size=$(stat -c %s "$BACKUP_PREFIX")
        echo "  - $BACKUP_PREFIX (created: $backup_date, size: $backup_size bytes)"
      fi
    else
      echo "✗ Backup creation failed" >&2
      return 1
    fi
  '';

  # Activation script that runs the backup during system activation
  backupActivationScript = ''
    echo "Running configuration backup with system_modules inlining..."
    if ${backupScript}/bin/backup-config; then
      echo "✓ Configuration backup completed successfully"
    else
      echo "⚠ Warning: Configuration backup failed, but continuing with system activation"
    fi
  '';

in
{
  # **CONFIGURATION BACKUP SYSTEM**
  # Automatically backs up configuration.nix with system_modules content inlined
  # Maintains rotation of 3 backup histories for redundancy
  # Creates self-contained backups that work even if system_modules/ is missing
  
  # Add the backup script to system packages for manual use
  environment.systemPackages = [ backupScript ];
  
  # Run backup during system activation (every rebuild)
  system.activationScripts.backup-config = {
    text = backupActivationScript;
    deps = [ "etc" ]; # Run after /etc is set up but before other services
  };
}