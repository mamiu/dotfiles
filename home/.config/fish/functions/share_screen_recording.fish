#!/usr/bin/env fish

function share_screen_recording
  # Get the latest .mov file in ~/Screenshots
  set latest_mov (ls -t ~/Screenshots/*.mov | head -n 1)

  # Check if there's a .mov file in the directory
  if test -z "$latest_mov"
    echo "No .mov files found in ~/Screenshots."
    return 1
  end

  # Determine if "--with-audio" flag is provided
  if test (count $argv) -gt 0 -a "$argv[1]" = "--with-audio"
    echo "Compressing video with audio..."
    set audio_args "-filter:a" "atempo=1.25"  # Array for audio filter args
    set audio_suffix "(compressed - with audio)"
  else
    echo "Compressing video without audio..."
    set audio_args "-an"  # Array for no-audio option
    set audio_suffix "(compressed - no audio)"
  end

  # Set the output file name by appending the audio suffix before the file extension
  set output_file (string replace -r '\.mov$' " $audio_suffix.mp4" $latest_mov)

  # Check if the output file already exists
  if test -e "$output_file"
    echo "Compressed file already exists: $output_file"
  else
    # Run ffmpeg command to scale, speed up, and compress the video with conditional audio options
    ffmpeg -i "$latest_mov" -vf "scale='if(gt(iw,1920),1920,iw)':'if(gt(ih,1080),1080,ih)':force_original_aspect_ratio=decrease,setpts=0.8*PTS" $audio_args -crf 23 -preset medium "$output_file"

    # Check if the output file was created successfully
    if not test -e "$output_file"
      echo "Failed to create compressed file."
      return 1
    end
  end

  # Copy the output file path to the clipboard using AppleScript
  echo "Copying file path to clipboard..."
  osascript -e "set the clipboard to POSIX file \"$output_file\""
  echo "File path copied to clipboard: $output_file"
end
