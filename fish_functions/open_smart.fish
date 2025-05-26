# ~/nixos-config/fish_functions/open_smart.fish
function open_smart -d " Intelligently open a file or directory"
    if test (count $argv) -eq 0
        echo "Usage: open_smart <path>"
        return 1
    end

    set -l path_to_open $argv[1]
    set -l editor_to_use

    # Determine the editor
    if set -q VISUAL; and test -n "$VISUAL"
        set editor_to_use $VISUAL
    else if set -q EDITOR; and test -n "$EDITOR"
        set editor_to_use $EDITOR
    else
        # Fallback editor if neither VISUAL nor EDITOR is set
        if command -q micro
            set editor_to_use micro
        else if command -q nano
            set editor_to_use nano
        else
            echo "⚠️ Neither \$VISUAL nor \$EDITOR is set, and 'micro' or 'nano' not found."
            echo "Please set your preferred editor variable or install micro/nano."
            return 1
        end
    end

    # Check if path exists
    if not test -e "$path_to_open"
        echo "❌ Error: Path '$path_to_open' does not exist."
        return 1
    end

    # If it's a directory, open with editor
    if test -d "$path_to_open"
        echo " Opening directory '$path_to_open' with $editor_to_use..."
        $editor_to_use "$path_to_open"
        return $status
    end

    # If it's a file, check its type
    if test -f "$path_to_open"
        # Use 'file -b' for a brief description without the filename
        # Check if it's some kind of text or an empty file
        set -l file_type_info (file -b "$path_to_open" 2>/dev/null)

        # Check for common text indicators or if it's empty
        # 'text', 'script', 'source code', 'empty', 'json', 'xml', 'html', 'css', 'javascript' etc.
        # Using a regex for broader matching of "text" or "empty"
        if string match -q -r -- 'text|empty|script|source|xml|json|html|css|javascript|markdown|shell|python|perl|ruby|java|c\+\+|c#|golang' (string lower "$file_type_info")
            echo " Opening text file '$path_to_open' with $editor_to_use..."
            $editor_to_use "$path_to_open"
            return $status
        else
            echo " Attempting to open file '$path_to_open' with default application (xdg-open)..."
            if command -q xdg-open
                xdg-open "$path_to_open" & disown # Open in background and disown
                return $status
            else
                echo "⚠️ 'xdg-open' command not found. Cannot open non-text file."
                return 1
            end
        end
    else
        # Should have been caught by -e, but as a fallback
        echo "❌ Error: '$path_to_open' is not a regular file or directory."
        return 1
    end
end
