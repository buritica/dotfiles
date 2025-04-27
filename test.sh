#!/usr/bin/env bats

# Load helper functions
load 'test/test_helper/bats-support/load'
load 'test/test_helper/bats-assert/load'

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

setup() {
    # Check if running in Docker or CI
    if [ -f /.dockerenv ] || [ "$CI" = "true" ]; then
        print_status "Running in CI environment"
        IS_CI=true
    else
        print_status "Running on host system"
        IS_CI=false
    fi
}

@test "Check source files exist and are not empty" {
    # Check for required source files
    assert [ -f "dot_gitconfig.tmpl" ]
    assert [ -s "dot_gitconfig.tmpl" ]
    assert [ -f "dot_gitignore" ]
    assert [ -s "dot_gitignore" ]
    assert [ -f "setup.sh" ]
    assert [ -s "setup.sh" ]
    assert [ -f "test.sh" ]
    assert [ -s "test.sh" ]
    assert [ -f ".chezmoi.toml.tmpl" ]
    assert [ -s ".chezmoi.toml.tmpl" ]
    assert [ -f ".chezmoiignore" ]
    assert [ -s ".chezmoiignore" ]
    assert [ -f ".yamllint" ]
    assert [ -s ".yamllint" ]
    
    # Check dot_my files
    assert [ -f "dot_my/dot_Brewfile.tmpl" ]
    assert [ -s "dot_my/dot_Brewfile.tmpl" ]
    assert [ -f "dot_my/executable_dot_macos" ]
    assert [ -s "dot_my/executable_dot_macos" ]
    assert [ -f "dot_my/dot_aliases" ]
    assert [ -s "dot_my/dot_aliases" ]
    assert [ -f "dot_my/dot_exports" ]
    assert [ -s "dot_my/dot_exports" ]
    assert [ -f "dot_my/dot_functions" ]
    assert [ -s "dot_my/dot_functions" ]
}

@test "Check executable permissions" {
    # Check executable permissions
    assert [ -x "setup.sh" ]
    assert [ -x "test.sh" ]
    assert [ -x "dot_my/executable_dot_macos" ]
}

@test "Check common configuration patterns" {
    # Check git configuration
    assert grep -q "\[user\]" dot_gitconfig.tmpl
    assert grep -q "\[core\]" dot_gitconfig.tmpl
    
    # Check shell configurations
    assert grep -q "export " dot_my/dot_exports
    assert grep -q "alias " dot_my/dot_aliases
    assert grep -q "function " dot_my/dot_functions
    
    # Check ignore patterns
    assert grep -q "^[^#]" .chezmoiignore
    
    # Check YAML configuration
    assert grep -q "^rules:" .yamllint
}

@test "Check shell script syntax" {
    # Check shell script syntax
    run bash -n setup.sh
    assert_success
    
    # Skip test.sh as it's a BATS file
    run bash -n dot_my/executable_dot_macos
    assert_success
    run bash -n dot_my/dot_functions
    assert_success
    run bash -n dot_my/dot_aliases
    assert_success
    run bash -n dot_my/dot_exports
    assert_success
}

@test "Check macOS specific tests" {
    if [ "$IS_CI" = "true" ]; then
        skip "Skipping macOS specific tests in CI environment"
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Check macOS settings
        assert grep -q "defaults write" dot_my/executable_dot_macos
        assert grep -q "killall" dot_my/executable_dot_macos
        
        # Check Brewfile syntax and list missing dependencies
        run brew bundle --file=dot_my/dot_Brewfile.tmpl check --verbose
        if [ "$status" -ne 0 ]; then
            echo "Note: Some Brewfile dependencies are not installed"
            echo "$output"
        fi
        # Don't fail the test if dependencies are missing
        true
    else
        skip "Not running on macOS"
    fi
}

@test "Check Brewfile syntax" {
    if [ "$IS_CI" = "true" ]; then
        skip "Skipping Brewfile check in CI environment"
    fi
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # First check if the file is valid Ruby syntax (Brewfiles are Ruby)
        run ruby -c dot_my/dot_Brewfile.tmpl
        assert_success
        
        # Then check if brew bundle can parse it (but don't care about missing deps)
        run brew bundle --file=dot_my/dot_Brewfile.tmpl check
        if [ "$status" -ne 0 ]; then
            # Only warn about missing dependencies, don't fail the test
            echo "Note: Some Brewfile dependencies are not installed"
        fi
    else
        skip "Not running on macOS"
    fi
}

@test "Check template syntax" {
    # Create temporary directory for testing
    tmp_dir=$(mktemp -d)
    trap 'rm -rf "$tmp_dir"' EXIT
    
    # Create test data in JSON format
    cat > "$tmp_dir/data.json" << EOF
{
    "email": "test@example.com",
    "name": "Test User",
    "github_user": "testuser"
}
EOF
    
    # Function to validate a template file
    validate_template() {
        local template_file="$1"
        # Check for basic template syntax
        if ! grep -q '{{' "$template_file" && ! grep -q '}}' "$template_file"; then
            return 0  # No templates to validate
        fi
        
        # Check for common template patterns
        if grep -q '{{\.' "$template_file"; then
            # Check for valid variable references
            if ! grep -q '{{\.(email|name|github_user)' "$template_file"; then
                echo "Invalid variable reference in $template_file"
                return 1
            fi
        fi
        
        # Check for valid control structures
        if grep -q '{{if' "$template_file" || grep -q '{{range' "$template_file"; then
            if ! grep -q '{{end}}' "$template_file"; then
                echo "Missing {{end}} in $template_file"
                return 1
            fi
        fi
        
        return 0
    }
    
    # Validate all template files
    validate_template dot_gitconfig.tmpl
    validate_template .chezmoi.tmpl
    validate_template dot_my/dot_Brewfile.tmpl
} 