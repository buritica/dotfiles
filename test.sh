#!/bin/bash

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

# Function to run a test and print result
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

# Test 1: Check source files exist and are not empty
run_test "Check source files" '
    [ -f "dot_gitconfig.tmpl" ] && [ -s "dot_gitconfig.tmpl" ] &&
    [ -f "dot_gitignore" ] && [ -s "dot_gitignore" ] &&
    [ -f "setup.sh" ] && [ -s "setup.sh" ] &&
    [ -f "test.sh" ] && [ -s "test.sh" ] &&
    [ -f ".chezmoi.toml.tmpl" ] && [ -s ".chezmoi.toml.tmpl" ] &&
    [ -f ".chezmoiignore" ] && [ -s ".chezmoiignore" ] &&
    [ -f ".yamllint" ] && [ -s ".yamllint" ] &&
    [ -f "dot_zshrc" ] && [ -s "dot_zshrc" ]
'

# Test 2: Check executable permissions
run_test "Check executable permissions" '
    [ -x "setup.sh" ] && [ -x "test.sh" ] && [ -x "dot_my/executable_dot_macos" ]
'

# Test 3: Check common configuration patterns
run_test "Check common configuration patterns" '
    grep -q "\[user\]" dot_gitconfig.tmpl &&
    grep -q "\[core\]" dot_gitconfig.tmpl &&
    grep -q "^[^#]" .chezmoiignore &&
    grep -q "^rules:" .yamllint
'

# Test 4: Check shell script syntax
run_test "Check shell script syntax" '
    bash -n setup.sh &&
    bash -n test.sh
'

# Test 5: Check macOS specific tests
if [ "$IS_CI" = "true" ]; then
    print_warning "Skipping macOS specific tests in CI environment"
else
    if [[ "$OSTYPE" == "darwin"* ]]; then
        run_test "Check macOS settings" '
            [ -f "dot_my/executable_dot_macos" ] && [ -s "dot_my/executable_dot_macos" ] &&
            [ -x "dot_my/executable_dot_macos" ] &&
            bash -n dot_my/executable_dot_macos
        '
    else
        print_warning "Not running on macOS"
    fi
fi

# Test 6: Check template syntax
run_test "Check template syntax" '
    # Create temporary directory for testing
    tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT
    
    # Create test data in JSON format
    cat > "$tmp_dir/data.json" << EOF
{
    "chezmoi": {
        "arch": "arm64",
        "os": "darwin"
    }
}
EOF
    
    # Function to validate a template file
    validate_template() {
        local template_file="$1"
        # Check for basic template syntax
        if ! grep -q "{{" "$template_file" && ! grep -q "}}" "$template_file"; then
            return 0  # No templates to validate
        fi
        
        # Check for valid control structures
        if grep -q "{{if" "$template_file" || grep -q "{{range" "$template_file"; then
            if ! grep -q "{{end}}" "$template_file"; then
                echo "Missing {{end}} in $template_file"
                return 1
            fi
        fi
        
        return 0
    }
    
    # Validate all template files
    validate_template dot_gitconfig.tmpl &&
    validate_template .chezmoi.toml.tmpl
'

# Test 7: Check Python 3 compatibility
run_test "Check Python 3 compatibility" '
    # Check that shell functions use Python 3, not Python 2
    if grep -q "python -c.*urllib" dot_my/dot_aliases; then
        echo "Found Python 2 urllib in dot_aliases"
        return 1
    fi
    if grep -q "SimpleHTTPServer" dot_my/dot_functions; then
        echo "Found Python 2 SimpleHTTPServer in dot_functions"
        return 1
    fi
    if grep -q "python -mjson.tool" dot_my/dot_functions; then
        echo "Found python without version specification in dot_functions"
        return 1
    fi
    return 0
'

# Test 8: Check for dangerous aliases
run_test "Check for dangerous git operations" '
    # fixit should not exist or should require confirmation
    if grep -q "alias fixit=" dot_my/dot_aliases && ! grep -q "# DANGEROUS" dot_my/dot_aliases; then
        echo "Found dangerous fixit alias without warning"
        return 1
    fi
    return 0
'

# Test 9: Check modern git config
run_test "Check modern git configuration" '
    # Check for deprecated GREP_OPTIONS
    if grep -q "GREP_OPTIONS" dot_my/dot_exports; then
        echo "Found deprecated GREP_OPTIONS in exports"
        return 1
    fi
    # Check for templated GOPATH
    if grep -q "/Users/buritica/go" dot_my/dot_exports; then
        echo "Found hardcoded user path in GOPATH"
        return 1
    fi
    # Check for modern git features (either fetch section or rerere section)
    if ! grep -q "\[fetch\]" dot_gitconfig.tmpl && ! grep -q "\[rerere\]" dot_gitconfig.tmpl; then
        echo "Missing modern git config features"
        return 1
    fi
    return 0
'

# Test 10: Check for deprecated hub usage
run_test "Check for deprecated hub CLI" '
    # hub is deprecated, should use gh instead
    if grep -q "hub alias" dot_my/dot_aliases; then
        echo "Found deprecated hub alias command"
        return 1
    fi
    return 0
'

print_status "All tests completed successfully!" 