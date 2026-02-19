#!/bin/env bash

# Helper functions for error handling 
die()  { echo "Error: $*" >&2; exit 1; }
warn() { echo "Warning: $*" >&2; }
info() { echo "[INFO] $*"; }

# Number checker function to validate input as a number
is_number() {
  [[ "${1:-}" =~ ^[0-9]+([.][0-9]+)?$ ]]
}


# Read user input for project identifier and validate it
read -r -p "Enter project identifier (used in attendance_tracker_{input}): " INPUT 
[[ -n "${INPUT// }" ]] || die "Input cannot be empty."


# Set project directory and archive name based on user input
PROJECT_DIR="attendance_tracker_${INPUT}"
ARCHIVE_NAME="attendance_tracker_${INPUT}_archive.tar.gz"


# signal interrupt handler to clean up and archive
cleanup_on_interrupt() {
  echo
  warn "SIGINT detected (Ctrl+C). Archiving current state and cleaning up..."

  if [[ -d "$PROJECT_DIR" ]]; then
    tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR" 2>/dev/null || warn "Failed to create archive."
    rm -rf "$PROJECT_DIR" || warn "Failed to remove incomplete directory."
    info "Archive created: $ARCHIVE_NAME"
    info "Incomplete directory removed: $PROJECT_DIR"
  else
    warn "Nothing to archive (project directory not found)."
  fi

  exit 130
}

trap cleanup_on_interrupt INT

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


cp "$SOURCE_DIR/attendance_checker.py" "$PROJECT_DIR/"       || die "Failed to copy attendance_checker.py"
cp "$SOURCE_DIR/assets.csv"          "$PROJECT_DIR/Helpers/" || die "Failed to copy assets.csv"
cp "$SOURCE_DIR/config.json"         "$PROJECT_DIR/Helpers/" || die "Failed to copy config.json"
cp "$SOURCE_DIR/reports.log"         "$PROJECT_DIR/reports/" || die "Failed to copy reports.log"


info "Files deployed successfully."


# prompt user to update attendance thresholds and validate input
echo
read -r -p "Do you want to update attendance thresholds? (y/n): " UPDATE
UPDATE="${UPDATE,,}"

if [[ "$UPDATE" == "y" || "$UPDATE" == "yes" ]]; then
  echo "Press Enter to keep defaults."

  read -r -p "New Warning threshold (default 75): " NEW_WARN
  read -r -p "New Failure threshold (default 50): " NEW_FAIL

  NEW_WARN="${NEW_WARN:-75}"
  NEW_FAIL="${NEW_FAIL:-50}"

  is_number "$NEW_WARN" || die "Warning threshold must be numeric."
  is_number "$NEW_FAIL" || die "Failure threshold must be numeric."

  awk -v w="$NEW_WARN" -v f="$NEW_FAIL" 'BEGIN{
    if (w < 0 || w > 100) exit 1;
    if (f < 0 || f > 100) exit 1;
    if (f >= w) exit 2;
    exit 0;
  }'
  # catches awk exit code and exit program with appropriate message if thresholds are invalid
  rc=$?
  if [[ $rc -eq 1 ]]; then die "Thresholds must be between 0 and 100."; fi
  if [[ $rc -eq 2 ]]; then die "Failure threshold should be less than warning threshold."; fi

  CONFIG_FILE="$PROJECT_DIR/Helpers/config.json"

  # Update thresholds.warning and thresholds.failure in-place
  sed -i 's/"warning"[[:space:]]*:[[:space:]]*[0-9]\+/"warning": '"$NEW_WARN"'/' "$CONFIG_FILE"

  sed -i 's/"failure"[[:space:]]*:[[:space:]]*[0-9]\+/"failure": '"$NEW_FAIL"'/' "$CONFIG_FILE"


  info "Updated config.json with warning=$NEW_WARN, failure=$NEW_FAIL"
else
  info "Keeping default thresholds."
fi


# Run heath check, python + file existence
echo
info "Running Health Check..."

if command -v python3 >/dev/null 2>&1; then
  PYV="$(python3 --version 2>&1 || true)"
  info "python3 found: $PYV"
else
  warn "python3 is missing. Install Python 3 to run attendance_checker.py"
fi

REQUIRED_PATHS=(
  "$PROJECT_DIR/attendance_checker.py"
  "$PROJECT_DIR/Helpers/assets.csv"
  "$PROJECT_DIR/Helpers/config.json"
  "$PROJECT_DIR/reports/reports.log"
)

for p in "${REQUIRED_PATHS[@]}"; do
  [[ -e "$p" ]] || die "Health Check failed: missing required path: $p"
done

info "Health Check passed. Project bootstrapped successfully."
info "Next: cd '$PROJECT_DIR' && python3 attendance_checker.py"
