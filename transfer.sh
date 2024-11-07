#!/bin/bash

# Initialize variables
DO_PUSH=false
FORCE_PUSH=false
COMMIT_MESSAGE="Initial commit 🚀"  # Default commit message
ORIGIN_REPO=""
TARGET_REPO=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -o|--origin)
      ORIGIN_REPO="$2"
      shift 2
      ;;
    -t|--target)
      TARGET_REPO="$2"
      shift 2
      ;;
    -m)
      COMMIT_MESSAGE="$2"
      shift 2
      ;;
    --do)
      DO_PUSH=true
      shift
      ;;
    --force)
      FORCE_PUSH=true
      shift
      ;;
    *)
      echo "Usage: $0 -o <origin-repo-path> -t <target-repo-url> [-m <commit-message>] [--do] [--force]"
      exit 1
      ;;
  esac
done

# Check if both origin and target are set
if [ -z "$ORIGIN_REPO" ] || [ -z "$TARGET_REPO" ]; then
  echo "Error: Origin and target repositories must be specified with -o and -t options."
  exit 1
fi

# Temporary directory setup
TMP_DIRECTORY="../tmp/tmp-transfer-repo"
echo "Creating temporary directory at $TMP_DIRECTORY..."
mkdir -p "$TMP_DIRECTORY"
echo "Copying files to temporary directory..."
cp -R * "$TMP_DIRECTORY"
cd "$TMP_DIRECTORY" || exit
echo "Current directory:"
pwd
echo "Contents of temporary directory:"
ls

# Git initialization and configuration
echo "Initializing a new Git repository..."
git init
echo "Configuring Git user information..."
git config --global user.email "Christopher.Koch@merckgroup.com" 
git config --global user.name "Christopher Koch" 
echo "Adding files to the repository..."
git add .
echo "Creating initial commit with message: '$COMMIT_MESSAGE'"
git commit -m "$COMMIT_MESSAGE"
echo "Setting branch to 'main'..."
git branch -m main

# Set up remote target
echo "Adding remote target repository: $TARGET_REPO"
git remote add origin "$TARGET_REPO"

# Determine push command based on options
PUSH_COMMAND="git push -u origin main"
if [ "$FORCE_PUSH" = true ]; then
  PUSH_COMMAND="$PUSH_COMMAND --force"
fi

# Decide whether to do a dry run or an actual push
if [ "$DO_PUSH" = true ]; then
  echo "Performing actual push to $TARGET_REPO..."
  eval "$PUSH_COMMAND"
else
  echo "Performing dry run push to $TARGET_REPO..."
  eval "$PUSH_COMMAND --dry-run"
fi

# Cleanup temporary directory
cd - || exit
echo "Cleaning up temporary directory..."
rm -rf "$TMP_DIRECTORY"
echo "Temporary directory cleaned up."
