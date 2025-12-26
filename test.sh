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
    [ -f "dot_zshrc.tmpl" ] && [ -s "dot_zshrc.tmpl" ]
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

# Test 11: Check for essential config files
run_test "Check for essential config files" '
    if [ ! -f ".gitattributes" ]; then
        echo "Missing .gitattributes file"
        return 1
    fi
    if [ ! -f ".editorconfig" ]; then
        echo "Missing .editorconfig file"
        return 1
    fi
    return 0
'

# Test 12: Check brew management functions exist
run_test "Check brew management functions" '
    if ! grep -q "brew-diff()" dot_my/dot_functions; then
        echo "Missing brew-diff function"
        return 1
    fi
    if ! grep -q "brew-sync()" dot_my/dot_functions; then
        echo "Missing brew-sync function"
        return 1
    fi
    if ! grep -q "brew-installed-only()" dot_my/dot_functions; then
        echo "Missing brew-installed-only function"
        return 1
    fi
    if ! grep -q "brew-missing()" dot_my/dot_functions; then
        echo "Missing brew-missing function"
        return 1
    fi
    return 0
'

# Test 13: Check modern tools configured
run_test "Check modern tool configuration" '
    if [ -f "dot_ripgreprc" ] && [ -s "dot_ripgreprc" ]; then
        if ! grep -q "hidden" dot_ripgreprc; then
            echo "Missing --hidden in ripgrep config"
            return 1
        fi
    fi

    if ! grep -q "FZF_DEFAULT_COMMAND" dot_zshrc.tmpl; then
        echo "Missing fzf configuration"
        return 1
    fi

    if ! grep -q "zoxide init" dot_zshrc.tmpl; then
        echo "Missing zoxide initialization"
        return 1
    fi

    return 0
'

# Test 14: Check delta configuration
run_test "Check git delta configuration" '
    if ! grep -q "pager = delta" dot_gitconfig.tmpl; then
        echo "Missing delta as git pager"
        return 1
    fi
    if ! grep -q "\[delta\]" dot_gitconfig.tmpl; then
        echo "Missing delta configuration"
        return 1
    fi
    return 0
'

# Test 15: Check modern aliases
run_test "Check modern tool aliases" '
    if ! grep -q "eza" dot_my/dot_aliases && ! grep -q "eza" dot_zshrc.tmpl; then
        echo "Missing eza aliases"
        return 1
    fi

    if ! grep -q "BAT_THEME" dot_zshrc.tmpl; then
        echo "Missing bat configuration"
        return 1
    fi

    return 0
'

# Test 16: Check new productivity functions exist
run_test "Check new productivity functions" '
    # Port management
    if ! grep -q "^port()" dot_my/dot_functions; then
        echo "Missing port() function"
        return 1
    fi
    if ! grep -q "^killport()" dot_my/dot_functions; then
        echo "Missing killport() function"
        return 1
    fi
    if ! grep -q "^ports()" dot_my/dot_functions; then
        echo "Missing ports() function"
        return 1
    fi

    # Environment switcher
    if ! grep -q "^envs()" dot_my/dot_functions; then
        echo "Missing envs() function"
        return 1
    fi
    if ! grep -q "^envswitch()" dot_my/dot_functions; then
        echo "Missing envswitch() function"
        return 1
    fi
    if ! grep -q "^envnew()" dot_my/dot_functions; then
        echo "Missing envnew() function"
        return 1
    fi

    # Clipboard helpers
    if ! grep -q "^clip()" dot_my/dot_functions; then
        echo "Missing clip() function"
        return 1
    fi
    if ! grep -q "^copyfile()" dot_my/dot_functions; then
        echo "Missing copyfile() function"
        return 1
    fi
    if ! grep -q "^copypath()" dot_my/dot_functions; then
        echo "Missing copypath() function"
        return 1
    fi

    return 0
'

# Test 17: Check new git workflow functions exist
run_test "Check new git workflow functions" '
    # Worktree helpers
    if ! grep -q "^gwt()" dot_my/dot_functions; then
        echo "Missing gwt() function"
        return 1
    fi
    if ! grep -q "^gwta()" dot_my/dot_functions; then
        echo "Missing gwta() function"
        return 1
    fi
    if ! grep -q "^gwtr()" dot_my/dot_functions; then
        echo "Missing gwtr() function"
        return 1
    fi
    if ! grep -q "^gwts()" dot_my/dot_functions; then
        echo "Missing gwts() function"
        return 1
    fi

    # Stash browser
    if ! grep -q "^fstash()" dot_my/dot_functions; then
        echo "Missing fstash() function"
        return 1
    fi
    if ! grep -q "^fstash-show()" dot_my/dot_functions; then
        echo "Missing fstash-show() function"
        return 1
    fi

    # Branch cleanup
    if ! grep -q "^git-cleanup()" dot_my/dot_functions; then
        echo "Missing git-cleanup() function"
        return 1
    fi
    if ! grep -q "^git-prune-local()" dot_my/dot_functions; then
        echo "Missing git-prune-local() function"
        return 1
    fi

    # Conventional commits
    if ! grep -q "^gcommit()" dot_my/dot_functions; then
        echo "Missing gcommit() function"
        return 1
    fi

    return 0
'

# Test 18: Check error handling in new functions
run_test "Check error handling in new functions" '
    # Port functions should check for arguments
    if ! grep -q "Usage: port" dot_my/dot_functions; then
        echo "port() missing usage message"
        return 1
    fi
    if ! grep -q "Usage: killport" dot_my/dot_functions; then
        echo "killport() missing usage message"
        return 1
    fi

    # Environment switcher should check for arguments
    if ! grep -q "Usage: envswitch" dot_my/dot_functions; then
        echo "envswitch() missing usage message"
        return 1
    fi
    if ! grep -q "Usage: envnew" dot_my/dot_functions; then
        echo "envnew() missing usage message"
        return 1
    fi

    # Clipboard helpers should check for arguments
    if ! grep -q "Usage: copyfile" dot_my/dot_functions; then
        echo "copyfile() missing usage message"
        return 1
    fi

    # Git functions should check for repo
    if ! grep -q "git rev-parse --git-dir" dot_my/dot_functions; then
        echo "Git functions missing repo validation"
        return 1
    fi

    return 0
'

# Test 19: Check modern tool integration
run_test "Check modern tool integration" '
    # Zoxide integration
    if ! grep -q "^zi()" dot_my/dot_functions; then
        echo "Missing zi() zoxide integration"
        return 1
    fi

    # Hyperfine benchmarking
    if ! grep -q "^bench()" dot_my/dot_functions; then
        echo "Missing bench() function"
        return 1
    fi
    if ! grep -q "^bench-compare()" dot_my/dot_functions; then
        echo "Missing bench-compare() function"
        return 1
    fi

    # Modern tre with eza
    if ! grep -q "function tre()" dot_my/dot_functions && ! grep -q "^tre()" dot_my/dot_functions; then
        echo "Missing tre() function"
        return 1
    fi
    if ! grep -q "eza --tree" dot_my/dot_functions; then
        echo "tre() not using eza"
        return 1
    fi

    # Modern aliases
    if ! grep -q "alias df=\"duf\"" dot_my/dot_aliases; then
        echo "Missing df=duf alias"
        return 1
    fi
    if ! grep -q "alias du=\"dust\"" dot_my/dot_aliases; then
        echo "Missing du=dust alias"
        return 1
    fi
    if ! grep -q "alias help=\"tldr\"" dot_my/dot_aliases; then
        echo "Missing help=tldr alias"
        return 1
    fi

    return 0
'

# Test 20: Check bug fixes applied
run_test "Check critical bug fixes" '
    # Man pages should use bat, not undefined variable
    if ! grep -q "MANPAGER" dot_my/dot_exports; then
        echo "Missing MANPAGER fix"
        return 1
    fi
    if grep -q "\${yellow}" dot_my/dot_exports; then
        echo "Still has undefined \${yellow} variable"
        return 1
    fi

    # SSH_AUTH_SOCK should be properly quoted
    if grep -q "SSH_AUTH_SOCK=\$HOME/Library" dot_my/dot_exports; then
        echo "SSH_AUTH_SOCK not properly quoted"
        return 1
    fi

    # Git functions should check for repo
    if ! grep -q "git rev-parse --git-dir" dot_my/dot_functions || \
       ! grep -q "&>/dev/null" dot_my/dot_functions; then
        echo "Git functions missing proper repo checks"
        return 1
    fi

    # gifify() should quote variables
    if ! grep -A 10 "gifify()" dot_my/dot_functions | grep -q "ffmpeg -i \"\$1\""; then
        echo "gifify() missing quoted \$1"
        return 1
    fi

    # fs() should use dust with quoted variables
    if ! grep -A 5 "function fs()" dot_my/dot_functions | grep -q "dust.*\"\$@\""; then
        echo "fs() missing dust or quoted variables"
        return 1
    fi

    # diff() should use delta when available
    if ! grep -A 5 "function diff()" dot_my/dot_functions | grep -q "delta"; then
        echo "diff() missing delta integration"
        return 1
    fi

    return 0
'

# Test 21: Check deprecated tools removed
run_test "Check deprecated tools removed" '
    # hub should be removed
    if grep -q "\[hub\]" dot_gitconfig.tmpl; then
        echo "hub section still present"
        return 1
    fi

    # ghi should be removed
    if grep -q "\[ghi\]" dot_gitconfig.tmpl; then
        echo "ghi section still present"
        return 1
    fi

    # bash completion should be removed
    if grep -q "bash-completion" dot_zshrc.tmpl; then
        echo "bash-completion still present"
        return 1
    fi

    # Duplicate aliases should be removed
    if grep -q "^alias refresh=" dot_my/dot_aliases; then
        echo "refresh alias still present (should be removed)"
        return 1
    fi
    if grep -q "^alias glog=" dot_my/dot_aliases; then
        echo "glog alias still present (should be removed)"
        return 1
    fi

    # Compinit configuration - let Oh My Zsh handle it
    if ! grep -q "ZSH_COMPDUMP" dot_zshrc.tmpl; then
        echo "Missing ZSH_COMPDUMP configuration"
        return 1
    fi
    if ! grep -q "ZSH_DISABLE_COMPFIX" dot_zshrc.tmpl; then
        echo "Missing ZSH_DISABLE_COMPFIX optimization"
        return 1
    fi
    # Verify we do not call compinit ourselves (Oh My Zsh handles it)
    if grep -E "^[[:space:]]*compinit" dot_zshrc.tmpl | grep -v "^#" | grep -q "compinit"; then
        echo "Found manual compinit call - should let Oh My Zsh handle it"
        return 1
    fi

    return 0
'

# Test 22: Verify function syntax by sourcing
if [ "$IS_CI" = "false" ]; then
    run_test "Verify functions can be sourced" '
        # Source in a subshell to avoid polluting current environment
        (
            set -e
            source dot_my/dot_functions >/dev/null 2>&1

            # Verify critical functions are defined
            for func in shellhelp port killport envswitch clip copyfile copypath gwt fstash git-cleanup gcommit zi bench tre; do
                type "$func" >/dev/null 2>&1 || {
                    echo "Function $func not found after sourcing"
                    exit 1
                }
            done
        )
    '
fi

print_status "All tests completed successfully!" 