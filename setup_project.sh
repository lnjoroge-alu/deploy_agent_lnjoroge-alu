#!/bin/env bash

# Helper functions for error handling 
die()  { echo "Error: $*" >&2; exit 1; }
warn() { echo "Warning: $*" >&2; }
info() { echo "[INFO] $*"; }


# Read user input for project identifier and validate it
read -r -p "Enter project identifier (used in attendance_tracker_{input}): " INPUT 
[[ -n "${INPUT// }" ]] || die "Input cannot be empty."


# Set project directory and archive name based on user input
PROJECT_DIR="attendance_tracker_${INPUT}"
ARCHIVE_NAME="attendance_tracker_${INPUT}_archive.tar.gz"


# Function to check if the directory already exists and exit with message if true
if [[ -e "$PROJECT_DIR" ]]; then
  die "Directory '$PROJECT_DIR' already exists. Remove it or choose a different input."
fi

# Create project structure with necessary directories
info "Creating project structure in: $PROJECT_DIR"

mkdir -p "$PROJECT_DIR/Helpers" "$PROJECT_DIR/reports" \
  || die "Failed to create directories (permissions?)."


# Set up source files
SOURCE_DIR="./source_files"
[[ -d "$SOURCE_DIR" ]] || die "Missing '$SOURCE_DIR' directory. Create it and put the provided files inside."

REQUIRED_SOURCES=(
  "$SOURCE_DIR/attendance_checker.py"
  "$SOURCE_DIR/assets.csv"
  "$SOURCE_DIR/config.json"
  "$SOURCE_DIR/reports.log"
)

for f in "${REQUIRED_SOURCES[@]}"; do
  [[ -f "$f" ]] || die "Missing required source file: $f"
done

info "Source files verified."