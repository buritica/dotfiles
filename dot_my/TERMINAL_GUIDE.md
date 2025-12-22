# Terminal Mastery Guide

Your progressive learning path to modern terminal excellence.

---

## Stage 1: Foundation Tools (Week 1)
Master the basics that you'll use every day:

### 1. **eza** - Modern ls replacement
**What it does**: Shows files with colors, icons, and git status

**Start here**:
```bash
# Basic usage (automatically via 'ls' alias)
ls                    # List all files with details, icons, git status
ll                    # List files (no hidden files)
lt                    # Show directory tree (2 levels deep)
```

**Learn this pattern**:
```bash
eza --long            # Detailed list view
eza --tree            # Tree view
eza --sort=modified   # Sort by modification time
eza --git-ignore      # Hide files from .gitignore
```

**Daily practice**: Every time you type `ls`, notice the git status column (M=modified, A=added, ?=untracked)

---

### 2. **bat** - Syntax-highlighted cat
**What it does**: Shows file contents with beautiful syntax highlighting and line numbers

**Start here**:
```bash
cat package.json      # Now shows JSON with syntax highlighting
catp README.md        # Full-page view with pager (scroll with space/arrows)
```

**Learn this pattern**:
```bash
bat -A file.txt       # Show all characters (spaces, tabs, newlines)
bat --line-range 10:20 file.js   # Show only lines 10-20
bat --diff file1.js file2.js     # Show differences between files
```

**Daily practice**: Use `cat` instead of opening files in editor for quick viewing

---

### 3. **zoxide** - Smart cd
**What it does**: Remembers directories you visit and lets you jump to them with partial names

**Start here**:
```bash
# Visit a directory normally
cd ~/projects/my-app/src/components

# Next time, just type:
z components          # Jumps straight there
z my-app             # Jumps to project root
```

**Learn this pattern**:
```bash
z <partial-name>      # Jump to most frequent/recent match
zi <partial-name>     # Interactive fuzzy selection
z ..                  # Go up one directory
```

**Daily practice**:
- Week 1: Just use `cd` normally, let zoxide learn your patterns
- Week 2: Start using `z` for frequently visited directories
- Week 3: Master `zi` for when you're not sure of the exact path

---

## Stage 2: Search & Discovery (Week 2-3)
Level up your ability to find things:

### 4. **ripgrep (rg)** - Super-fast code search
**What it does**: Searches file contents 100x faster than grep, respects .gitignore

**Start here**:
```bash
rg "TODO"             # Find all TODOs in your codebase
rg "function"         # Find all functions
rg "import.*react"    # Regex: all React imports
```

**Learn this pattern**:
```bash
rg "pattern" --type js         # Search only JavaScript files
rg "pattern" -A 3              # Show 3 lines After match
rg "pattern" -B 3              # Show 3 lines Before match
rg "pattern" -C 3              # Show 3 lines of Context
rg "pattern" --files-with-matches  # Just show filenames
rg --no-ignore "secret"        # Search even .gitignored files
```

**Daily practice**: Replace `grep` with `rg` for searching codebases

**Real examples**:
```bash
# Find where a function is defined
rg "function handleSubmit"

# Find all console.logs (for cleanup)
rg "console\.(log|warn|error)"

# Find files that import a specific module
rg "import.*Button" --files-with-matches

# Find security issues
rg "password.*=.*['\"]"
```

---

### 5. **fd** - User-friendly find
**What it does**: Finds files by name, much simpler syntax than `find`

**Start here**:
```bash
fd config             # Find all files with "config" in name
fd "\.js$"            # Find all .js files (regex)
fd README -x cat      # Find README files and cat each one
```

**Learn this pattern**:
```bash
fd pattern                    # Find files by name
fd pattern --type f           # Only files
fd pattern --type d           # Only directories
fd pattern --extension js     # Only .js files
fd pattern --exec code        # Open each match in VS Code
```

**Daily practice**: Use `fd` instead of `find` for locating files

**Real examples**:
```bash
# Find all test files
fd test

# Find all config files
fd -e json -e yaml config

# Find and delete all node_modules
fd node_modules --type d --exec rm -rf

# Find large files
fd --size +10m
```

---

## Stage 3: Interactive Workflows (Week 3-4)
Add fuzzy finding superpowers:

### 6. **fzf** - Fuzzy finder everywhere
**What it does**: Interactive fuzzy search for files, history, processes, anything

**Start here - Keyboard shortcuts**:
```bash
Ctrl+R    # Search command history (type partial command)
Ctrl+T    # Find file and paste path (try it in any command)
Alt+C     # Fuzzy cd into directory
```

**Learn this pattern**:
```bash
# In command line, type:
code **<TAB>         # Fuzzy find file to open
cd **<TAB>           # Fuzzy find directory to cd into
kill -9 **<TAB>      # Fuzzy find process to kill
```

**Daily practice**:
- Day 1-3: Just use Ctrl+R for command history
- Day 4-7: Add Ctrl+T when typing file paths
- Week 2: Master Alt+C for directory navigation

**Real examples**:
```bash
# Finding that command you ran yesterday
Ctrl+R → type "docker" → see all docker commands

# Opening a file deep in your project
code<space>Ctrl+T → type "config" → fuzzy find the config file

# Quick directory jump
Alt+C → type "component" → jump to components directory
```

---

### 7. **Custom fzf functions** - Power combinations
Once you're comfortable with basic fzf (Ctrl+R, Ctrl+T, Alt+C), these functions combine multiple tools:

**fcd** - Fuzzy cd with preview:
```bash
fcd                   # Shows directory tree preview as you search
# Use case: "I need to get to that folder but don't remember exact name"
```

**fe** - Fuzzy file edit:
```bash
fe                    # Preview file contents while searching
# Use case: "I want to edit one of these config files but not sure which"
```

**frg** - Interactive ripgrep:
```bash
frg "handleClick"     # Search code, preview matches, press Enter to open
# Use case: "Where did I use this function?"
```

**fbr** - Fuzzy git branch:
```bash
fbr                   # See branch commits preview, checkout on Enter
# Use case: "Which branch was I working on last week?"
```

**fshow** - Interactive git log:
```bash
fshow                 # Browse commits, press Enter to see full diff
# Use case: "What changed in the last few commits?"
```

**Daily practice**: Pick ONE function per week to master
- Week 1: `fcd` (replaces lots of cd/ls cycles)
- Week 2: `frg` (replaces manual file opening)
- Week 3: `fbr` (replaces `git branch -a | grep`)
- Week 4: Combine them all into your natural workflow

---

## Stage 4: Git Workflow Enhancement (Week 4-5)

### 8. **delta** - Beautiful git diffs
**What it does**: Makes git diffs readable with syntax highlighting and side-by-side view

**Start here**:
```bash
git diff              # Now shows side-by-side with highlighting
git log -p            # Browse commits with beautiful diffs
git show abc123       # View specific commit with delta
```

**Learn this pattern**:
```bash
# In the delta pager:
n / N                 # Jump to next/previous file
/ <pattern>           # Search within diff
q                     # Quit
```

**Daily practice**: Every time you run `git diff`, notice:
- Red/green highlighting for changes
- Side-by-side comparison
- Line numbers on both sides

**Real examples**:
```bash
# Review your changes before committing
git diff

# Compare branches
git diff main..feature-branch

# See what changed in last commit
git show HEAD

# Review PR changes
git diff origin/main...HEAD
```

---

### 9. **Modern git aliases**
**What they do**: Shortcuts for common git operations

**Start here**:
```bash
git sw main          # Switch branch (shorter than checkout)
git swc feature-x    # Create and switch to new branch
git sync             # Fetch + pull with rebase
```

**Learn this pattern**:
```bash
# Modern commands
git sw <branch>      # Switch to existing branch
git swc <branch>     # Create and switch to new branch
git restore <file>   # Undo changes to file

# Interactive rebase
git ri HEAD~3        # Rebase interactively last 3 commits
git rc               # Continue rebase
git ra               # Abort rebase

# Worktrees (advanced - for managing multiple branches)
git wta ../feature-b feature-b   # Create worktree for feature-b
git wtl              # List all worktrees
git wtr ../feature-b # Remove worktree
```

**Daily practice**: Replace old habits
- `git checkout` → `git sw`
- `git checkout -b` → `git swc`
- `git fetch && git pull` → `git sync`

---

## Stage 5: GitHub CLI Integration (Week 5-6)

### 10. **gh + fzf functions**
**What they do**: Interactive PR and issue management

**Start here**:
```bash
ghpr                  # Browse PRs with preview, open in browser
ghissue               # Browse issues with preview
```

**Learn this pattern**:
```bash
# Traditional workflow (slow):
gh pr list            # Look at list
gh pr view 123        # Copy number, view PR
gh pr view --web 123  # Open in browser

# New workflow (fast):
ghpr                  # Arrow keys, Enter to open
```

**Daily practice**: Use `ghpr` for code review instead of opening GitHub

**Real examples**:
```bash
# Check your assigned PRs
gh pr list --assignee @me

# Create PR with body
gh pr create --title "feat: add search" --body-file pr_body.md

# Checkout PR locally
gh pr checkout 123

# Interactive PR review
ghpr                  # Browse, preview, open
```

---

## Stage 6: System Utilities (Week 6+)
Tools you'll use occasionally but are great to know:

### 11. **procs** - Modern ps
```bash
pg chrome             # Find Chrome processes (uses procs if available)
procs --tree          # Show process tree
procs --sort cpu      # Sort by CPU usage
```

### 12. **dust** - Better disk usage
```bash
dust                  # Visual tree of disk usage
dust -d 2             # Only 2 levels deep
dust -r               # Reverse sort (largest last)
```

### 13. **duf** - Prettier df
```bash
duf                   # Colorful disk usage overview
```

### 14. **tldr** - Quick command examples
```bash
tldr tar              # Quick examples instead of full man page
tldr git-rebase       # Learn git rebase with examples
```

### 15. **hyperfine** - Command benchmarking
```bash
hyperfine 'npm run build'              # Benchmark build time
hyperfine 'rg pattern' 'grep pattern'  # Compare tool speeds
```

---

## Daily Workflow Examples

### Morning: Start working on feature
```bash
# Jump to project (zoxide remembers)
z my-project

# Check current status
ls                    # See git-modified files with icons

# See what changed overnight
git diff main..develop  # Beautiful delta diff

# Switch to feature branch or create new one
git sw feature-auth
# or
git swc feature-new-thing

# Check what PRs need review
ghpr                  # Interactive browser
```

### During work: Finding things
```bash
# "Where did I define that function?"
frg "handleSubmit"    # Interactive search with preview

# "Need to update some config"
fe                    # Fuzzy find with file preview

# "What was that directory called?"
fcd                   # Fuzzy directory navigation
```

### Before commit: Review changes
```bash
# See what you changed
git diff              # Side-by-side with delta

# Review specific file
git diff src/utils.js

# Preview changes to commit
git diff --staged
```

### End of day: Branch management
```bash
# See recent commits
fshow                 # Interactive git log

# Need to switch contexts?
fbr                   # Fuzzy branch selector

# Sync with remote
git sync              # Fetch + pull with rebase
```

---

## Practice Exercises

### Week 1 Challenges
1. Use `ls` in 5 different directories and identify modified files by git status
2. Use `cat` on 3 different file types (JS, JSON, MD) and notice syntax highlighting
3. Visit 10 different directories with `cd`, then use `z` to jump between them

### Week 2 Challenges
1. Find all TODOs in your codebase with `rg`
2. Find all files that import React with `rg`
3. Use `fd` to find all test files
4. Use Ctrl+R to find a command you ran yesterday

### Week 3 Challenges
1. Use Ctrl+T to add a file path to a command
2. Use Alt+C to navigate to 3 different directories
3. Use `fcd` to explore your project structure
4. Use `frg` to search for a function and open it

### Week 4 Challenges
1. Review your last 5 commits with `git diff` and notice delta features
2. Create a branch with `git swc`, make changes, compare with `git diff main..HEAD`
3. Use `fbr` to switch between 3 branches
4. Use `fshow` to browse your commit history

### Week 5 Challenges
1. Use `ghpr` to review 3 open PRs
2. Create a PR with `gh pr create`
3. Find which commit introduced a bug with `fshow`

---

## Quick Reference Card

### Keyboard Shortcuts (memorize these first!)
```
Ctrl+R    History search (use daily!)
Ctrl+T    File finder (use when typing paths)
Alt+C     Directory jumper (use for navigation)
```

### Essential Commands
```bash
# Navigation
ls        # List files (now with eza: icons + git status)
z name    # Smart cd (learns your patterns)
fcd       # Fuzzy cd with preview

# Viewing files
cat file  # View file (now with bat: syntax highlighting)
catp file # View file with pager (scrollable)

# Searching
rg "text"     # Search in files (super fast)
fd filename   # Find files by name
frg "text"    # Interactive search + open

# Git
git diff      # See changes (now with delta: side-by-side)
git sw branch # Switch branch (modern syntax)
fbr           # Fuzzy branch switcher
fshow         # Interactive commit browser

# GitHub
ghpr          # Browse PRs interactively
ghissue       # Browse issues interactively
```

### Tool Discovery
```bash
# Learn any command with examples
tldr <command>

# Get help for any command
<command> --help | bat
```

---

## Troubleshooting

### "Command not found" after install
```bash
# Reload your shell config
source ~/.zshrc

# Or just open a new terminal window
```

### "fzf keybindings not working"
```bash
# Manually install fzf keybindings
$(brew --prefix)/opt/fzf/install
```

### "zoxide doesn't have any paths yet"
```bash
# Use regular cd for a few days, it needs to learn your patterns
cd ~/projects/my-app
cd ~/documents
# After a week, z will know these places
```

### "delta not showing in git diff"
```bash
# Verify delta is configured
git config --get core.pager
# Should output: delta

# If not, apply changes with:
chezmoi apply
```

---

## Accessing This Guide

Quick access anytime:
```bash
termguide    # View this guide with syntax highlighting
tg           # Short alias
```
