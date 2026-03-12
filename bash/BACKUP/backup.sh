#!/bin/bash

USE_DEFAULT=true
BACKUP_SOURCES=("/backup_archive.bz2" "/backup_file.txt" "/backup_folder")
FILES=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f)
            USE_DEFAULT=false
            shift
            while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
                FILES+=("$1")
                shift
            done
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

check_backup_sorce() {
    local backup_sources=("$@")

    for source in "${backup_sources[@]}"; do
        if [[ ! -e "$source" ]]; then
            echo "Backup source/sources not exist: $source" >&2
            return 1
        fi
    done
}

archive_files() {
    local files=("$@")
    local timestamp
    timestamp=$(date +"%d%m%Y_%H%M%S")

    local archive_name
    archive_name="$(pwd)/backup_${timestamp}.tar.gz"

    if check_backup_sorce "${files[@]}"; then
        if tar -czvf "$archive_name" "${files[@]}" 2>/dev/null; then
            echo "$archive_name"
        else
            echo "Error: Failed to create archive." >&2
            return 1
        fi
    else
        echo "Error: Some files do not exist." >&2
        return 1
    fi
}

convert_to_bytes() {
    local value="$1"
    local number
    number=$(echo "$value" | grep -o '^[0-9.]*')
    local unit
    unit=$(echo "$value" | grep -o '[A-Za-z]*$' | tr '[:upper:]' '[:lower:]')

    case "$unit" in
        g|gb|gib) echo "$(echo "$number * 1024 * 1024 * 1024" | bc)" ;;
        m|mb|mib) echo "$(echo "$number * 1024 * 1024" | bc)" ;;
        k|kb|kib) echo "$(echo "$number * 1024" | bc)" ;;
        b|"")     echo "$number" ;;
        *)        echo "Unknown unit: $unit" >&2; return 1 ;;
    esac
}

upload_to_drive() {
    local file="$1"

    local gdrive_free_space
    gdrive_free_space=$(rclone about gdrive: | awk 'NR==3 {print $2 $3}')

    local files_size
    files_size=$(du -h "$file" | awk '{print $1}')

    if (( $(convert_to_bytes "$gdrive_free_space") > $(convert_to_bytes "$files_size") )); then
        rclone copy "$file" gdrive:backup_folder
        echo "Backup done!"
    else
        echo "Error: Files can't be uploaded" >&2
        return 1
    fi
}

if [[ "$USE_DEFAULT" == false ]]; then
    archive_path=$(archive_files "${FILES[@]}")
else
    archive_path=$(archive_files "${BACKUP_SOURCES[@]}")
fi

upload_to_drive "$archive_path"
