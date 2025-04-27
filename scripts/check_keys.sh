#!/usr/bin/env bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Directories to exclude from search
EXCLUDE_DIRS=(
    "./.git"
    "./scripts"
    "./test.sh"
    "./.github"
)

# File patterns to check for
KEY_PATTERNS=(
    "*.pem"
    "*.key"
    "id_rsa*"
    "id_ed25519*"
    "id_ecdsa*"
    "*.gpg"
    "*.asc"
)

# Build find command with exclusions
find_cmd="find . -type f"
for dir in "${EXCLUDE_DIRS[@]}"; do
    find_cmd+=" -not -path \"$dir/*\""
done

# Add file patterns
find_cmd+=" \("
for pattern in "${KEY_PATTERNS[@]}"; do
    find_cmd+=" -name \"$pattern\" -o"
done
find_cmd="${find_cmd% -o}\)"

print_status "Checking for private keys..."

# Execute find command and check results
if eval "$find_cmd" | grep -q .; then
    print_error "Private keys found in the repository:"
    eval "$find_cmd"
    exit 1
else
    print_status "No private keys detected."
    exit 0
fi 