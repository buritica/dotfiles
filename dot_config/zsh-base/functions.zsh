# functions.zsh — shared zsh base: dev-workflow functions (git worktrees, fzf
# pickers, port/env helpers). Plain zsh, no chezmoi templating, no
# account-specific paths, every tool dependency `command -v`-guarded.
#
# Consumed by two accounts: buritica's (chezmoi deploys this dir to
# ~/.config/zsh-base) and the estanli account on severo (the dotfiles role in
# team-perrito/estanli clones this repo and links ~/.config/zsh-base here).
# Per-account functions stay in their own repos and load after this file.
# Changes reach every fleet host on their own: machines' dotfiles-rollout
# daemon applies new master commits within about 10 minutes.

# shellcheck shell=bash
# Oh My Zsh's git plugin defines `alias gwt='git worktree'` etc. — in zsh an
# alias is expanded at function-definition time, so `gwt() {` would parse as
# `git worktree () {` without this. Sourced after oh-my-zsh, so unalias
# before (re)defining.
for _fn_alias in gwt gwta gwtr gwts gcommit; do
  unalias "$_fn_alias" 2>/dev/null || true
done
unset _fn_alias

# --- Directory shortcuts ---

# `s` with no arguments cds into ~/src, otherwise opens the given subdir
s() {
  if [ $# -eq 0 ]; then
    cd ~/src || return
  else
    cd ~/src/"$1" || return
  fi
}

# `o` with no arguments opens the current directory, otherwise the given path
o() {
  if [ $# -eq 0 ]; then
    open .
  else
    open "$@"
  fi
}

# Create a new directory and enter it
mkd() {
  mkdir -p "$@" && cd "$_" || return
}

# `e` with no arguments opens the current directory in VS Code, otherwise
# opens the given location
e() {
  if [ $# -eq 0 ]; then
    code .
  else
    code "$@"
  fi
}

# --- Git workflow helpers (worktrees, stash, cleanup, conventional commits) ---

gwt() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "❌ Not a git repository"
    return 1
  fi
  git worktree list
}

gwta() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "❌ Not a git repository"
    return 1
  fi
  local branch="$1"
  # not `path`: zsh ties it to $PATH, so `local path=...` would clobber PATH
  local wt_path="${2:-../${branch}}"
  if [[ -z "$branch" ]]; then
    echo "Usage: gwta <branch-name> [path]"
    return 1
  fi
  git worktree add -b "$branch" "$wt_path" && cd "$wt_path" || return
}

gwtr() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "❌ Not a git repository"
    return 1
  fi
  if ! command -v fzf &>/dev/null; then
    echo "❌ gwtr requires fzf"
    return 1
  fi
  local worktree
  worktree=$(git worktree list | sed '1d' | fzf --height 40% | awk '{print $1}')
  [[ -n "$worktree" ]] && git worktree remove "$worktree"
}

gwts() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "❌ Not a git repository"
    return 1
  fi
  if ! command -v fzf &>/dev/null; then
    echo "❌ gwts requires fzf"
    return 1
  fi
  local worktree
  worktree=$(git worktree list | fzf --height 40% | awk '{print $1}')
  [[ -n "$worktree" ]] && cd "$worktree" || return
}

fstash() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "❌ Not a git repository"
    return 1
  fi
  if ! command -v fzf &>/dev/null; then
    echo "❌ fstash requires fzf"
    return 1
  fi
  local stash
  stash=$(git stash list | fzf --height 40% --preview 'git stash show -p {1}' --preview-window=right:60%)
  [[ -n "$stash" ]] && git stash pop "${stash%%:*}"
}

fstash-show() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "❌ Not a git repository"
    return 1
  fi
  if ! command -v fzf &>/dev/null; then
    echo "❌ fstash-show requires fzf"
    return 1
  fi
  local stash
  stash=$(git stash list | fzf --height 40% --preview 'git stash show -p {1}' --preview-window=right:60%)
  [[ -n "$stash" ]] && git stash show -p "${stash%%:*}"
}

git-cleanup() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "❌ Not a git repository"
    return 1
  fi
  local branches
  branches=$(git branch --merged | grep -v '\*\|master\|main\|develop')
  if [[ -z "$branches" ]]; then
    echo "✨ No merged branches to clean up"
    return 0
  fi
  echo "🗑️  Merged branches:"
  echo "$branches"
  echo ""
  read -q "REPLY?Delete these branches? [y/N] "
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "$branches" | xargs git branch -d
    echo "✅ Branches deleted"
  else
    echo "❌ Cancelled"
  fi
}

git-prune-local() {
  if ! git rev-parse --git-dir &>/dev/null; then
    echo "❌ Not a git repository"
    return 1
  fi
  git fetch -p
  local branches
  branches=$(git branch -vv | grep ': gone]' | awk '{print $1}')
  if [[ -z "$branches" ]]; then
    echo "✨ No orphaned branches"
    return 0
  fi
  echo "🗑️  Branches not on remote:"
  echo "$branches"
  echo ""
  read -q "REPLY?Delete these branches? [y/N] "
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    local -a failed_branches
    while IFS= read -r branch; do
      [[ -z "$branch" ]] && continue
      if ! git branch -d "$branch" 2>/dev/null; then
        failed_branches+=("$branch")
      fi
    done <<< "$branches"
    if (( ${#failed_branches[@]} > 0 )); then
      echo ""
      echo "⚠️  The following branches have unmerged changes:"
      printf '  %s\n' "${failed_branches[@]}"
      echo ""
      read -q "REPLY?Force delete these unmerged branches? [y/N] "
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -D "${failed_branches[@]}"
        echo "✅ All branches deleted (some forced)"
      else
        echo "❌ Cancelled force delete"
      fi
    else
      echo "✅ Branches deleted"
    fi
  fi
}

gcommit() {
  local type="${1}"
  local scope="${2}"
  local message="${3:-}"
  if [[ -z "$type" ]] || [[ -z "$message" && -z "$scope" ]]; then
    echo "Usage: gcommit <type> [scope] <message>"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    return 1
  fi
  if [[ -z "$message" ]]; then
    message="$scope"
    scope=""
  fi
  local commit_msg="${type}"
  [[ -n "$scope" ]] && commit_msg="${commit_msg}(${scope})"
  commit_msg="${commit_msg}: ${message}"
  git commit -m "$commit_msg"
}
alias gcfeat='gcommit feat'
alias gcfix='gcommit fix'
alias gcdocs='gcommit docs'
alias gcchore='gcommit chore'

# --- fzf-powered pickers ---

fcd() {
  if ! command -v fd &>/dev/null || ! command -v fzf &>/dev/null || ! command -v eza &>/dev/null; then
    echo "Error: fcd requires fd, fzf, and eza to be installed"
    return 1
  fi
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git | fzf --preview 'eza --tree --level=2 --icons=auto {}') && cd "$dir" || return
}

fe() {
  if ! command -v fzf &>/dev/null || ! command -v bat &>/dev/null || ! command -v code &>/dev/null; then
    echo "Error: fe requires fzf, bat, and code to be installed"
    return 1
  fi
  local files
  # shellcheck disable=SC2034,SC2296  # zsh (f) flag: one arg per selected file
  files=$(fzf --multi --preview 'bat --color=always --style=numbers --line-range=:500 {}') && code "${(f)files[@]}"
}

fbr() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: fbr requires fzf"
    return 1
  fi
  local branch
  branch=$(git branch --all | grep -v HEAD | sed 's/remotes\/origin\///' | sort -u | fzf --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {}')
  # git branch's leading marker is always exactly 2 chars: "* " (current) or "  ".
  [[ -n "$branch" ]] && git switch "${branch:2}"
}

fshow() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: fshow requires fzf"
    return 1
  fi
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
    --bind "ctrl-m:execute:
            (grep -o '[a-f0-9]\{7\}' | head -1 |
            xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
            {}
FZF-EOF"
}

frg() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: frg requires fzf"
    return 1
  fi
  if [ $# -eq 0 ]; then
    echo "Usage: frg <search_term>"
    return 1
  fi
  rg --color=always --line-number --no-heading --smart-case "${*:-}" |
    fzf --ansi \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:become(code {1}:{2})'
}

ghpr() {
  if ! command -v gh &>/dev/null || ! command -v fzf &>/dev/null; then
    echo "Error: ghpr requires gh and fzf to be installed"
    return 1
  fi
  local pr_number
  pr_number=$(gh pr list | fzf --preview 'gh pr view {1}' --preview-window=right:60% | awk '{print $1}')
  [[ -n "$pr_number" ]] && gh pr view --web "$pr_number"
}

ghissue() {
  if ! command -v gh &>/dev/null || ! command -v fzf &>/dev/null; then
    echo "Error: ghissue requires gh and fzf to be installed"
    return 1
  fi
  local issue_number
  issue_number=$(gh issue list | fzf --preview 'gh issue view {1}' --preview-window=right:60% | awk '{print $1}')
  [[ -n "$issue_number" ]] && gh issue view --web "$issue_number"
}

# --- Dev productivity ---

port() {
  local port="${1}"
  if [[ -z "$port" ]]; then
    echo "Usage: port <port-number>"
    return 1
  fi
  lsof -i ":$port"
}

killport() {
  local port="${1}"
  if [[ -z "$port" ]]; then
    echo "Usage: killport <port-number>"
    return 1
  fi
  local pids pid
  pids=$(lsof -ti ":$port")
  if [[ -z "$pids" ]]; then
    echo "❌ No process found on port $port"
    return 1
  fi
  # shellcheck disable=SC2296  # zsh (f) flag: lsof prints one PID per line
  for pid in "${(f)pids[@]}"; do
    if ! kill -0 "$pid" 2>/dev/null; then
      echo "⚠️  Process $pid exited before kill (race condition avoided)"
      continue
    fi
    echo "🛑 Stopping process $pid on port $port (SIGTERM)..."
    if ! kill -15 "$pid" 2>/dev/null; then
      echo "⚠️  Process $pid already exited"
      continue
    fi
    local count=0
    while kill -0 "$pid" 2>/dev/null && [[ $count -lt 6 ]]; do
      sleep 0.5
      count=$((count + 1))
    done
    if kill -0 "$pid" 2>/dev/null; then
      echo "⚠️  Process $pid didn't stop gracefully, force killing (SIGKILL)..."
      kill -9 "$pid" 2>/dev/null
    fi
    echo "✅ Process $pid stopped"
  done
}

ports() {
  echo "📡 Listening ports:"
  lsof -iTCP -sTCP:LISTEN -n -P
}

envs() {
  local env_files
  env_files=$(ls -1 .env* 2>/dev/null)
  if [[ -z "$env_files" ]]; then
    echo "❌ No .env files found in current directory"
    return 1
  fi
  echo "Available environment files:"
  echo "$env_files" | nl
}

envswitch() {
  local env_file=".env.${1}"
  if [[ -z "$1" ]]; then
    echo "Usage: envswitch <environment>"
    envs
    return 1
  fi
  if [[ ! -f "$env_file" ]]; then
    echo "❌ $env_file not found"
    envs
    return 1
  fi
  if [[ -f .env ]]; then
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    cp .env ".env.backup.$timestamp"
    echo "💾 Backed up current .env to .env.backup.$timestamp"
    local backup_count
    backup_count=$(find . -maxdepth 1 -name '.env.backup.*' | wc -l | tr -d ' ')
    if [[ $backup_count -gt 3 ]]; then
      find . -maxdepth 1 -name '.env.backup.*' -print0 | xargs -0 ls -t | tail -n +4 | xargs -r rm -f
      echo "🧹 Cleaned up old backups (kept last 3)"
    fi
  fi
  cp "$env_file" .env
  echo "✅ Switched to $env_file"
}

envnew() {
  local env_name="${1}"
  if [[ -z "$env_name" ]]; then
    echo "Usage: envnew <environment>"
    return 1
  fi
  local env_file=".env.${env_name}"
  if [[ -f "$env_file" ]]; then
    echo "❌ $env_file already exists"
    return 1
  fi
  if [[ -f ".env.template" ]]; then
    cp .env.template "$env_file"
    echo "✅ Created $env_file from template"
  else
    touch "$env_file"
    echo "✅ Created empty $env_file"
  fi
  ${=EDITOR:-code} "$env_file"   # ${=...} word-splits so EDITOR="code -w" works
}

json() {
  if [ -t 0 ]; then
    python3 -m json.tool <<< "$*" | pygmentize -l javascript
  else
    python3 -m json.tool | pygmentize -l javascript
  fi
}

server() {
  local port="${1:-8000}"
  sleep 1 && open "http://localhost:${port}/" &
  python3 -m http.server "$port"
}

disk() {
  if ! command -v dust &>/dev/null; then
    echo "❌ disk requires dust"
    return 1
  fi
  dust -d "${1:-2}" -r "${2:-.}"
}

bench() {
  if ! command -v hyperfine &>/dev/null; then
    echo "❌ bench requires hyperfine"
    return 1
  fi
  if [[ -z "$1" ]]; then
    echo "Usage: bench <command> [command2...]"
    return 1
  fi
  hyperfine --warmup 3 "$@"
}

bench-compare() {
  if [[ -z "$2" ]]; then
    echo "Usage: bench-compare <command1> <command2>"
    return 1
  fi
  hyperfine --warmup 3 "$1" "$2"
}
