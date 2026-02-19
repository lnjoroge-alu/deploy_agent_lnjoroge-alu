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