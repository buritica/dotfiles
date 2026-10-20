#!/usr/bin/env bats
# The deployed ~/.gitconfig, exercised with real repos.

setup() {
  load test_helper
}

@test "gitconfig parses and sets the identity" {
  run hgit config --global --list
  [ "$status" -eq 0 ]
  [ "$(hgit config --global user.email)" = "buritica@gmail.com" ]
  [ -n "$(hgit config --global user.name)" ]
}

@test "new repos start on main" {
  local repo
  repo="$(new_repo)"
  [ "$(hgit -C "$repo" branch --show-current)" = "main" ]
}

@test "git go creates a branch, then switches to it when it exists" {
  local repo
  repo="$(new_repo)"
  hgit -C "$repo" go topic
  [ "$(hgit -C "$repo" branch --show-current)" = "topic" ]
  hgit -C "$repo" go main
  hgit -C "$repo" go topic
  [ "$(hgit -C "$repo" branch --show-current)" = "topic" ]
}

@test "git amend keeps the message, git undo drops the commit but keeps the change" {
  local repo
  repo="$(new_repo)"
  echo two > "$repo/b.txt"
  hgit -C "$repo" add b.txt
  hgit -C "$repo" commit -q -m "add b"
  echo more >> "$repo/b.txt"
  hgit -C "$repo" add b.txt
  hgit -C "$repo" amend -q
  [ "$(hgit -C "$repo" log -1 --format=%s)" = "add b" ]
  [ "$(hgit -C "$repo" rev-list --count HEAD)" -eq 2 ]

  hgit -C "$repo" undo
  [ "$(hgit -C "$repo" rev-list --count HEAD)" -eq 1 ]
  [ "$(hgit -C "$repo" diff --cached --name-only)" = "b.txt" ]
}

@test "git wip / unwip round-trips uncommitted work" {
  local repo
  repo="$(new_repo)"
  echo wip > "$repo/w.txt"
  hgit -C "$repo" wip >/dev/null
  [ "$(hgit -C "$repo" log -1 --format=%s)" = "WIP" ]
  hgit -C "$repo" unwip
  [ "$(hgit -C "$repo" log -1 --format=%s)" = "initial" ]
  [ -f "$repo/w.txt" ]
}

@test "merges are fast-forward only" {
  local repo
  repo="$(new_repo)"
  hgit -C "$repo" switch -q -c side
  echo side > "$repo/s.txt"; hgit -C "$repo" add s.txt; hgit -C "$repo" commit -q -m side
  hgit -C "$repo" switch -q main
  echo main > "$repo/m.txt"; hgit -C "$repo" add m.txt; hgit -C "$repo" commit -q -m main
  run hgit -C "$repo" merge side
  [ "$status" -ne 0 ]
  [[ "$output" == *"fast-forward"* ]]
}

@test "git pr fetches a pull request head into pr-<n>" {
  local origin repo
  origin="$(new_repo)"
  hgit -C "$origin" update-ref refs/pull/7/head HEAD
  repo="$BATS_TEST_TMPDIR/clone"
  hgit clone -q "$origin" "$repo"
  hgit -C "$repo" pr 7 2>/dev/null
  [ "$(hgit -C "$repo" branch --show-current)" = "pr-7" ]
}

@test "commits are signed on the laptops only" {
  local cfg="$BATS_TEST_TMPDIR/gitconfig"
  render_as crowntail dot_gitconfig.tmpl > "$cfg"
  [ "$(git config --file "$cfg" commit.gpgsign)" = "true" ]
  [ "$(git config --file "$cfg" gpg.format)" = "ssh" ]

  render_as severo dot_gitconfig.tmpl > "$cfg"
  run git config --file "$cfg" commit.gpgsign
  [ "$output" != "true" ]
}

@test "git dft shows a difftastic diff of the working tree" {
  command -v difft >/dev/null 2>&1 || skip "difftastic not installed"
  local repo
  repo="$(new_repo)"
  printf 'fn main() {}\n' > "$repo/m.rs"
  hgit -C "$repo" add m.rs
  hgit -C "$repo" commit -q -m "add m.rs"
  printf 'fn main() { println!("hi"); }\n' > "$repo/m.rs"
  run hgit -C "$repo" dft
  [ "$status" -eq 0 ]
  [[ "$output" == *"m.rs"*"Rust"* ]] || { echo "$output"; return 1; }

  hgit -C "$repo" commit -q -am "print hi"
  for alias in dshow dlog; do
    run hgit -C "$repo" "$alias" -1 --no-color
    [ "$status" -eq 0 ]
    [[ "$output" == *"print hi"*"m.rs"*"Rust"* ]] || { echo "$alias: $output"; return 1; }
  done
}

@test "git fa folds a staged fix into the commit that wrote the line" {
  command -v git-absorb >/dev/null 2>&1 || skip "git-absorb not installed"
  local repo
  repo="$(new_repo)"
  echo two > "$repo/b.txt"
  hgit -C "$repo" add b.txt
  hgit -C "$repo" commit -q -m "add b"
  echo three > "$repo/c.txt"
  hgit -C "$repo" add c.txt
  hgit -C "$repo" commit -q -m "add c"
  echo TWO > "$repo/b.txt"
  hgit -C "$repo" add b.txt
  # GIT_SEQUENCE_EDITOR: the autosquash rebase runs as is, nothing to edit
  run env HOME="$TEST_HOME" GIT_CONFIG_NOSYSTEM=1 GIT_SEQUENCE_EDITOR=true GIT_EDITOR=true \
    git -C "$repo" fa
  [ "$status" -eq 0 ] || { echo "$output"; return 1; }
  [ "$(hgit -C "$repo" rev-list --count HEAD)" -eq 3 ]
  [ "$(hgit -C "$repo" show HEAD~1:b.txt)" = "TWO" ]
  [ -z "$(hgit -C "$repo" status --porcelain)" ]
}
