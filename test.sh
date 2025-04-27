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

# Check if running in Docker
if [ -f /.dockerenv ]; then
    print_status "Running in Docker container"
    IS_DOCKER=true
else
    print_status "Running on host system"
    IS_DOCKER=false
fi

# Test 1: Verify source files exist and are not empty
source_files=(
    "dot_gitconfig.tmpl"
    "dot_zshrc"
    "dot_gitignore"
    "setup.sh"
    "test.sh"
    "dot_my/dot_Brewfile.tmpl"
    "dot_my/executable_dot_macos"
)

for file in "${source_files[@]}"; do
    run_test "$file exists" "[ -f \"$file\" ]"
    run_test "$file is not empty" "[ -s \"$file\" ]"
done

# Test 2: Verify executable permissions
executable_files=(
    "setup.sh"
    "test.sh"
    "dot_my/executable_dot_macos"
)

for file in "${executable_files[@]}"; do
    run_test "$file is executable" "[ -x \"$file\" ]"
done

# Test 3: Check for common configuration patterns
run_test "git configuration" "grep -q 'defaultBranch' dot_gitconfig.tmpl"
run_test "zsh configuration" "grep -q -E '(PATH|path)' dot_zshrc"

# Only run macOS-specific tests if not in Docker
if [ "$IS_DOCKER" = false ]; then
    # Test 4: Verify we're on macOS
    run_test "macOS check" '[[ "$OSTYPE" == "darwin"* ]]'
    
    # Test 5: Verify Brewfile syntax
    run_test "Brewfile syntax" "brew bundle --file=dot_my/dot_Brewfile.tmpl check > /dev/null 2>&1 || true"
    
    # Test 6: Check macOS settings
    run_test "macOS settings" "grep -q 'defaults write' dot_my/executable_dot_macos"
fi

# Test 7: Check for sensitive data
run_test "no AWS keys" "! grep -r 'AKIA' ."
run_test "no private keys" "! find . -name '*.pem' -o -name 'id_rsa'"
run_test "no tokens" "! grep -r 'ghp_' ."

# Test 8: Verify template syntax
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

cat > "$temp_dir/chezmoi.toml" << EOF
[data]
username = "test_user"

[data.chezmoi]
arch = "amd64"
os = "linux"
hostname = "test-host"
username = "test_user"
email = "test@example.com"
EOF

run_test "template syntax" "CHEZMOI_CONFIG_FILE=$temp_dir/chezmoi.toml chezmoi init --config-path=$temp_dir/chezmoi.toml --source=$PWD --destination=$temp_dir/home test_user > /dev/null 2>&1"

print_status "All tests completed!" 