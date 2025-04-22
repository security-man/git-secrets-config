#!/bin/bash
# simple-git-secrets-setup.sh
# A simplified script to apply patterns from a file to git-secrets

set -e

# Default patterns file location
PATTERNS_FILE="git-secrets-patterns.txt"

# Use specified file if provided as argument
if [ "$1" != "" ]; then
  PATTERNS_FILE="$1"
fi

# Check if git-secrets is installed
if ! command -v git secrets &> /dev/null && ! command -v git-secrets &> /dev/null; then
  echo "Error: git-secrets is not installed"
  echo "Please install it from https://github.com/awslabs/git-secrets"
  exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  echo "Error: Not in a git repository"
  exit 1
fi

# Check if patterns file exists
if [ ! -f "$PATTERNS_FILE" ]; then
  echo "Error: Patterns file '$PATTERNS_FILE' not found"
  exit 1
fi

echo "Installing git-secrets hooks in current repository..."
git secrets --install

echo "Adding patterns from $PATTERNS_FILE..."
while IFS= read -r line || [ -n "$line" ]; do
  # Skip comments and empty lines
  [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]] && continue
  
  # Handle literal patterns differently
  if [[ "$line" == *"-----BEGIN"* ]]; then
    git secrets --add --literal "$line"
  else
    git secrets --add "$line"
  fi
done < "$PATTERNS_FILE"

echo "Done! Configured patterns:"
git secrets --list
