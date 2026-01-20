#!/bin/bash

# ==============================================================================
# CONFIGURATION
# ==============================================================================

VIDEO_EXTS=("mov" "mp4" "mkv" "avi" "m4v" "webm" "flv" "wmv")

EXCLUDED_DIRS=(
    "$HOME/Library"
    "$HOME/Music"
    "$HOME/Pictures"
    "$HOME/dev"
)

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

check_deps() {
    for cmd in fzf ffmpeg ffprobe trash bc dirname basename; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: '$cmd' is not installed."
            exit 1
        fi
    done
}

draw_progress_bar() {
  local percent=$1
  if (( percent < 0 )); then percent=0; fi
  if (( percent > 100 )); then percent=100; fi

  local bar_width=50
  local filled=$((percent * bar_width / 100))
  local empty=$((bar_width - filled))
  local bar=$(printf "%${filled}s" "" | tr ' ' '#')$(printf "%${empty}s" "" | tr ' ' '-')
  printf "\rProgress: [%-50s] %d%%" "$bar" "$percent"
}

is_excluded() {
    local dir="$1"
    for excluded in "${EXCLUDED_DIRS[@]}"; do
        if [[ "$dir" == "$excluded" ]]; then return 0; fi
    done
    return 1
}

# ==============================================================================
# COMPRESSION LOGIC
# ==============================================================================

compress_video() {
    local input_file="$1"

    local dir_path
    dir_path=$(dirname "$input_file")
    local filename
    filename=$(basename "$input_file")
    local filename_no_ext="${filename%.*}"

    echo -e "\n------------------------------------------------"
    echo -e "Selected: \033[1;34m$input_file\033[0m"

    # --- 1. Speed Selection ---
    echo -e "\nSelect Speed Option:"
    echo "1) 1.0x (Normal Speed)"
    echo "2) 1.1x"
    echo "3) 1.25x"
    echo "4) 1.5x"
    echo "5) 1.75x"
    read -r -p "Choice [1]: " speed_choice
    speed_choice=${speed_choice:-1}

    local video_filter_speed=""
    local audio_filter_args=()
    local speed_factor=1

    case "$speed_choice" in
        2) video_filter_speed=",setpts=0.9091*PTS"; audio_filter_args=(-filter:a "atempo=1.1");  speed_factor=1.1 ;;
        3) video_filter_speed=",setpts=0.8*PTS";    audio_filter_args=(-filter:a "atempo=1.25"); speed_factor=1.25 ;;
        4) video_filter_speed=",setpts=0.6667*PTS"; audio_filter_args=(-filter:a "atempo=1.5");  speed_factor=1.5 ;;
        5) video_filter_speed=",setpts=0.5714*PTS"; audio_filter_args=(-filter:a "atempo=1.75"); speed_factor=1.75 ;;
        *) video_filter_speed="";                   audio_filter_args=();                          speed_factor=1 ;;
    esac

    # --- 2. Quality Selection ---
    echo -e "\nSelect Quality/Size:"
    echo "1) Small  (High compression)"
    echo "2) Medium (Balanced)"
    echo "3) Large  (High quality)"
    read -r -p "Choice [2]: " quality_choice
    quality_choice=${quality_choice:-2}

    local crf_val
    local preset_val

    case "$quality_choice" in
        1) crf_val="28"; preset_val="fast" ;;
        3) crf_val="18"; preset_val="slow" ;;
        *) crf_val="23"; preset_val="medium" ;;
    esac

    # --- 3. Trash Preference ---
    echo ""
    read -r -p "Move ORIGINAL file to Trash after successful compression? (Y/n): " trash_original
    trash_original=${trash_original:-Y}

    local output_file="${dir_path}/${filename_no_ext} (compressed).mp4"

    if [[ -e "$output_file" ]]; then
        echo -e "\n\033[1;33mWarning: Output file already exists.\033[0m"
        read -r -p "Overwrite? (y/N): " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then return; fi
    fi

    # Get Duration
    local duration
    duration=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "$input_file")
    local duration_micros=$(echo "$duration * 1000000" | bc)

    # Adjust duration for progress bar based on speed
    duration_micros=$(echo "$duration_micros / $speed_factor" | bc)

    echo ""
    echo "Starting compression..."

    # Construct Filter Chain
    local vf_chain="scale='if(gt(iw,1920),1920,iw)':'if(gt(ih,1080),1080,ih)':force_original_aspect_ratio=decrease,scale=trunc(iw/2)*2:trunc(ih/2)*2${video_filter_speed}"

    # --- FILE BASED PROGRESS MONITORING ---
    local progress_log=$(mktemp)
    local error_log=$(mktemp)

    # Run FFMPEG in background
    ffmpeg -y -i "$input_file" \
        -vf "$vf_chain" \
        "${audio_filter_args[@]}" \
        -crf "$crf_val" -preset "$preset_val" \
        -progress "$progress_log" \
        "$output_file" > "$error_log" 2>&1 &

    local ffmpeg_pid=$!

    # Loop while ffmpeg is running to update progress bar
    while kill -0 "$ffmpeg_pid" 2>/dev/null; do
        local out_time_ms=$(grep "out_time_ms=" "$progress_log" | tail -n 1 | cut -d= -f2)

        if [[ -n "$out_time_ms" && "$out_time_ms" != "N/A" ]]; then
            local percent=$(awk -v curr="$out_time_ms" -v total="$duration_micros" 'BEGIN { printf "%.0f", (curr / total) * 100 }')
            draw_progress_bar "$percent"
        fi
        sleep 0.5
    done

    wait "$ffmpeg_pid"
    local ffmpeg_status=$?

    rm "$progress_log"

    if [[ $ffmpeg_status -eq 0 && -e "$output_file" ]]; then
        draw_progress_bar 100
        echo -e "\n\n\033[1;32mCompression Successful!\033[0m"

        local old_size=$(du -h "$input_file" | cut -f1)
        local new_size=$(du -h "$output_file" | cut -f1)
        echo "Original: $old_size -> Compressed: $new_size"

        # --- Trash Logic ---
        echo -e "\n------------------------------------------------"
        if [[ "$trash_original" =~ ^[Yy]$ ]]; then
            trash "$input_file"
            echo "Original file moved to trash."
        else
            echo "Original file kept."
        fi
        rm "$error_log"
    else
        echo -e "\n\n\033[1;31mCompression Failed.\033[0m"
        echo "------------------------------------------------"
        echo "ERROR LOG:"
        tail -n 20 "$error_log"
        echo "------------------------------------------------"
        rm "$error_log"
        if [[ -e "$output_file" ]]; then rm "$output_file"; fi
    fi

    echo -e "\nPress Enter to return..."
    read -r
}

# ==============================================================================
# MAIN NAVIGATION LOOP
# ==============================================================================

check_deps

START_DIR="${1:-$HOME}"
if [[ "$START_DIR" != "$HOME"* ]]; then
    echo "Restricted: Cannot navigate outside of Home directory."
    START_DIR="$HOME"
fi
cd "$START_DIR" || exit 1

while true; do
    find_args=()
    for ext in "${VIDEO_EXTS[@]}"; do
        find_args+=( -o -iname "*.$ext" )
    done
    find_args=("${find_args[@]:1}")

    # Clear screen for fresh look
    clear
    echo "Current Dir: $(pwd)"
    echo "------------------------------------------------"

    list_file=$(mktemp)

    if [[ "$(pwd)" != "$HOME" ]]; then
        echo "  .. (Go Up)" > "$list_file"
    else
        > "$list_file"
    fi

    # 1. Scan Directories
    while IFS= read -r -d '' dir; do
        dirname=$(basename "$dir")

        # Visual Indicator
        printf "\r\033[KScanning folders: %s" "$dirname"

        abs_path="$(pwd)/$dirname"
        if ! is_excluded "$abs_path"; then
            # Get size in KB first for filtering
            # -s: summary, -k: kilobytes
            size_kb=$(du -sk "$dir" 2>/dev/null | cut -f1)
            size_kb=${size_kb:-0} # Handle empty result

            # Filter: Only show if >= 10MB (10240 KB)
            if [[ "$size_kb" -ge 10240 ]]; then
                # Get human readable size for display
                size_human=$(du -sh "$dir" 2>/dev/null | cut -f1)
                echo "$size_human $dirname/" >> "$list_file"
            fi
        fi
    done < <(find . -maxdepth 1 -mindepth 1 -type d -not -name '.*' -not -type l -print0)

    # 2. Scan Files
    printf "\r\033[KScanning files..."

    while IFS= read -r -d '' file; do
        size=$(du -sh "$file" 2>/dev/null | cut -f1)
        clean_name=$(echo "$file" | sed 's|^\./||')
        echo "$size $clean_name" >> "$list_file"
    done < <(find . -maxdepth 1 -type f -not -name '.*' -not -type l \( "${find_args[@]}" \) -print0)

    # Clear the scanning line
    printf "\r\033[K"

    # Sort
    if [[ "$(pwd)" != "$HOME" ]]; then
        header=$(head -n 1 "$list_file")
        tail -n +2 "$list_file" | sort -hr > "${list_file}.tmp"
        echo "$header" > "$list_file"
        cat "${list_file}.tmp" >> "$list_file"
    else
        sort -hr "$list_file" > "${list_file}.tmp"
        mv "${list_file}.tmp" "$list_file"
    fi

    selection=$(cat "$list_file" | fzf \
        --header="Current Dir: $(pwd)" \
        --prompt="Select Video or Folder > " \
        --height=100% --layout=reverse --border \
        --nth=2.. \
        --expect=enter)

    rm "$list_file" "${list_file}.tmp" 2>/dev/null

    key=$(echo "$selection" | head -n 1)
    line=$(echo "$selection" | tail -n 1)

    if [[ -z "$line" ]]; then
        echo "Exiting."
        exit 0
    fi

    if [[ "$line" == *".. (Go Up)"* ]]; then
        cd ..
        continue
    fi

    item_name=$(echo "$line" | cut -d ' ' -f2-)

    if [[ "$item_name" == */ ]]; then
        dir_name="${item_name%/}"
        cd "$dir_name"
    else
        compress_video "$item_name"
    fi
done