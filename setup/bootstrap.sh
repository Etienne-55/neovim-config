#!/usr/bin/env bash
# Set up a new mac: homebrew packages, dotfiles, tmux plugins, neovim.
# Safe to run more than once - existing files are backed up, nothing is deleted.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES="$REPO_DIR/setup/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !!\033[0m %s\n' "$*"; }

[ "$(uname -s)" = "Darwin" ] || { echo "This script is for macOS."; exit 1; }

# ---------------------------------------------------------------- xcode tools
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing the Xcode command line tools (compilers, git)"
  xcode-select --install || true
  echo "Accept the dialog, wait for it to finish, then run this script again."
  exit 1
fi

# ------------------------------------------------------------------ homebrew
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew (this asks for your password)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

log "Installing everything in setup/Brewfile (this is the long part)"
brew bundle --file="$REPO_DIR/setup/Brewfile"

# ------------------------------------------------------------------ dotfiles
# symlinked, so editing ~/.zshrc edits the file in this repo
link() {
  src="$DOTFILES/$1"
  dest="$2"
  [ -e "$src" ] || { warn "missing in repo: $1"; return; }
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    log "already linked: $dest"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
    warn "moved your existing $dest into $BACKUP_DIR"
  fi
  ln -s "$src" "$dest"
  log "linked $dest"
}

log "Linking dotfiles"
link zshrc       "$HOME/.zshrc"
link p10k.zsh    "$HOME/.p10k.zsh"
link tmux.conf   "$HOME/.tmux.conf"
link wezterm.lua "$HOME/.wezterm.lua"
link gitconfig   "$HOME/.gitconfig"
link tmux-cht.sh "$HOME/.tmux-cht.sh"
link tmux-cht-languages "$HOME/.tmux-cht-languages"
link tmux-cht-command   "$HOME/.tmux-cht-command"
# real dir (not a symlink into this repo) so claude doesn't think it's in a git project
mkdir -p "$HOME/.claude-chat"
link claude-chat.md "$HOME/.claude-chat/CLAUDE.md"

# --------------------------------------------------------------------- tmux
TPM="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM" ]; then
  log "Installing tmux plugin manager"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM"
fi
log "Installing tmux plugins"
"$TPM/bin/install_plugins" || warn "could not install tmux plugins - open tmux and press prefix + I"

# ------------------------------------------------------------------ neovim
if [ "$REPO_DIR" != "$HOME/.config/nvim" ]; then
  warn "This repo is at $REPO_DIR but neovim reads ~/.config/nvim - clone it there instead."
else
  log "Installing neovim plugins"
  nvim --headless "+Lazy! sync" +qa

  log "Installing language servers and formatters (a few minutes)"
  nvim --headless \
    -c 'autocmd User MasonToolsUpdateCompleted quitall' \
    -c 'lua vim.defer_fn(function() vim.cmd("cquit 1") end, 300000)' \
    -c 'MasonToolsInstall' || warn "run :Mason inside neovim to check"
fi

# -------------------------------------------------------------------- done
cat <<'EOF'

Done. Still to do by hand:

  1. Restart your terminal (or: exec zsh) so the new shell config loads.
  2. WezTerm: set the font to MesloLGS NF in the terminal's settings if icons look wrong.
  3. GitHub: create an ssh key and add it to your account
       ssh-keygen -t ed25519 -C "your@email"
       cat ~/.ssh/id_ed25519.pub
  4. Claude Code, if you want it:
       curl -fsSL https://claude.ai/install.sh | bash
       then add to ~/.zshrc: export PATH="$HOME/.local/bin:$PATH"
  5. Open neovim once and let treesitter finish installing parsers.

Optional, makes vim navigation much nicer (needs a logout to take effect):
  defaults write -g KeyRepeat -int 2
  defaults write -g InitialKeyRepeat -int 15
  defaults write -g ApplePressAndHoldEnabled -bool false

EOF
