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

# Test 1: Verify source files exist
source_files=("dot_gitconfig.tmpl" "dot_zshrc" "dot_gitignore" "setup.sh" "test.sh")
for file in "${source_files[@]}"; do
    run_test "$file exists" "[ -f \"$file\" ]"
done

# Test 2: Verify template syntax
run_test "gitconfig template syntax" "grep -q '{{ .chezmoi' dot_gitconfig.tmpl"

# Test 3: Verify setup script is executable
run_test "setup.sh is executable" "[ -x setup.sh ]"

# Test 4: Verify test script is executable
run_test "test.sh is executable" "[ -x test.sh ]"

# Test 5: Verify gitconfig has no invalid sections
run_test "gitconfig has no invalid sections" "! grep -q '\[INVALID SECTION\]' dot_gitconfig.tmpl"

print_status "All tests completed!" 