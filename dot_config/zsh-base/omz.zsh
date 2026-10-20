# omz.zsh — shared zsh base: Oh My Zsh with the plugin set and prompt every
# account uses. Each account's .zshrc sources this, then layers its own config.
# Oh My Zsh and the two community plugins are installed by the account's
# provisioner (chezmoi's .chezmoiexternal.toml for buritica, the estanli
# collection's dotfiles role for estanli), both pinned to the same Oh My Zsh
# commit; missing pieces degrade, never break.
#
# The prompt is starship (installed by the machines core Brewfile) with
# starship.toml from this directory. An account can put an emoji in front of it
# by exporting ZSH_PROMPT_EMOJI before sourcing this file. Without starship it
# falls back to the geoffgarside theme.

# shellcheck shell=bash disable=SC2034,SC2154  # zsh: OMZ reads these; vcs_info sets vcs_info_msg_0_
# Terminal: keep the TERM the terminal set (Ghostty's xterm-ghostty) rather than
# forcing xterm-256color. Ghostty.app bundles its terminfo, so point ncurses at
# it on any host that has the app (the trailing ':' keeps the system default
# dirs). Where TERM still has no terminfo entry (an SSH session from Ghostty to
# a host without it, or tmux's tmux-256color on macOS), fall back to a generic
# entry so less/vim/tmux keep working.
_ghostty_terminfo=/Applications/Ghostty.app/Contents/Resources/terminfo
if [[ -d "$_ghostty_terminfo" && ":${TERMINFO_DIRS}:" != *":${_ghostty_terminfo}:"* ]]; then
  export TERMINFO_DIRS="${TERMINFO_DIRS:+${TERMINFO_DIRS}:}${_ghostty_terminfo}:"
fi
unset _ghostty_terminfo
if [[ -n "$TERM" && "$TERM" != xterm-256color ]] && command -v infocmp >/dev/null 2>&1 \
  && ! infocmp "$TERM" >/dev/null 2>&1; then
  if [[ -n "$TMUX" ]]; then export TERM=screen-256color; else export TERM=xterm-256color; fi
fi

export ZSH="$HOME/.oh-my-zsh"
# Outside $ZSH: chezmoi manages ~/.oh-my-zsh as an exact archive, so anything
# OMZ wrote inside it would be deleted on the next apply.
export ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
_zsh_base_starship=0
command -v starship >/dev/null 2>&1 && _zsh_base_starship=1
if (( _zsh_base_starship )); then
  ZSH_THEME=""
else
  ZSH_THEME="geoffgarside"
fi
export ZSH_DISABLE_COMPFIX=true  # skip insecure directory checks (faster)
# The provisioners own the version; OMZ's own updater would git-pull it off the
# pin (and prompts about it in every shell, SSH included, every 13 days).
zstyle ':omz:update' mode disabled

plugins=(
  git git-extras
  cp copypath copyfile extract
  npm docker docker-compose
  colored-man-pages  # estanli's man colours; harmless under buritica's MANPAGER=bat
)
[[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)
[[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions" ]] && plugins+=(zsh-autosuggestions)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "Warning: Oh My Zsh not found at $ZSH/oh-my-zsh.sh — falling back to a plain prompt"
  autoload -Uz vcs_info
  zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
  precmd() { vcs_info; }
  setopt PROMPT_SUBST
  PS1='%F{cyan}%m%f %F{blue}%1~%f${vcs_info_msg_0_} %# '
fi

if (( _zsh_base_starship )); then
  export STARSHIP_CONFIG="$HOME/.config/zsh-base/starship.toml"
  eval "$(starship init zsh)"
else
  PS1="${ZSH_PROMPT_EMOJI:+$ZSH_PROMPT_EMOJI }$PS1"
fi
unset _zsh_base_starship

# History, the same on every account. OMZ's lib/history.zsh sets most of these
# options already; they're repeated so the fallback branch above matches, and
# the sizes raise OMZ's 50000/10000 (HISTSIZE stays above SAVEHIST so
# HIST_EXPIRE_DUPS_FIRST has room to drop duplicates before unique entries).
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=120000
SAVEHIST=100000
HISTORY_IGNORE='(ls|cd|cd -|pwd|exit|date|* --help)'
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS HIST_VERIFY SHARE_HISTORY
