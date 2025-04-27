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
    echo -e "${RED}==> Error:${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}==> Warning:${NC} $1"
}

# Function to setup test environment
setup_test_env() {
    print_status "Setting up test environment..."
    
    # Create test helper directory if it doesn't exist
    mkdir -p test/test_helper
    
    # Install bats-support if not present
    if [ ! -d "test/test_helper/bats-support" ]; then
        print_status "Installing bats-support..."
        git clone https://github.com/bats-core/bats-support.git test/test_helper/bats-support
    fi
    
    # Install bats-assert if not present
    if [ ! -d "test/test_helper/bats-assert" ]; then
        print_status "Installing bats-assert..."
        git clone https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert
    fi
}

# Main execution
main() {
    # Setup test environment
    setup_test_env
    
    # Run tests
    print_status "Running tests..."
    bats ./test.sh
}

# Run main function
main "$@" 