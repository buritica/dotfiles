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

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is only for macOS"
    exit 1
fi

print_status "Starting macOS setup..."

# Install Xcode Command Line Tools
print_status "Installing Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
    print_status "This will open a dialog to install Xcode Command Line Tools."
    print_status "Please complete the installation in the dialog that appears."
    print_status "After installation is complete, run this script again."
    xcode-select --install
    exit 0
else
    print_status "Xcode Command Line Tools already installed"
fi

# Install Homebrew
print_status "Installing Homebrew..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    print_status "Homebrew already installed"
fi

# Install 1Password CLI
print_status "Installing 1Password CLI..."
if ! command -v op &>/dev/null; then
    brew install --cask 1password-cli
else
    print_status "1Password CLI already installed"
fi

# Install chezmoi
print_status "Installing chezmoi..."
if ! command -v chezmoi &>/dev/null; then
    brew install chezmoi
else
    print_status "chezmoi already installed"
fi

# Initialize and apply dotfiles
print_status "Setting up dotfiles..."
if [ ! -d "$HOME/.local/share/chezmoi" ]; then
    # Check if we're running from a local repository
    if [ -d "$(dirname "$0")/.git" ]; then
        print_status "Using local repository..."
        chezmoi init --apply "$(dirname "$0")"
    else
        print_status "Using remote repository..."
        chezmoi init --apply "https://github.com/buritica/dotfiles.git"
    fi
else
    print_warning "Dotfiles already initialized. Run 'chezmoi update' to update them."
fi

# Run macOS settings script
print_status "Applying macOS settings..."
if [ -f "$HOME/.macos" ]; then
    chmod +x "$HOME/.macos"
    "$HOME/.macos"
else
    print_warning "macOS settings script not found. Make sure dotfiles are properly installed."
fi

# Install Homebrew packages
print_status "Installing Homebrew packages..."
if [ -f "$HOME/Brewfile" ]; then
    sudo brew bundle install --file="$HOME/Brewfile"
else
    print_warning "Brewfile not found. Make sure dotfiles are properly installed."
fi

print_status "Setup complete! Please restart your terminal to ensure all changes take effect."
print_status "You may need to manually configure some applications and services." 