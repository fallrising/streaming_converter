#!/bin/bash
# config.sh - Configuration settings for video processing

# Base directories
export BASE_DIR="$HOME/video_conversion"
export UPLOAD_DIR="$BASE_DIR/upload"
export PROCESSED_DIR="$BASE_DIR/processed"
export WWW_DIR="$BASE_DIR/www"
export LOG_DIR="$BASE_DIR/logs"

# Video Quality Settings
# Format: "name:resolution:bitrate"
# Will automatically scale based on input video resolution
export QUALITIES=(
    # Original quality (will match input if higher than 1080p)
    "source:original:4000k"
    # Common qualities
    "720p:1280x720:2500k"
    "480p:854x480:1000k"
    "360p:640x360:800k"
    "240p:426x240:400k"
)

# Video Encoding Settings
export HLS_SEGMENT_TIME=10        # Length of each segment in seconds
export HLS_LIST_SIZE=0           # 0 means keep all segments
export VIDEO_PRESET="fast"       # Encoding preset
export AUDIO_BITRATE="128k"      # Audio bitrate
export AUDIO_CHANNELS=2          # Number of audio channels

# Validation settings - Minimal requirements
export MIN_WIDTH=160             # Very permissive minimum width
export MIN_HEIGHT=90             # Very permissive minimum height
export MIN_DURATION=1            # Minimum video duration in seconds

# Create required directories
mkdir -p "$UPLOAD_DIR" "$PROCESSED_DIR" "$WWW_DIR" "$LOG_DIR"

# Logging function
log() {
    local level="$1"
    local message="$2"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_DIR/conversion.log"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message"
}

export -f log
