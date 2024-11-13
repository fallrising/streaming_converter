#!/bin/bash
# convert.sh - Convert videos to HLS format with dimension handling

source "$(dirname "$0")/config.sh"

# Function to ensure even dimensions
ensure_even_dimensions() {
    local width="$1"
    local height="$2"
    
    # Make width even
    width=$((width - width % 2))
    # Make height even
    height=$((height - height % 2))
    
    echo "${width}x${height}"
}

convert_video() {
    local input_file="$1"
    local basename=$(basename "${input_file%.*}")
    local output_dir="$PROCESSED_DIR/$basename"
    
    log "INFO" "Starting conversion for $basename"
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Get input video dimensions
    local input_dims=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$input_file")
    local input_width=$(echo "$input_dims" | cut -d'x' -f1)
    local input_height=$(echo "$input_dims" | cut -d'x' -f2)
    
    log "INFO" "Input dimensions: ${input_dims}"
    
    # Create master playlist
    echo "#EXTM3U" > "$output_dir/master.m3u8"
    echo "#EXT-X-VERSION:3" >> "$output_dir/master.m3u8"
    
    # Convert each quality
    for quality in "${QUALITIES[@]}"; do
        IFS=':' read -r name resolution bitrate <<< "$quality"
        
        # Get target dimensions
        local target_width=$(echo "$resolution" | cut -d'x' -f1)
        local target_height=$(echo "$resolution" | cut -d'x' -f2)
        
        # Calculate scaled dimensions while maintaining aspect ratio
        local scale_dims
        if [ "$input_width" -gt "$input_height" ]; then
            # Landscape video
            local new_height=$((target_width * input_height / input_width))
            scale_dims=$(ensure_even_dimensions "$target_width" "$new_height")
        else
            # Portrait video
            local new_width=$((target_height * input_width / input_height))
            scale_dims=$(ensure_even_dimensions "$new_width" "$target_height")
        fi
        
        local quality_dir="$output_dir/$name"
        mkdir -p "$quality_dir/segments"
        
        log "INFO" "Converting $basename to $name ($scale_dims)"
        
        if ! ffmpeg -y -i "$input_file" \
            -c:v libx264 -preset fast \
            -b:v "$bitrate" \
            -maxrate "$bitrate" \
            -bufsize "$(echo "$bitrate" | sed 's/k$//')k" \
            -vf "scale=$scale_dims:force_original_aspect_ratio=disable" \
            -c:a aac -b:a 128k -ac 2 \
            -force_key_frames "expr:gte(t,n_forced*$HLS_SEGMENT_TIME)" \
            -hls_time "$HLS_SEGMENT_TIME" \
            -hls_list_size "$HLS_LIST_SIZE" \
            -hls_segment_filename "$quality_dir/segments/%03d.ts" \
            -f hls \
            "$quality_dir/playlist.m3u8"; then
            
            log "ERROR" "Failed to convert $basename to $name"
            return 1
        fi
        
        # Add to master playlist
        echo "" >> "$output_dir/master.m3u8"
        echo "#EXT-X-STREAM-INF:BANDWIDTH=$(echo "$bitrate" | sed 's/k/000/'),RESOLUTION=$scale_dims" >> "$output_dir/master.m3u8"
        echo "$name/playlist.m3u8" >> "$output_dir/master.m3u8"
    done
    
    log "INFO" "Conversion completed for $basename"
    return 0
}

# Main execution if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <input_file>"
        exit 1
    fi
    
    if ! "$(dirname "$0")/validate.sh" "$1"; then
        exit 1
    fi
    
    convert_video "$1"
fi
