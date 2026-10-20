# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository managed with [chezmoi](https://chezmoi.io/), designed to bootstrap and maintain a consistent macOS development environment. Secrets use the 1Password SSH agent (no Age encryption).

> **Package ownership boundary**: this repo is PREFERENCES AND CONFIG ONLY. Homebrew packages (core + capabilities) are defined and installed by the machines ansible repo (`ansible/roles/packages/files/Brewfile`). There is no Brewfile in this repo. Do not add one.

## Key Commands

### Testing
```bash
./test.sh                    # Run all tests: syntax, shellcheck, then the bats suite in tests/
```

### Setup and Deployment
```bash
./setup.sh                   # Apply dotfiles on a Mac machines doesn't manage (needs chezmoi)
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

### Package Management

Packages are owned by the **machines ansible repo** (`ansible/roles/packages/files/Brewfile`), not this dotfiles repo. To add or change a package, edit that file and run the provision playbook.

The brew helpers reflect the new ownership: read-only audits (`brew-diff`, `brew-installed-only`, `brew-missing`, `brew-orphans`) check installed packages against the deployed Brewfile (`~/.config/homebrew/Brewfile`); `brew-edit` opens the source in the machines repo; `brew-export` writes a `/tmp` snapshot for reference. `brew-sync` is retired (it would edit a file the next provision overwrites).

### Capabilities (per-host)

Capability package selection has moved to the machines ansible repo (`host_vars/<hostname>.yml` + `ansible/roles/packages/`). This repo no longer controls which packages are installed per machine.

The `machine-list` and `machine-info` shell helpers still work for informational display.

## Architecture

### Chezmoi File Structure
- **Template files** (`.tmpl` extension): Processed by chezmoi's Go templates
  - `dot_gitconfig.tmpl`: Git configuration with user data from `.chezmoi.toml.tmpl`
  - `.chezmoi.toml.tmpl`: Chezmoi config (machine identity; no longer manages capabilities or Brewfile)
- **Executable files** (`executable_` prefix): Made executable when applied
  - `dot_my/executable_dot_macos`: macOS system settings script
- **Dotfiles** (`dot_` prefix): Mapped to hidden files in home directory
  - `dot_zshrc.tmpl` → `~/.zshrc`
  - `dot_my/` → `~/.my/` (custom shell scripts and configs)

### Secrets
- SSH keys are served by the 1Password agent; `known_hosts` self-populates
- No Age encryption; no key files in the repo

### Shell Configuration
- **Primary shell**: Zsh with Oh My Zsh, pinned to a commit in `.chezmoiexternal.toml` (same SHA as team-perrito/estanli's `dotfiles_omz_version`; bump both together). OMZ's own updater is disabled.
- **Prompt**: starship (from the machines core Brewfile) with `dot_config/zsh-base/starship.toml`; the per-host emoji is `ZSH_PROMPT_EMOJI` in `dot_zshrc.tmpl`. Falls back to the `geoffgarside` theme when starship is missing.
- **Plugin management**: Via `.chezmoiexternal.toml` (pinned to tags/commits; bump by editing the URL)
  - zsh-syntax-highlighting
  - zsh-autosuggestions
  - zsh-defer (for lazy loading)
- **Plugin loading order**:
  1. Oh My Zsh plugins (git, git-extras, npm, etc.)
  2. Tool initialization with lazy loading (direnv eager, mise/fzf/zoxide deferred)
  3. Custom dotfiles from `~/.my/` (.exports, .aliases, .functions)
- **Architecture-aware Homebrew paths**: Auto-detects ARM64 vs Intel
- **Performance**: Lazy loading achieves < 100ms startup time (2-3x improvement)

### Shared zsh base (`dot_config/zsh-base/`)
Plain zsh (no templating, no `~/.my` or other buritica-only paths; optional tools like fzf/bat/gh are `command -v`-guarded, macOS basics like `open`/`lsof` are assumed) shared with the `estanli` account on severo:
- `omz.zsh`: Oh My Zsh plugin set and the starship prompt (`starship.toml`), and the zsh history settings (sizes, `HISTORY_IGNORE`, setopts) for both accounts; `functions.zsh`: git worktree/stash, fzf pickers, port/env helpers
- Here, chezmoi deploys it to `~/.config/zsh-base/` and `dot_zshrc.tmpl` sources it. On severo, team-perrito/estanli's `dotfiles` role clones this public repo and links `~/.config/zsh-base` to it; team-perrito/estanli-dotfiles keeps only that account's overrides.
- Anything that only makes sense for buritica stays in `dot_my/` (loads after the base). Changes here reach estanli on its next dotfiles deploy, so keep it portable.

### Setup Script Flow
On managed Macs the machines repo does all of this (`bootstrap.sh`: Homebrew, Rosetta, 1Password CLI; `provision.yml`: chezmoi, packages, and `chezmoi init --apply`), so `setup.sh` is only for a Mac it doesn't manage. It:
1. Validates macOS or CI environment
2. Checks chezmoi is installed (exits with a hint if not)
3. **Initializes and applies dotfiles** (shell config, git config, macOS defaults via `run_onchange_apply-macos-defaults.sh`, zsh plugins via `.chezmoiexternal.toml`)

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
- Repository scripts and tests (setup.sh, test.sh, tests/)
- OS generated files

## CI/CD

### Workflows
- **ci** (`.github/workflows/ci.yml`): Runs `test.sh` on PRs on Ubuntu and macOS, with Oh My Zsh at the SHA estanli pins (manual trigger available)
- **security** (`.github/workflows/security.yml`): Weekly scans (Sundays at midnight) + PR checks with ShellCheck and Trivy config scanner

### Branch Protection
Master branch requires:
- All CI checks passing
- All PR conversations resolved
- No force pushes
- No direct commits

## Testing

`test.sh` runs `bash -n` and `zsh -n` (including the rendered `.zshrc`), shellcheck when installed, then the bats suite in `tests/`. Needs `chezmoi`, `bats-core`, `zsh` and `git`.

The suite applies the dotfiles once into a throwaway `$HOME` (`tests/setup_suite.bash`, scripts excluded so `~/.my/.macos` never runs) and tests the result rather than grepping the source:
- `chezmoi.bats`: apply is clean and `chezmoi verify` passes, repo-only files stay out of `$HOME`, per-host files (`id_halfmoon.pub`), the macOS run script's re-run hash and its laptop-only gate
- `zsh.bats`: an interactive shell starts without stderr, the shared history settings win over OMZ's, functions survive OMZ's aliases, host prompt emoji, every host's `.zshrc` parses, `.zshenv` PATH with and without `path.zsh`
- `functions.bats`: the shared helpers (`gcommit`, `gwta`, `envswitch`, `envnew`, …) run against real repos and files
- `git.bats` / `ssh.bats` / `tmux.bats`: the deployed gitconfig's aliases, merge policy and laptop-only signing; `ssh -G` resolution of `~/.ssh/config` (fleet aliases, connection reuse, halfmoon's key); `~/.tmux.conf` loads in a real tmux

Host-specific templates are rendered per hostname by `render_as` in `tests/test_helper.bash` (including the `laptop` data `.chezmoi.toml.tmpl` derives). Set `DOTFILES_TEST_OMZ=<checkout>` to test with Oh My Zsh (CI does), or `DOTFILES_TEST_NO_EXTERNALS=1` when GitHub archive downloads are blocked.

## Important Files

- `~/.my/.macos`: macOS system preferences script
- `~/.my/.{exports,aliases,functions}`: Custom shell configuration
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
