#!/usr/bin/env fish

# Show Shortcuts Function
#
# Purpose: Display Hyprland keybindings with descriptions and categories
# Tags: # cat: CategoryName, # desc: Description Text
# Dependencies: string, math, column
#
# Usage:
#   show-shortcuts            - Show all
#   show-shortcuts <cat>      - Filter by category
#   show-shortcuts <search>   - Search descriptions/keys

function show-shortcuts
    set -l config_dir "$NIXOS_CONFIG_DIR"
    set -l keybinds_file "$config_dir/configuration/home/hypr_config/modules/keybinds.nix"
    set -l userprefs_file "$config_dir/configuration/home/hypr_config/userprefs.conf"

    set -l filter ""
    set -l search ""
    if test (count $argv) -gt 0
        set -l input (string lower "$argv[1]")
        set -l valid_cats (get_detected_categories "$keybinds_file" "$userprefs_file")
        if contains "$input" (string lower $valid_cats)
            set filter "$input"
        else
            set search "$argv[1]"
        end
    end

    set -l all_shortcuts
    set -l current_cat "General"
    set -l current_desc ""

    # Helper to parse files
    function parse_config -S
        set -l file $argv[1]
        test -f "$file"; or return

        cat "$file" | while read -l line
            # Detect Section Header as Category (=== Name ===)
            if string match -qr '^\s*#\s*=== (.+) ===\s*$' "$line"
                set current_cat (string replace -r '^\s*#\s*=== (.+) ===\s*$' '$1' "$line")
            # Detect Category Tag (# cat: Name)
            else if string match -qr '^\s*#\s*cat:\s*(.+)' "$line"
                set current_cat (string replace -r '^\s*#\s*cat:\s*' '' "$line")

            # Detect Description Tag
            else if string match -qr '^\s*#\s*desc:\s*(.+)' "$line"
                set current_desc (string replace -r '^\s*#\s*desc:\s*' '' "$line")

            # Match Nix Binding ("mod, key, action")
            else if string match -qr '^\s*"([^"]+)"' "$line"; and test -n "$current_desc"
                set -l raw (string replace -r '^\s*"([^"]+)".*' '$1' "$line")
                set -l parts (string split ',' "$raw")
                if test (count $parts) -ge 2
                    set -l binding (string trim "$parts[1]")", "(string trim "$parts[2]")
                    set -a all_shortcuts (normalize_binding "$binding")"|"$current_desc"|"$current_cat
                end
                set current_desc ""

            # Match Conf Binding (bind = mod, key, action)
            else if string match -qr '^\s*bind[elmn]*\s*=' "$line"; and test -n "$current_desc"
                set -l binding (string replace -r '^\s*bind[elmn]*\s*=\s*([^,]+,\s*[^,]+),.*' '$1' "$line")
                set -a all_shortcuts (normalize_binding "$binding")"|"$current_desc"|"$current_cat
                set current_desc ""
            end
        end
    end

    parse_config "$keybinds_file"
    parse_config "$userprefs_file"

    if test (count $all_shortcuts) -eq 0
        set_color yellow; echo "No shortcuts with # desc: tags found."; set_color normal
        return
    end

    # Apply Filters
    set -l filtered
    for item in $all_shortcuts
        set -l parts (string split '|' "$item")
        if test -n "$search"
            string match -iqr "$search" "$parts[1] $parts[2]"; and set -a filtered "$item"
        else if test -n "$filter"
            test (string lower "$parts[3]") = "$filter"; and set -a filtered "$item"
        else
            set -a filtered "$item"
        end
    end

    # Render Header
    set -l box_width 62
    set -l title " HYPRLAND SHORTCUTS "
    test -n "$filter"; and set title " CATEGORY: "(string upper "$filter")" "
    test -n "$search"; and set title " SEARCH: $search "

    set -l padding (math "($box_width - "(string length "$title")") / 2")
    set -l l_pad (math -s0 "floor($padding)")
    set -l r_pad (math -s0 "$box_width - "(string length "$title")" - $l_pad")

    set_color brgreen
    echo "╔"(string repeat -n $box_width "═")"╗"
    echo "║"(string repeat -n $l_pad " ")$title(string repeat -n $r_pad " ")"║"
    echo "╚"(string repeat -n $box_width "═")"╝"
    set_color normal; echo ""

    # Group by dynamically discovered categories
    set -l found_cats
    for i in $filtered; set -a found_cats (string split '|' "$i")[3]; end
    set found_cats (printf '%s\n' $found_cats | sort -u)

    for cat in $found_cats
        set_color brcyan; echo "[$cat]"; set_color normal
        echo "─────────────────────────────────────────────────────────────────────"
        for item in $filtered
            set -l p (string split '|' "$item")
            if test "$p[3]" = "$cat"
                echo -e "$p[1]\t$p[2]"
            end
        end | column -t -s (printf '\t')
        echo ""
    end

    set_color brblack; echo "Tip: # cat: <name> and # desc: <text> in config files"; set_color normal
end

function normalize_binding
    set -l out (string replace -a '$mainMod' 'SUPER' "$argv[1]")
    string replace -ra '[[:space:]]+' ' ' "$out" | string trim
end

function get_detected_categories
    for file in $argv
        test -f "$file"; and grep -oP '#\s*cat:\s*\K.+|#\s*=== \K.+?(?=\s*===)' "$file"
    end | string replace -r '.+?:' '' | sort -u
end
