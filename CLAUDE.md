# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository managed with [chezmoi](https://chezmoi.io/), designed to bootstrap and maintain a consistent macOS development environment. The repository uses Age encryption for sensitive files and Homebrew for package management.

## Key Commands

### Testing
```bash
./test.sh                    # Run all tests (validates files, syntax, templates)
```

### Setup and Deployment
```bash
./setup.sh                   # Full setup (macOS only, requires ~/.chez.txt Age key)
chezmoi apply                # Apply dotfile changes
chezmoi update              # Pull and apply latest changes
```

### Development Workflow

**Simplified Dotfiles Commands:**
```bash
# Easy-to-remember helpers (no chezmoi knowledge required)
dsync                       # Pull and apply latest changes (= chezmoi update)
dapply                      # Apply pending changes (= chezmoi apply)
ddiff                       # Show what would change (= chezmoi diff)
dedit ~/.zshrc              # Edit dotfile source (= chezmoi edit)
dadd ~/.myfile              # Track new file (= chezmoi add)
dstatus                     # Check status (= chezmoi status)
dcd                         # Go to dotfiles source directory

# Traditional chezmoi commands (still work)
chezmoi update              # Pull and apply latest changes
chezmoi apply               # Apply dotfile changes
chezmoi add ~/.myfile       # Track a new dotfile
chezmoi edit ~/.myfile      # Edit tracked file in source
```

**Pull Request Creation:**
```bash
gh pr create --title "type: description" --body-file pr_body.md    # Create PR with body file
```

### Brewfile Management
```bash
brew-diff                   # Show diff between Brewfile and installed packages
brew-installed-only         # List packages installed but not in Brewfile
brew-missing                # List packages in Brewfile but not installed
brew-sync                   # Interactively sync Brewfile with installed packages
brew-edit                   # Edit Brewfile source template via chezmoi
brew-export                 # Export current installation to Brewfile
brew-orphans                # Detect orphaned packages (not dependencies)
brew-cleanup                # Clean up Homebrew cache and autoremove
```

**Workflow:**
1. Install new package: `brew install packagename`
2. Check what's different: `brew-diff`
3. Decide if you want to track it in Brewfile
4. If yes: `brew-sync` to add it (or manually edit Brewfile)
5. Commit Brewfile changes

**Philosophy:**
- Core packages shared across all machines (1password, chrome, vscode, etc.)
- Machine-specific packages for home/work/media (see Machine Profiles below)
- Test new tools before adding to Brewfile
- Dependencies are auto-installed, don't track them
- Use `brew-diff` to periodically audit installed vs tracked packages

### Machine Profiles

**Available Profiles:**
```bash
machine-list                # List all configured machine profiles
machine-info                # Show current machine profile information
```

**Configured Machines:**
- **crowntail (home 🏡)**: Personal home workstation
  - Home apps: discord, minecraft, spotify
- **deltatail (work 💼)**: Work laptop
  - Work tools: microsoft-teams, slack
- **halfmoon (media 🎥)**: Video editing station
  - Media apps: obs, streamlabs, adobe-creative-cloud, audio-hijack, loopback, soundsource
  - Media tools: ffmpeg, gifsicle
- **default (🔬)**: Test/unknown machines

The machine profile is automatically detected from hostname and configures:
- Shell prompt emoji (PS1)
- Machine-specific Brewfile packages
- Profile metadata in chezmoi templates

## Architecture

### Chezmoi File Structure
- **Template files** (`.tmpl` extension): Processed by chezmoi's Go templates
  - `dot_gitconfig.tmpl`: Git configuration with user data from `.chezmoi.toml.tmpl`
  - `dot_my/dot_Brewfile.tmpl`: Homebrew package list
  - `.chezmoi.toml.tmpl`: Chezmoi config with Age encryption settings
- **Executable files** (`executable_` prefix): Made executable when applied
  - `dot_my/executable_dot_macos`: macOS system settings script
- **Dotfiles** (`dot_` prefix): Mapped to hidden files in home directory
  - `dot_zshrc.tmpl` → `~/.zshrc` (uses machine profile for PS1)
  - `dot_my/` → `~/.my/` (custom shell scripts and configs)

### Encryption
- Uses Age encryption with identity at `~/.chez.txt`
- Recipient key: `age1n4nhw67j8ds89gavcf7s8d9ty2ceu7z8g93d3f3r3rg57er9lqfq8cttyp`
- Private SSH keys and sensitive configs stored encrypted

### Shell Configuration
- **Primary shell**: Zsh with Oh My Zsh
- **Theme**: `geoffgarside`
- **Plugin management**: Via `.chezmoiexternal.toml` (auto-updates weekly)
  - zsh-syntax-highlighting
  - zsh-autosuggestions
  - zsh-defer (for lazy loading)
- **Plugin loading order**:
  1. Oh My Zsh plugins (git, git-extras, github, npm, etc.)
  2. Tool initialization with lazy loading (direnv eager, asdf/fzf/zoxide deferred)
  3. Custom dotfiles from `~/.my/` (.exports, .aliases, .functions)
- **Architecture-aware Homebrew paths**: Auto-detects ARM64 vs Intel
- **Performance**: Lazy loading achieves < 100ms startup time (2-3x improvement)

### Setup Script Flow
1. Checks for required Age key (`~/.chez.txt`)
2. Validates macOS or CI environment
3. Installs Xcode Command Line Tools (if needed)
4. Installs Homebrew and Rosetta 2 (Apple Silicon)
5. **Installs chezmoi first** (needed to bootstrap dotfiles)
6. **Initializes and applies dotfiles** (creates Brewfile and other configs)
7. Installs 1Password CLI
8. Runs Brewfile bundle install from `~/.my/.Brewfile`
9. ZSH plugins managed by chezmoi (via `.chezmoiexternal.toml`)
10. Installs fzf keybindings
11. Runs macOS settings (once, tracked by `~/.my/.macos_configured` flag)

## Branch and PR Conventions

### Branch Naming
Use these prefixes:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `chore/` - Maintenance tasks

### Pull Request Labels
Version labels control semantic versioning on merge to master:
- `version/major` - Breaking changes (1.0.0 → 2.0.0)
- `version/patch` - Bug fixes (1.0.0 → 1.0.1)
- No label - Minor changes (1.0.0 → 1.1.0) **[DEFAULT]**

### PR Title Format
Follow conventional commits: `type: description`
- Examples: `feat: add vim config`, `fix: zsh path issue`, `docs: update README`

### Creating PRs with Multiline Bodies
```bash
# Use pr_body.md (already in .gitignore and .chezmoiignore)
cat > pr_body.md << 'EOF'
## Summary
- Description of changes

## Test plan
- [ ] Tested on fresh macOS install
- [ ] Verified chezmoi apply works
EOF

gh pr create --title "feat: add new feature" --body-file pr_body.md
```

## File Conventions

### Extensions
- GitHub Actions workflows: `.yml` (NOT `.yaml`)
- Chezmoi templates: `.tmpl`
- All filenames: lowercase with hyphens

### Ignored by Chezmoi
See `.chezmoiignore` for full list. Key items:
- Documentation files (README.md, LICENSE, CONTRIBUTING.md, CLAUDE.md, CHANGELOG.md)
- GitHub workflows and configs
- Repository scripts (setup.sh, test.sh)
- OS generated files

## CI/CD

### Workflows
- **ci** (`.github/workflows/ci.yml`): Runs ShellCheck and `test.sh` on PRs (manual trigger available)
- **security** (`.github/workflows/security.yml`): Weekly scans (Sundays at midnight) + PR checks with ShellCheck and Trivy config scanner

### Branch Protection
Master branch requires:
- All CI checks passing
- All PR conversations resolved
- No force pushes
- No direct commits

## Testing

The `test.sh` script validates:
1. Source files exist and are non-empty
2. Executable permissions on scripts
3. Configuration patterns in dotfiles
4. Shell script syntax (bash -n)
5. macOS-specific files (skipped in CI)
6. Template syntax (validates Go template structure)
7. Python 3 compatibility (no Python 2 code)
8. Dangerous git operations (with proper warnings)
9. Modern git configuration (no deprecated options)
10. No deprecated hub CLI usage
11. Essential config files exist (.gitattributes, .editorconfig)
12. Brew management functions exist (brew-diff, brew-sync, etc.)

## Important Files

- `~/.my/.Brewfile`: Homebrew package manifest (after setup)
- `~/.my/.macos`: macOS system preferences script
- `~/.my/.{exports,aliases,functions}`: Custom shell configuration
- `~/.chez.txt`: Age encryption private key (REQUIRED, not in repo)
- `.chezmoiignore`: Files excluded from home directory deployment
- `.gitattributes`: Line ending normalization and binary file handling
- `.editorconfig`: Consistent editor settings across team

## Shell Function Notes

### Safe Git Operations
- **fixit**: Legacy alias with force push warning (use `fixup` instead)
- **fixup()**: Safer alternative using `--force-with-lease` instead of `-f`

### Python 3 Only
All shell functions use Python 3:
- `urlencode`: Uses `urllib.parse` (Python 3)
- `server()`: Uses `http.server` module (Python 3)
- `json()`: Explicitly calls `python3`

### Git Config Features
- `fetch.prune = true`: Auto-cleanup stale remote branches
- `rerere.enabled = true`: Remember conflict resolutions

## Shell Evolution Migration Guide

This section documents breaking changes and new features from the comprehensive shell modernization (Sprint 1-6).

### Breaking Changes

**Removed Aliases** - Update your muscle memory:
- `refresh` → Use `dsync` instead (dotfiles sync)
- `glog` → Use `git l` or `git lg` instead (git aliases)
- `urlencode` → Use the function instead (same name, just type it)
- `dots` → Use `dot` instead (navigate to dotfiles) *[optional removal]*

**Removed Tools**:
- **hub CLI** → Use `gh` CLI instead (already installed)
  - Old: `hub pr create`
  - New: `gh pr create`
- **ghi** → No replacement needed (tool unmaintained)

**Performance Changes**:
- Shell startup optimized: OMZ install check removed, bash completion removed
- Completion now uses native zsh compinit (regenerates once per day)
- brew-orphans optimized from O(n²) to O(n)

### New Features Available

**Modern CLI Tool Integration** (Section 6 of TERMINAL_GUIDE.md):
```bash
df                  # Now uses duf (prettier disk free)
du                  # Now uses dust (visual disk usage)
help <cmd>          # Now uses tldr (quick command examples)
```

**Git Workflow Enhancements**:
```bash
# Worktree management (parallel branch work)
gwt                 # List worktrees
gwta feature-x      # Create worktree for branch
gwtr                # Remove worktree (interactive)
gwts                # Switch to worktree (interactive)

# Stash browser with preview
fstash              # Browse stashes, pop on Enter
fstash-show         # Browse stashes, show diff

# Branch cleanup
git-cleanup         # Remove merged branches (interactive)
git-prune-local     # Remove orphaned branches (interactive)

# Conventional commits
gcommit feat "add search"           # feat: add search
gcommit fix api "resolve timeout"   # fix(api): resolve timeout
gcfeat "add X"      # Alias for gcommit feat
gcfix "resolve Y"   # Alias for gcommit fix
gcdocs "update Z"   # Alias for gcommit docs
gcchore "clean W"   # Alias for gcommit chore
```

**Modern Navigation**:
```bash
zi                  # Interactive zoxide with fzf
tree                # Now uses eza (icons + git-aware)
tree-all            # Tree including hidden files
tre <dir>           # Tree with pager
```

**Enhanced Tools**:
```bash
diff file1 file2    # Now uses delta when available
fs <dir>            # Now uses dust when available
disk                # Visual disk usage (wrapper for dust)
```

**Benchmarking** (documented in termguide tool #15):
```bash
bench 'npm run build'               # Benchmark a command
bench-compare 'cmd1' 'cmd2'         # Compare two commands
```

**Developer Productivity**:
```bash
# Port management
port 3000           # What's using this port?
killport 3000       # Kill process on port
ports               # List all listening ports

# Environment switcher
envs                # List .env files
envswitch dev       # Switch to .env.dev
envswitch prod      # Switch to .env.prod
envnew staging      # Create .env.staging

# Clipboard helpers
copy "text"         # Copy to clipboard
cat file | copy     # Pipe to clipboard
copyfile config.json # Copy file contents
copypath            # Copy current directory path
```

### Bug Fixes Applied

1. **Man pages now work**: Fixed undefined `${yellow}` variable → now using bat for beautiful syntax-highlighted man pages
2. **Ripgrep config works**: Created missing `.ripgreprc` file
3. **Filenames with spaces work**: Fixed unquoted variables in `gifify()` and `fs()`
4. **SSH auth more robust**: Fixed SSH_AUTH_SOCK with proper quoting and graceful fallback
5. **Git functions safer**: Added repo checks to `todo()` and `fixup()` functions

### Configuration Changes

**Man Pages**: Now use bat instead of LESS_TERMCAP
```bash
# Old (broken):
export LESS_TERMCAP_md="${yellow}"

# New (beautiful):
export MANPAGER='sh -c "col -bx | bat -l man -p"'
```

**ZSH Completion**: Optimized for performance
```bash
# Now regenerates only once per 24 hours
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-~}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
```

### Testing Changes

All changes pass the existing test suite. No test modifications needed.

### Performance Impact

- Shell startup remains < 100ms (maintained or improved)
- brew-orphans now O(n) instead of O(n²)
- Completion regeneration reduced by ~99% (once/day vs every shell start)
- Removed slow bash completion compatibility layer

### Documentation

See `~/.my/TERMINAL_GUIDE.md` (or `termguide` / `tg` command) for:
- Comprehensive guide to all modern tools
- Progressive learning path (Week 1-6)
- Daily workflow examples
- Practice exercises

### Rollback

If issues arise, this commit can be reverted. All changes are backward compatible except for the removed aliases listed above.
