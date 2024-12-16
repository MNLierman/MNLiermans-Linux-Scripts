#!/bin/sh

# Fix Dir Permissions Script
# Created by Mike Lierman (@MNLierman) and @InviseLabs.
# License: OK to modify & share, please consider contributing improvements, commercial use of @MNLierman's scripts by written agreement only.
#
# This script corrects file and folder permissions in the specified directory, and displays stats.
# It sets directories to 0755, shared object files to 0644, and other files based on their type.
# You can enable logging and verbose mode below; verbose will log every file and folder changed.
#
# Variables:
# - FOLDER: The directory to process.
# - LOGGING_ENABLED: Enable or disable logging (true/false).
# - LOGVERBOSE: Enable or disable verbose logging (true/false).
# - LOGFILE: Path to the log file.

# SUPPORTED VARIABLES
FOLDER=""  # <- Change or pass via cli arg
LOGGING_ENABLED=true
LOGVERBOSE=false
LOGFILE="./permission_changes.log"

# SUPPORTED ARGUMENTS
usage() {
  echo "Usage: $0 -f folder [-l log_file] [-v] [--help|-h|-?|*]"
  echo " -f folder          : The directory to process."
  echo " -l log_file        : Path to the log file (default: ./permission_changes.log)."
  echo " -g                 : Disable logging (default enabled)."
  echo " -v                 : Enable verbose logging."
  echo " --help, -h, -?, *  : Display this help message."
  exit 1
}

# Parse command-line arguments
while getopts "f:l:v-:h?" opt; do
  case "$opt" in
    f) FOLDER=$OPTARG ;;
    l) LOGFILE=$OPTARG ;;
    g) LOGGING_ENABLED=false ;;
    v) LOGVERBOSE=true ;;
    -) case "$OPTARG" in
         help) usage ;;
         *) usage ;;
       esac ;;
    h|\?) usage ;;
    *) usage ;;
  esac
done

# Check if folder is set
if [ -z "$FOLDER" ]; then
  usage
fi

# Initialize counters
dir_count=0
file_count=0

# Logging function
log() {
  if [ "$LOGGING_ENABLED" = true ]; then
    echo "$1" >> "$log_file"
  fi
}

read -r -p "Correct file and folder permissions? [y/N] " chse
case "$chse" in
  [yY][eE][sS]|[yY])
    echo "Processing ..."
    log "Processing started at $(date)"
    
    find -H "$FOLDER" -type d -exec sh -c '
      chmod 0755 "$1"
      dir_count=$((dir_count + 1))
      [ "$verbose_logging" = true ] && echo "Set dir  0755 $1" >> "$log_file"
    ' sh {} \;

    find -H "$FOLDER" -type f \( -iname '*.so.*' -o -iname '*.so' \) -exec sh -c '
      chmod 0644 "$1"
      file_count=$((file_count + 1))
      [ "$verbose_logging" = true ] && echo "Set lib  0644 $1" >> "$log_file"
    ' sh {} \;

    find -H "$FOLDER" -type f ! \( -iname '*.so.*' -o -iname '*.so' -o -iname '*.bak' \) -exec sh -c '
      for value; do
        tstbin=$(readelf -l "$value" 2>/dev/null | grep -Eio "executable|shared")
        if [ -z "$tstbin" ]; then
          tstbat=$(head -c2 "$value" | grep -io "#!")
          if [ -n "$tstbat" ]; then
            perm=$(stat -c "%a" "$value")
            if [ "$perm" != "755" ]; then
              chmod 755 "$value"
              echo "Set script  755 $value"
              [ "$verbose_logging" = true ] && echo "Set script  755 $value" >> "$log_file"
            fi
          else
            perm=$(stat -c "%a" "$value")
            if [ "$perm" != "644" ]; then
              chmod 644 "$value"
              echo "Set regular 644 $value"
              [ "$verbose_logging" = true ] && echo "Set regular 644 $value" >> "$log_file"
            fi
          fi
        else
          perm=$(stat -c "%a" "$value")
          if [ "$perm" != "755" ]; then
            chmod 755 "$value"
            echo "Set binary  755 $value"
            [ "$verbose_logging" = true ] && echo "Set binary  755 $value" >> "$log_file"
          fi
        fi
        file_count=$((file_count + 1))
      done
    ' sh {} +

    log "Processing completed at $(date)"
    log "Total directories processed: $dir_count"
    log "Total files processed: $file_count"
    echo "Processing completed. Check the log file for details."
    ;;
  *)
    echo "Aborted."
    ;;
esac
