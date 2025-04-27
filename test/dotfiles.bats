#!/usr/bin/env bats

setup() {
    # Try Homebrew paths first, then fall back to local paths
    if [ -f "/opt/homebrew/lib/bats-support/load.bash" ]; then
        load '/opt/homebrew/lib/bats-support/load.bash'
        load '/opt/homebrew/lib/bats-assert/load.bash'
    elif [ -f "/usr/local/lib/bats-support/load.bash" ]; then
        load '/usr/local/lib/bats-support/load.bash'
        load '/usr/local/lib/bats-assert/load.bash'
    else
        load 'test_helper/bats-support/load'
        load 'test_helper/bats-assert/load'
    fi
    
    # Create temp directory
    export DOTFILES_TEST_DIR="$(mktemp -d)"
    export HOME="${DOTFILES_TEST_DIR}/home"
    mkdir -p "$HOME"
    
    # Set up test environment
    export CHEZMOI_USERNAME="test_user"
    export CHEZMOI_EMAIL="test@example.com"
    export CHEZMOI_NAME="Test User"
    export CHEZMOI_ARCH="amd64"
    export CHEZMOI_OS="linux"
    export CHEZMOI_HOSTNAME="test-host"
}

teardown() {
    rm -rf "$DOTFILES_TEST_DIR"
}

@test "required files exist" {
    for file in "dot_gitconfig.tmpl" "dot_zshrc" "dot_gitignore" "setup.sh" "test.sh" "dot_my/dot_Brewfile.tmpl" "dot_my/executable_dot_macos"; do
        assert [ -f "$file" ]
        assert [ -s "$file" ]
    done
}

@test "executable files have correct permissions" {
    for file in "setup.sh" "test.sh" "dot_my/executable_dot_macos"; do
        assert [ -x "$file" ]
    done
}

@test "git configuration contains required settings" {
    run grep "defaultBranch" dot_gitconfig.tmpl
    assert_success
}

@test "zsh configuration contains PATH settings" {
    run grep -E "(PATH|path)" dot_zshrc
    assert_success
}

@test "chezmoi template syntax is valid" {
    # Create test environment
    mkdir -p "$HOME"
    cat > "$DOTFILES_TEST_DIR/chezmoi.toml" << EOF
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

    # Test template syntax
    run chezmoi init --config-path="$DOTFILES_TEST_DIR/chezmoi.toml" --source="$BATS_TEST_DIRNAME/.." --destination="$HOME" test_user --prompt=false
    assert_success
}

@test "brewfile syntax is valid" {
    if [[ "$CHEZMOI_OS" == "darwin" ]]; then
        run brew bundle --file=dot_my/dot_Brewfile.tmpl check
        assert_success
    else
        skip "Not running on macOS"
    fi
}

@test "macos settings file contains defaults commands" {
    run grep "defaults write" dot_my/executable_dot_macos
    assert_success
} 