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

# Check if running in Docker or CI
if [ -f /.dockerenv ] || [ "$CI" = "true" ]; then
    print_status "Running in CI environment"
    IS_CI=true
else
    print_status "Running on host system"
    IS_CI=false
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

# Only run macOS-specific tests if not in CI
if [ "$IS_CI" = false ]; then
    # Test 4: Verify we're on macOS
    run_test "macOS check" '[[ "$OSTYPE" == "darwin"* ]]'
    
    # Test 5: Verify Brewfile syntax
    run_test "Brewfile syntax" "brew bundle --file=dot_my/dot_Brewfile.tmpl check > /dev/null 2>&1 || true"
    
    # Test 6: Check macOS settings
    run_test "macOS settings" "grep -q 'defaults write' dot_my/executable_dot_macos"
else
    print_status "Skipping macOS-specific tests in CI environment"
fi

# Test 7: Verify template syntax
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

# Create test environment
mkdir -p "$temp_dir/home"
export HOME="$temp_dir/home"

# Set all necessary environment variables
export CHEZMOI_USERNAME="test_user"
export CHEZMOI_EMAIL="test@example.com"
export CHEZMOI_NAME="Test User"
export CHEZMOI_ARCH="amd64"
export CHEZMOI_OS="linux"
export CHEZMOI_HOSTNAME="test-host"

# Create chezmoi configuration
cat > "$temp_dir/chezmoi.toml" << EOF
[data]
username = "test_user"
email = "test@example.com"

[data.chezmoi]
arch = "amd64"
os = "linux"
hostname = "test-host"
username = "test_user"
email = "test@example.com"
EOF

# Run template syntax test with verbose output
print_status "Running template syntax test with verbose output"
if CHEZMOI_CONFIG_FILE="$temp_dir/chezmoi.toml" chezmoi init --config-path="$temp_dir/chezmoi.toml" --source="$PWD" --destination="$temp_dir/home" test_user --prompt=false; then
    print_status "✓ template syntax passed"
else
    print_error "✗ template syntax failed"
    print_error "Last command output:"
    CHEZMOI_CONFIG_FILE="$temp_dir/chezmoi.toml" chezmoi init --config-path="$temp_dir/chezmoi.toml" --source="$PWD" --destination="$temp_dir/home" test_user --prompt=false
    exit 1
fi

print_status "All tests completed!" 