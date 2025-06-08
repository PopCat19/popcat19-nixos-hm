# ~/nixos-config/fish_functions/open_smart.fish
function open_smart -d "🗂️ Intelligently open files/dirs with appropriate apps. Use 'open_smart help' for manual."
    if test "$argv[1]" = "help" -o "$argv[1]" = "h" -o "$argv[1]" = "--help" -o "$argv[1]" = "-h"
        _open_smart_help
        return 0
    else if test "$argv[1]" = "manual" -o "$argv[1]" = "man" -o "$argv[1]" = "doc"
        _open_smart_manual
        return 0
    end
    
    if test (count $argv) -eq 0
        echo "❌ Usage: open_smart <path>"
        echo "💡 Use 'open_smart help' for more information"
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
        # Fallback editor
        if command -q micro
            set editor_to_use micro
        else if command -q nano
            set editor_to_use nano
        else
            echo "⚠️ Neither \$VISUAL nor \$EDITOR is set, and 'micro' or 'nano' not found."
            echo "💡 Set your preferred editor: set -Ux EDITOR micro"
            return 1
        end
    end

    # Check if path exists
    if not test -e "$path_to_open"
        echo "❌ Error: Path '$path_to_open' does not exist."
        return 1
    end

    # Handle directories
    if test -d "$path_to_open"
        echo "📁 Opening directory '$path_to_open' with $editor_to_use..."
        $editor_to_use "$path_to_open"
        return $status
    end

    # Handle files
    if test -f "$path_to_open"
        set -l file_type_info (file -b "$path_to_open" 2>/dev/null)

        # Check for text files
        if string match -q -r -- 'text|empty|script|source|xml|json|html|css|javascript|markdown|shell|python|perl|ruby|java|c\+\+|c#|golang' (string lower "$file_type_info")
            echo "📝 Opening text file '$path_to_open' with $editor_to_use..."
            $editor_to_use "$path_to_open"
            return $status
        else
            echo "🗂️ Opening '$path_to_open' with default application..."
            if command -q xdg-open
                xdg-open "$path_to_open" & disown
                return $status
            else
                echo "⚠️ 'xdg-open' command not found. Cannot open non-text file."
                echo "💡 Install xdg-utils package"
                return 1
            end
        end
    else
        echo "❌ Error: '$path_to_open' is not a regular file or directory."
        return 1
    end
end

function _open_smart_help -d "Show help for open_smart"
    echo "🗂️ open_smart - Intelligent File/Directory Opener"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "🎯 DESCRIPTION:"
    echo "   Intelligently opens files and directories with appropriate applications."
    echo "   Text files → Editor, Binary files → Default app, Directories → Editor"
    echo ""
    echo "⚙️  USAGE:"
    echo "   open_smart <path>"
    echo "   open_smart help|manual"
    echo ""
    echo "🧠 INTELLIGENCE:"
    echo "   📁 Directories    → Opens with \$VISUAL/\$EDITOR"
    echo "   📝 Text files     → Opens with \$VISUAL/\$EDITOR"
    echo "   🗂️ Binary files   → Opens with xdg-open (default app)"
    echo ""
    echo "💡 EXAMPLES:"
    echo "   open_smart ~/Documents           # Open directory in editor"
    echo "   open_smart config.txt           # Open text file in editor"
    echo "   open_smart image.png            # Open image in default viewer"
    echo ""
    echo "🎮 ABBREVIATION:"
    echo "   o = open_smart    # Your configured abbreviation"
end

function _open_smart_manual -d "Show detailed manual for open_smart"
    echo "📖 open_smart - Complete Manual"
    echo "════════════════════════════════════════════════════════════════════════════════"
    echo ""
    echo "🔍 OVERVIEW:"
    echo "   A smart file opener that determines the best application for each file type."
    echo "   Eliminates the need to remember different commands for different file types."
    echo ""
    echo "🧠 DECISION LOGIC:"
    echo ""
    echo "   1️⃣ EDITOR DETECTION:"
    echo "      Priority: \$VISUAL > \$EDITOR > micro > nano"
    echo "      Used for: Text files and directories"
    echo ""
    echo "   2️⃣ FILE TYPE DETECTION:"
    echo "      Method: Uses 'file -b' command for MIME type detection"
    echo "      Categories:"
    echo "        • Text: text, script, source, empty, json, xml, html, css"
    echo "        • Code: javascript, markdown, shell, python, perl, ruby"
    echo "        • Compiled: java, c++, c#, golang"
    echo "        • Binary: Everything else"
    echo ""
    echo "   3️⃣ APPLICATION SELECTION:"
    echo "      📁 Directories: Always use editor (for project browsing)"
    echo "      📝 Text files: Use editor for editing"
    echo "      🗂️ Binary files: Use xdg-open for system default"
    echo ""
    echo "⚙️  ENVIRONMENT REQUIREMENTS:"
    echo "   Required:"
    echo "   • file command (for type detection)"
    echo "   • xdg-open (for binary files)"
    echo ""
    echo "   Recommended:"
    echo "   • Set \$EDITOR or \$VISUAL environment variables"
    echo "   • Configure default applications via xdg-mime"
    echo ""
    echo "🎯 USE CASES:"
    echo ""
    echo "   💻 Development:"
    echo "     open_smart ~/projects/myapp    # Browse project in editor"
    echo "     open_smart README.md          # Edit documentation"
    echo "     open_smart src/main.py        # Edit source code"
    echo ""
    echo "   📄 Documents:"
    echo "     open_smart document.pdf       # View in PDF reader"
    echo "     open_smart notes.txt          # Edit in text editor"
    echo "     open_smart config.yaml       # Edit configuration"
    echo ""
    echo "   🎨 Media:"
    echo "     open_smart photo.jpg          # View in image viewer"
    echo "     open_smart music.mp3          # Play in music player"
    echo "     open_smart video.mp4          # Play in video player"
    echo ""
    echo "🔧 CUSTOMIZATION:"
    echo "   • Set preferred editor: set -Ux EDITOR micro"
    echo "   • Set visual editor: set -Ux VISUAL code"
    echo "   • Configure default apps: xdg-mime default app.desktop mime/type"
    echo ""
    echo "🆘 TROUBLESHOOTING:"
    echo "   ❌ \"Editor not found\": Set \$EDITOR or install micro/nano"
    echo "   ❌ \"xdg-open not found\": Install xdg-utils package"
    echo "   ❌ Wrong app opens: Check xdg-mime query default mime/type"
end
