#!/usr/bin/env bash
# setup-zsh.sh — install zsh, Oh My Zsh, Powerlevel10k, and common plugins
set -euo pipefail

msg()  { printf '\n\e[1;34m==> \e[0m%s\n' "$*"; }
die()  { printf '\e[1;31mERROR:\e[0m %s\n' "$*" >&2; exit 1; }

ROOT="$(cd "$(dirname "$0")" && pwd)"
OMZ_DIR="$HOME/.oh-my-zsh"
CUSTOM="${ZSH_CUSTOM:-$OMZ_DIR/custom}"

# Install zsh
if ! command -v zsh &>/dev/null; then
  msg "Installing zsh..."
  sudo pacman -S --needed zsh
fi

# Install Oh My Zsh (unattended, no chsh)
if [[ ! -d "$OMZ_DIR" ]]; then
  msg "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  msg "Oh My Zsh already installed at $OMZ_DIR"
fi

# Powerlevel10k theme
P10K_DIR="$CUSTOM/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  msg "Cloning Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  msg "Powerlevel10k already present"
fi

# zsh-autosuggestions
AUTOSUG_DIR="$CUSTOM/plugins/zsh-autosuggestions"
if [[ ! -d "$AUTOSUG_DIR" ]]; then
  msg "Cloning zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUG_DIR"
else
  msg "zsh-autosuggestions already present"
fi

# zsh-syntax-highlighting
SYNTHIGH_DIR="$CUSTOM/plugins/zsh-syntax-highlighting"
if [[ ! -d "$SYNTHIGH_DIR" ]]; then
  msg "Cloning zsh-syntax-highlighting..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$SYNTHIGH_DIR"
else
  msg "zsh-syntax-highlighting already present"
fi

# Link zshrc
ZSHRC_SRC="$ROOT/zshrc"
ZSHRC_DST="$HOME/.zshrc"
if [[ "$(realpath -m "$ZSHRC_SRC")" != "$(realpath -m "$ZSHRC_DST" 2>/dev/null)" ]]; then
  [[ -e "$ZSHRC_DST" || -L "$ZSHRC_DST" ]] && mv "$ZSHRC_DST" "$ZSHRC_DST.bak" && echo "Backed up $ZSHRC_DST"
  ln -s "$ZSHRC_SRC" "$ZSHRC_DST"
  msg "Linked ~/.zshrc -> $ZSHRC_SRC"
else
  msg "~/.zshrc already linked"
fi

# Set zsh as default shell
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  msg "Setting zsh as default shell..."
  chsh -s "$(command -v zsh)"
fi

msg "Done. Open a new terminal — p10k will run its config wizard on first launch."
