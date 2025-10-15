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
./setup.sh                   # Full setup (macOS only, requires ~/chez.txt Age key)
chezmoi apply                # Apply dotfile changes
chezmoi update              # Pull and apply latest changes
```

### Development Workflow
```bash
gh pr create --title "type: description" --body-file pr_body.md    # Create PR with body file
chezmoi add ~/.myfile       # Track a new dotfile
chezmoi edit ~/.myfile      # Edit tracked file in source
```

## Architecture

### Chezmoi File Structure
- **Template files** (`.tmpl` extension): Processed by chezmoi's Go templates
  - `dot_gitconfig.tmpl`: Git configuration with user data from `.chezmoi.toml.tmpl`
  - `dot_my/dot_Brewfile.tmpl`: Homebrew package list
  - `.chezmoi.toml.tmpl`: Chezmoi config with Age encryption settings
- **Executable files** (`executable_` prefix): Made executable when applied
  - `dot_my/executable_dot_macos`: macOS system settings script
- **Dotfiles** (`dot_` prefix): Mapped to hidden files in home directory
  - `dot_zshrc` → `~/.zshrc`
  - `dot_my/` → `~/.my/` (custom shell scripts and configs)

### Encryption
- Uses Age encryption with identity at `~/.chez.txt`
- Recipient key: `age1n4nhw67j8ds89gavcf7s8d9ty2ceu7z8g93d3f3r3rg57er9lqfq8cttyp`
- Private SSH keys and sensitive configs stored encrypted

### Shell Configuration
- **Primary shell**: Zsh with Oh My Zsh
- **Theme**: `geoffgarside`
- **Plugin loading order**:
  1. Oh My Zsh plugins (git, git-extras, github, macos, npm, etc.)
  2. Tool initialization (nodenv, direnv, asdf)
  3. Custom dotfiles from `~/.my/` (.exports, .aliases, .functions)
- **Architecture-aware Homebrew paths**: Auto-detects ARM64 vs Intel

### Setup Script Flow
1. Checks for required Age key (`~/chez.txt`)
2. Validates macOS or CI environment
3. Installs Xcode Command Line Tools (if needed)
4. Installs Homebrew and Rosetta 2 (Apple Silicon)
5. Installs 1Password CLI
6. Runs Brewfile bundle install from `~/.my/.Brewfile`
7. Initializes chezmoi and applies dotfiles
8. Runs macOS settings (once, tracked by `.macos_configured` flag)

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
- Documentation files (README.md, LICENSE, CONTRIBUTING.md, etc.)
- GitHub workflows and configs
- Repository scripts (setup.sh, test.sh)
- OS generated files

## CI/CD

### Workflows
- **ci** (`.github/workflows/ci.yml`): Runs ShellCheck and `test.sh` on PRs
- **security** (`.github/workflows/security.yml`): Weekly scans + PR checks (ShellCheck, Trivy)
- **release**: Auto-creates semantic version tags on merge to master based on PR labels

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
