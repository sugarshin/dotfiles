#!/bin/bash

# YouTube Channel Audio Downloader
# This script downloads audio from all videos in a YouTube channel,
# excluding live streams and shorts.

set -euo pipefail

# Default values
OUTPUT_DIR="./audio_downloads"
DRY_RUN=false
CHANNEL_URL=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] CHANNEL_URL

Download audio from all videos in a YouTube channel (excluding live streams and shorts).

OPTIONS:
    -o, --output DIR     Output directory (default: ./audio_downloads)
    -d, --dry-run        Show what would be downloaded without actually downloading
    -h, --help          Show this help message

EXAMPLES:
    $0 "https://www.youtube.com/@channel_name"
    $0 -o /path/to/output "https://www.youtube.com/@channel_name"
    $0 --dry-run "https://www.youtube.com/@channel_name"
EOF
}

# Function to check if yt-dlp is installed
check_dependencies() {
    if ! command -v yt-dlp &> /dev/null; then
        print_error "yt-dlp is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed. Please install it first."
        exit 1
    fi
}

# Function to get channel videos
get_channel_videos() {
    local channel_url="$1"
    local temp_file=$(mktemp)
    
    print_info "Fetching videos from channel: $channel_url" >&2
    
    local error_file=$(mktemp)
    yt-dlp --dump-json --flat-playlist --extractor-args "youtube:skip=hls,dash" "$channel_url" > "$temp_file" 2>"$error_file"
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        print_error "Failed to fetch channel videos (exit code: $exit_code)"
        if [[ -s "$error_file" ]]; then
            cat "$error_file" >&2
        fi
        rm -f "$temp_file" "$error_file"
        return 1
    fi
    
    # Check if we have actual content (not just errors)
    if [[ ! -s "$temp_file" ]]; then
        print_error "No video data retrieved"
        rm -f "$temp_file" "$error_file"
        return 1
    fi
    
    rm -f "$error_file"
    
    echo "$temp_file"
}

# Function to filter videos (exclude live streams and shorts)
filter_videos() {
    local temp_file="$1"
    local filtered_file=$(mktemp)
    
    print_info "Filtering videos (excluding live streams and shorts)..." >&2
    
    # Filter out live streams and shorts - use simpler, more permissive logic
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            # Check if it's a live stream
            if echo "$line" | jq -e '.live_status == "is_live" or .is_live == true' >/dev/null 2>&1; then
                continue
            fi
            
            # Check for 'shorts' in URL or webpage_url
            url=$(echo "$line" | jq -r '.url // ""')
            webpage_url=$(echo "$line" | jq -r '.webpage_url // ""')
            if [[ "$url" =~ /shorts/ || "$webpage_url" =~ /shorts/ ]]; then
                continue
            fi
            
            # Check duration (only skip if explicitly under 45 seconds)
            duration=$(echo "$line" | jq -r '.duration // null')
            if [[ "$duration" != "null" && "$duration" != "0" && "$duration" != "" ]]; then
                if (( $(echo "$duration < 45" | bc -l) )); then
                    continue
                fi
            fi
            
            # Check title for obvious shorts/live indicators
            title=$(echo "$line" | jq -r '.title // ""' | tr '[:upper:]' '[:lower:]')
            if [[ "$title" =~ \#shorts || "$title" =~ live || "$title" =~ ライブ ]]; then
                continue
            fi
            
            # Add to filtered list
            echo "$line" >> "$filtered_file"
        fi
    done < "$temp_file"
    
    echo "$filtered_file"
}

# Function to download audio from a single video
download_audio() {
    local video_id="$1"
    local output_dir="$2"
    local video_url="https://www.youtube.com/watch?v=$video_id"
    
    if yt-dlp --extract-audio --audio-format mp3 --audio-quality 0 \
              --output "$output_dir/%(title)s.%(ext)s" \
              --no-playlist "$video_url" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            if [[ -z "$CHANNEL_URL" ]]; then
                CHANNEL_URL="$1"
            else
                print_error "Multiple channel URLs provided"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if channel URL is provided
if [[ -z "$CHANNEL_URL" ]]; then
    print_error "Channel URL is required"
    show_usage
    exit 1
fi

# Check dependencies
check_dependencies

# Create output directory if it doesn't exist
if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Get channel videos
videos_file=$(get_channel_videos "$CHANNEL_URL")
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Check if any videos were found
if [[ ! -s "$videos_file" ]]; then
    print_error "No videos found or error occurred"
    rm -f "$videos_file"
    exit 1
fi

total_videos=$(wc -l < "$videos_file")
print_info "Found $total_videos videos"

# Filter videos
filtered_file=$(filter_videos "$videos_file")
filtered_count=$(wc -l < "$filtered_file")
print_info "After filtering: $filtered_count videos (excluding live streams and shorts)"

# Clean up original file
rm -f "$videos_file"

if [[ "$filtered_count" -eq 0 ]]; then
    print_warning "No videos to download after filtering"
    rm -f "$filtered_file"
    exit 0
fi

# Dry run mode
if [[ "$DRY_RUN" == true ]]; then
    print_info "Dry run mode - Videos that would be downloaded:"
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            title=$(echo "$line" | jq -r '.title // "Unknown title"')
            echo "  - $title"
        fi
    done < "$filtered_file"
    rm -f "$filtered_file"
    exit 0
fi

# Download audio files
successful_downloads=0
failed_downloads=0
current=0

print_info "Starting audio download to: $OUTPUT_DIR"

while IFS= read -r line; do
    if [[ -n "$line" ]]; then
        current=$((current + 1))
        video_id=$(echo "$line" | jq -r '.id')
        title=$(echo "$line" | jq -r '.title // "Unknown title"')
        
        print_info "[$current/$filtered_count] Downloading: $title"
        
        if download_audio "$video_id" "$OUTPUT_DIR"; then
            successful_downloads=$((successful_downloads + 1))
            print_success "Downloaded: $title"
        else
            failed_downloads=$((failed_downloads + 1))
            print_error "Failed to download: $title"
        fi
    fi
done < "$filtered_file"

# Clean up
rm -f "$filtered_file"

# Summary
echo
print_success "Download complete!"
print_info "Successfully downloaded: $successful_downloads"
if [[ "$failed_downloads" -gt 0 ]]; then
    print_warning "Failed downloads: $failed_downloads"
fi
print_info "Output directory: $(realpath "$OUTPUT_DIR")"