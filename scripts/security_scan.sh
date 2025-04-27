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

# Install TruffleHog if not present
if ! command -v trufflehog &> /dev/null; then
    print_status "Installing TruffleHog..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install trufflehog
    else
        # For Linux/CI environments
        curl -L "https://github.com/trufflesecurity/trufflehog/releases/download/v3.63.1/trufflehog_3.63.1_linux_amd64.tar.gz" | tar xz
        sudo mv trufflehog /usr/local/bin/
    fi
fi

# Run TruffleHog scan
print_status "Running TruffleHog security scan..."
if trufflehog git file://. --no-update --fail > /dev/null 2>&1; then
    print_status "No secrets detected by TruffleHog"
else
    print_error "TruffleHog detected potential secrets!"
    trufflehog git file://. --no-update
    exit 1
fi

# Additional security checks can be added here
# For example:
# - gitleaks
# - detect-secrets
# - git-secrets 