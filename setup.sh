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
    echo -e "${GREEN}==>${NC} ${1}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}Error:${NC} ${1}"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}Warning:${NC} ${1}"
}

# (Age encryption was removed — SSH keys live in the 1Password agent and
# known_hosts self-populates. No ~/.chez.txt required.)

# Check if running on macOS or in CI environment
if [[ "${OSTYPE}" != "darwin"* ]] && [[ -z "${CI}" ]]; then
    print_error "This script is only for macOS"
    exit 1
fi

print_status "Starting setup..."

# Skip macOS-specific steps in CI
if [[ -n "${CI}" ]]; then
    print_status "Running in CI environment, skipping macOS-specific steps..."
    
    # Initialize and apply dotfiles
    print_status "Setting up dotfiles..."
    if [ ! -d "${HOME}/.local/share/chezmoi" ]; then
        print_status "Using local repository..."
        chezmoi init --apply --prompt=false "$(dirname "${0}")"
    else
        print_warning "Dotfiles already initialized. Run chezmoi update to update them."
    fi
    exit 0
fi

# Managed Macs don't need this script: github.com/buritica/machines installs
# Homebrew, Rosetta and the 1Password CLI (bootstrap.sh), then chezmoi, packages
# and these dotfiles (provision.yml). This only applies dotfiles on a Mac that
# already has chezmoi, e.g. one machines doesn't manage.
if ! command -v chezmoi &>/dev/null; then
    print_error "chezmoi not found. Provision with github.com/buritica/machines, or 'brew install chezmoi' first."
    exit 1
fi

# Initialize and apply dotfiles (shell, git, macOS config — no packages)
print_status "Setting up dotfiles..."
if [ ! -d "${HOME}/.local/share/chezmoi" ]; then
    # Check if we're running from a local repository
    if [ -d "$(dirname "${0}")/.git" ]; then
        print_status "Using local repository..."
        chezmoi init --apply "$(dirname "${0}")"
    else
        print_status "Using remote repository..."
        chezmoi init --apply "https://github.com/buritica/dotfiles.git"
    fi
else
    print_warning "Dotfiles already initialized. Run chezmoi update to update them."
fi

print_status "Setup complete! Please restart your terminal to ensure all changes take effect."
print_status "You may need to manually configure some applications and services."