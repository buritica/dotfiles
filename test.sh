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

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_status "Running test: $test_name"
    if eval "$test_command"; then
        print_status "✓ $test_name passed"
        return 0
    else
        print_error "✗ $test_name failed"
        return 1
    fi
}

# Test 1: Verify chezmoi installation
run_test "chezmoi" "command -v chezmoi &>/dev/null"

# Test 2: Verify essential commands
essential_commands=("git" "zsh")
for cmd in "${essential_commands[@]}"; do
    run_test "$cmd command" "command -v $cmd &>/dev/null"
done

# Test 3: Verify dotfiles
dotfiles=(".zshrc" ".gitconfig" ".gitignore")
for file in "${dotfiles[@]}"; do
    run_test "$file" "[ -f \"$HOME/$file\" ]"
done

# Test 4: Verify chezmoi data
run_test "chezmoi data" "chezmoi data > /dev/null"

print_status "All tests completed!" 