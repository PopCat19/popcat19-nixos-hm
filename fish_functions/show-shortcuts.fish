#!/usr/bin/env fish

# Show Shortcuts Function
#
# Purpose: Display Hyprland keybindings with descriptions
# Dependencies: grep, sed, awk, string, column
# Related: fish-greeting.fish, keybinds.nix, userprefs.conf

function show-shortcuts
    set -l config_dir "$NIXOS_CONFIG_DIR"
    set -l keybinds_file "$config_dir/configuration/home/hypr_config/modules/keybinds.nix"
    set -l userprefs_file "$config_dir/configuration/home/hypr_config/userprefs.conf"
    set -l filter ""
    set -l search ""

    # Parse arguments
    if test (count $argv) -gt 0
        if string match -qr '^(window|workspace|launch|media|monitor|system)$' "$argv[1]"
            set filter "$argv[1]"
        else
            set search "$argv[1]"
        end
    end

    # Check config directory exists
    if not test -d "$config_dir"
        set_color red; echo "Error: NIXOS_CONFIG_DIR not set"; set_color normal
        return 1
    end

    set -l all_shortcuts

    # Parse keybinds.nix
    if test -f "$keybinds_file"
        set -l lines (cat "$keybinds_file")
        set -l current_desc ""
        for line in $lines
            if string match -qr '^\s*# desc:\s*(.+)' "$line"
                set current_desc (string replace -r '^\s*# desc:\s*' '' "$line")
            else if string match -qr '^\s*"[^"]+"' "$line"; and test -n "$current_desc"
                set -l full_content (string replace -r '^\s*"([^"]+)".*' '$1' "$line")
                set -l parts (string split ',' "$full_content")
                if test (count $parts) -ge 2
                    set -l binding (string trim "$parts[1]")", "(string trim "$parts[2]")
                    set -l cat (get_category "$binding" "$current_desc")
                    set -l normalized_binding (normalize_binding "$binding")
                    set -a all_shortcuts "$normalized_binding|$current_desc|$cat"
                end
                set current_desc ""
            end
        end
    end

    # Parse userprefs.conf
    if test -f "$userprefs_file"
        set -l lines (cat "$userprefs_file")
        set -l current_desc ""
        for line in $lines
            if string match -qr '^\s*# desc:\s*(.+)' "$line"
                set current_desc (string replace -r '^\s*# desc:\s*' '' "$line")
            else if string match -qr '^\s*bind[elmn]*\s*=' "$line"; and test -n "$current_desc"
                # Extract only the MOD and KEY parts (first two comma-separated fields)
                set -l binding (string replace -r '^\s*bind[elmn]*\s*=\s*([^,]+,\s*[^,]+),.*' '$1' "$line")
                # Handle edge case where no comma exists after second arg
                if test "$binding" = "$line"
                     set binding (string replace -r '^\s*bind[elmn]*\s*=\s*([^,]+,\s*[^,]+).*' '$1' "$line")
                end
                set -l cat (get_category "$binding" "$current_desc")
                set -l normalized_binding (normalize_binding "$binding")
                set -a all_shortcuts "$normalized_binding|$current_desc|$cat"
                set current_desc ""
            end
        end
    end

    if test (count $all_shortcuts) -eq 0
        set_color yellow; echo "No shortcuts found"; set_color normal
        return
    end

    # Apply filters
    set -l filtered_shortcuts
    for item in $all_shortcuts
        set -l parts (string split '|' "$item")
        if test -n "$search"
            if string match -iqr "$search" "$parts[1]" "$parts[2]"
                set -a filtered_shortcuts "$item"
            end
        else if test -n "$filter"
            if test (string lower "$parts[3]") = "$filter"
                set -a filtered_shortcuts "$item"
            end
        else
            set -a filtered_shortcuts "$item"
        end
    end

    # Header Box Logic
    set -l box_width 62
    set -l title " HYPRLAND KEYBOARD SHORTCUTS "
    if test -n "$filter"; set title " CATEGORY: "(string upper "$filter")" "; end
    if test -n "$search"; set title " SEARCH: $search "; end

    set -l title_len (string length "$title")
    set -l total_padding (math "$box_width - $title_len")
    set -l left_pad_size (math "floor($total_padding / 2)")
    set -l right_pad_size (math "$total_padding - $left_pad_size")

    set_color brgreen
    echo "╔"(string repeat -n $box_width "═")"╗"
    echo "║"(string repeat -n $left_pad_size " ")$title(string repeat -n $right_pad_size " ")"║"
    echo "╚"(string repeat -n $box_width "═")"╝"
    set_color normal
    echo ""

    # Group and Display
    set -l categories Window Workspace Launch Media Monitor System
    for cat in $categories
        set -l cat_items
        for item in $filtered_shortcuts
            set -l parts (string split '|' "$item")
            if test "$parts[3]" = "$cat"
                set -a cat_items "$parts[1]\t$parts[2]"
            end
        end

        if test (count $cat_items) -gt 0
            set_color brcyan; echo "[$cat]"; set_color normal
            echo "─────────────────────────────────────────────────────────────────────"
            for item in $cat_items
                echo -e "$item"
            end | column -t -s (printf '\t')
            echo ""
        end
    end

    set_color brblack; echo "Tip: show-shortcuts <category> | show-shortcuts <search>"; set_color normal
end

function normalize_binding
    set -l binding "$argv[1]"
    set binding (string replace -a '$mainMod' 'SUPER' "$binding")
    set binding (string replace -a '  ' ' ' "$binding")
    string trim "$binding"
end

function get_category
    set -l binding (string lower "$argv[1]")
    set -l desc (string lower "$argv[2]")

    if string match -qr 'workspace|move to' "$desc"; echo "Workspace"
    else if string match -qr 'close|kill|exit|lock|fullscreen|floating|split|group' "$desc"; echo "Window"
    else if string match -qr 'launch|terminal|browser|editor|file|screenshot|clipboard|picker|launcher|vicinae' "$desc"; echo "Launch"
    else if string match -qr 'volume|mute|audio|play|pause|next|prev|brightness|media|ddcutil|pavucontrol' "$desc"; echo "Media"
    else if string match -qr 'monitor|dpms|hyprshade|shader|wayvnc' "$desc"; echo "Monitor"
    else if string match -qr 'resize|focus|mouse'; echo "Window"
    else; echo "System"; end
end
