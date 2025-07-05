#!/bin/sh
set -e

# Usage: ./iconfinder.sh <desktop_file>
# Finds the best icon from a .desktop file based on the same logic as desktop2app

desktop_file="$1"

if [ ! -f "$desktop_file" ]; then
    echo "Usage: $0 /path/to/file.desktop"
    echo "Example: $0 /usr/share/applications/firefox.desktop"
    exit 1
fi

# Extract Icon from .desktop file
icon_name=$(grep -E '^Icon=' "$desktop_file" | head -n1 | cut -d'=' -f2-)

if [ -z "$icon_name" ]; then
    echo "Error: No Icon field found in $desktop_file" >&2
    exit 1
fi

echo "Searching for icon: $icon_name" >&2

icon_file=""

# Check if icon_name is an absolute path and file exists
if [ -f "$icon_name" ]; then
    echo "Icon specified as absolute path and found: $icon_name" >&2
    icon_file="$icon_name"
else
    echo "Icon specified is not an absolute path or not found, searching in theme folders..." >&2
    preferred_sizes="96x96 64x64 48x48"
    icon_dirs="/usr/local/share/icons /usr/share/icons"
    echo "Searching for icon in these directories:" >&2
    for dir in $icon_dirs; do
        echo "   $dir" >&2
    done
    for dir in $icon_dirs; do
        [ -d "$dir" ] || continue
        for size in $preferred_sizes; do
            echo "Searching in $dir for size $size for icon: ${icon_name}" >&2
            found=$(find "$dir" -type f \( -name "${icon_name}" -o -name "${icon_name}.png" \) 2>/dev/null | grep "/${size}/" | head -n1)
            if [ -n "$found" ]; then
                echo "Found candidate icon: $found" >&2
                icon_file="$found"
                break 2
            fi
        done
    done

    # Fallback to pixmaps
    if [ -z "$icon_file" ]; then
        echo "No icon found in theme folders, falling back to pixmaps..." >&2
        pixmap_dirs="/usr/local/share/pixmaps /usr/share/pixmaps"
        for dir in $pixmap_dirs; do
            echo "Searching in $dir for ${icon_name}.png" >&2
            if [ -f "${dir}/${icon_name}.png" ]; then
                echo "Found pixmap icon: ${dir}/${icon_name}.png" >&2
                icon_file="${dir}/${icon_name}.png"
                break
            fi
        done
    fi

    # Fallback to scalable SVG
    if [ -z "$icon_file" ]; then
        echo "No PNG or pixmap icon found, searching for SVG fallback in /usr/local/share/icons/hicolor/scalable..." >&2
        scalable_dir="/usr/local/share/icons/hicolor/scalable"
        if [ -d "$scalable_dir" ]; then
            found_svg=$(find "$scalable_dir" -type f \( -name "${icon_name}.svg" -o -name "${icon_name}" \) 2>/dev/null | head -n1)
            if [ -n "$found_svg" ]; then
                echo "Found SVG icon: $found_svg" >&2
                icon_file="$found_svg"
            fi
        fi
    fi
fi

# Output result
if [ -n "$icon_file" ]; then
    echo "$icon_file"
    exit 0
else
    echo "Icon not found: $icon_name" >&2
    exit 1
fi
