# omz.zsh — shared zsh base: Oh My Zsh with the theme and plugin set every
# account uses. Each account's .zshrc sources this, then layers its own config.
# Oh My Zsh and the two community plugins are installed by the account's
# provisioner (chezmoi's .chezmoiexternal.toml for buritica, the estanli
# collection's dotfiles role for estanli); missing pieces degrade, never break.

# shellcheck shell=bash disable=SC2034,SC2154  # zsh: OMZ reads these; vcs_info sets vcs_info_msg_0_
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="geoffgarside"
export ZSH_DISABLE_COMPFIX=true  # skip insecure directory checks (faster)

plugins=(
  git git-extras
  cp copypath copyfile extract
  npm docker docker-compose
  colored-man-pages
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
