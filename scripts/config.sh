#!/bin/bash
# config.sh - Configuration settings for video conversion

# Base directories
export BASE_DIR="$HOME/video_conversion"
export UPLOAD_DIR="$BASE_DIR/upload"
export PROCESSED_DIR="$BASE_DIR/processed"
export WWW_DIR="$BASE_DIR/www"
export LOG_DIR="$BASE_DIR/logs"

# R2 Settings (optional)
export USE_R2="false"  # Set to "true" to enable R2 upload
export R2_BUCKET_NAME="your-bucket-name"
export R2_DOMAIN="your-domain.com"
export R2_BASE_PATH="videos"  # Base path in R2 bucket

# Video settings
export QUALITIES=(
    "1080p:1920x1080:4000k"
    "720p:1280x720:2500k"
    "480p:854x480:1000k"
)

# HLS settings
export HLS_SEGMENT_TIME=10
export HLS_LIST_SIZE=0

# Validation settings
export MIN_WIDTH=640
export MIN_HEIGHT=360
export MIN_DURATION=1

# Cleanup settings
export RETENTION_DAYS=7

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
