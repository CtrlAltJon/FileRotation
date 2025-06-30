#!/bin/bash

# ############################################################################################################
# Rotate files in a directory, keeping the N most recent files and deleting the rest.
#
# Usage: RotateFile.sh [ARGUMENTS]
#
# Required Arguments:
#   --source <argument>            Specify the path to the source directory.
# Optional Arguments:
#   --keep <argument>              Keep the number of most recent files. Default 4.
#   --pattern <PATTERN>            Filter files by using grep extended regular expressions.
#                                  Default is '.*' (matches all files).
#   --dry-run                      Perform a trial run with no changes made.
#   --silent                       Suppress all output.
#   --help or -h or -?             Display the manual page for the command.
#
# ############################################################################################################

# ----------------------------------------------------------------------- Manual page ------------------------
# ------------------------------------------------------------------------------------------------------------
_BASENAME=$(basename $0)
_MANUAL="Usage: $_BASENAME [ARGUMENTS]

Required Arguments:
  --source <argument>     Specify the path of source directory.

Optional Arguments:
  --keep <argument>       Keep the N most recent files. Default 4.
  --pattern <PATTERN>     Filter files by using grep extended regular expressions.
                          Default is '.*' (matches all files).
  --dry-run               Perform a run with no changes made.
  --silent                Suppress all output.
  --help or -h or -?      Display this help.

Example:
  $_BASENAME \\
    --source /mnt/my-data/ \\
    --pattern \"foo_bar_[[:digit:]]{8}\.zip\" \\
    --keep 2
"

# ----------------------------------------------------------------------- Variables initialization -----------
# ------------------------------------------------------------------------------------------------------------
PATH_SOURCE=""                 # Path to the source directory
KEEP_N_ARG=""                  # Number of files to keep passed as an argument
KEEP_N=4                       # Default number of files to keep
PATTERN=".*"                   # Default pattern to match files (can be overridden by --pattern argument)
DRY_RUN=false                  # If true, perform a dry run without deleting files
HELP=false                     # If true, display the help manual
SILENT=false                   # If true, suppress all output except errors
FILE_LIST=""                   # List of files in the source directory matching the pattern
NUM_FILES=0                    # Total number of files found in the source directory matching the pattern
NUM_FILES_TO_DELETE=0          # Number of files to delete
FILES_TO_DELETE_LIST=""        # List of files to delete, full paths
FILES_TO_KEEP_LIST=""          # List of files to keep, full paths

# ----------------------------------------------------------------------- Arguments parsing ------------------
# ------------------------------------------------------------------------------------------------------------
while [ $# -ne 0 ]; do
  argument="${1}"
  case "${argument}" in
    --source)
      PATH_SOURCE="${2}"
      [[ "${PATH_SOURCE}" != */ ]] && PATH_SOURCE="${PATH_SOURCE}/"   # Ensure the source has a trailing slash
      shift 2
      ;;
    --keep)
      KEEP_N_ARG="${2}"
      shift 2
      ;;
    --pattern)
      PATTERN="${2}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help|-h|\?)
      HELP=true
      shift
      ;;
    --silent)
      SILENT=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# ----------------------------------------------------------------------- Check Help -------------------------
# ------------------------------------------------------------------------------------------------------------
if [[ $HELP == true ]]; then echo "${_MANUAL}"; exit 0; fi

# ----------------------------------------------------------------------- Check arguments --------------------
# ------------------------------------------------------------------------------------------------------------
if [[ "$KEEP_N_ARG" =~ ^-?[0-9]+$ ]]; then                                  # Check if KEEP_N_ARG is a number
  KEEP_N=$KEEP_N_ARG
fi

if [ -z "$PATH_SOURCE" ]; then echo "Source path is required."; exit 1; fi  # Check if source path is provided

if [ ! -d "$PATH_SOURCE" ]; then
  echo "Source path ${PATH_SOURCE} does not exist or is not a directory."   # Check if source path exists
  exit 1
fi

# ----------------------------------------------------------------------- Main -------------------------------
# ------------------------------------------------------------------------------------------------------------
if [ "$SILENT" = false ]; then
  echo ""
  echo "____________________ START ____________________ $(date)"
  echo ""
  echo "SOURCE PATH ....... $PATH_SOURCE"
  echo "SILENT ............ $SILENT"
  echo "DRY RUN ........... $DRY_RUN"
  echo "PATTERN ........... $PATTERN"
  echo "KEEP NUMBER ....... $KEEP_N"
  echo ""
fi

FILE_LIST=$(find "$PATH_SOURCE" -maxdepth 1 -type f -print0 | grep -z -E "$PATTERN" | sort -z | tr '\0' '\n')
#NUM_FILES=$(printf "%s\n" "$FILE_LIST" | wc -l)
NUM_FILES=$(echo "$FILE_LIST" | grep -c .)

if [ "$NUM_FILES" -le 1 ]; then
  [[ "$SILENT" = false ]] && echo "No files found matching the pattern $PATTERN in the source path ${PATH_SOURCE}."
else
  if (( NUM_FILES > KEEP_N )); then
    NUM_FILES_TO_DELETE=$(( NUM_FILES - KEEP_N ))
  else
    NUM_FILES_TO_DELETE=0
  fi
  FILES_TO_DELETE_LIST=$(echo "$FILE_LIST" | head -n "-$KEEP_N")
  FILES_TO_KEEP_LIST=$(echo "$FILE_LIST" | tail -n "$KEEP_N")
 
  if [ "$SILENT" = false ]; then
    echo "Number of files to delete: $NUM_FILES_TO_DELETE"
    echo ""
    echo "List of files to delete:"
    while IFS= read -r file; do
      echo -e "\t$file"
    done <<< "$FILES_TO_DELETE_LIST"
    echo ""
    echo "List of files to keep:"
    while IFS= read -r file; do
      echo -e "\t$file"
    done <<< "$FILES_TO_KEEP_LIST"
    echo ""
  fi

  if [[ -n "$FILES_TO_DELETE_LIST" ]]; then
    while IFS= read -r file; do
      [[ -z "$file" ]] && continue                                          # Skip empty lines
      [[ ! -e "$file" ]] && continue                                        # Skip if file does not exist
      [[ "$SILENT" = false ]] && echo "Deleting file: $file"
      if [ "$DRY_RUN" = false ]; then
        rm -- "$file" 2>/dev/null
      fi
    done <<< "$FILES_TO_DELETE_LIST"
  fi

fi

[[ "$SILENT" = false ]] && { echo ""; echo "_____________________ END _____________________ $(date)"; echo""; }

exit 0
