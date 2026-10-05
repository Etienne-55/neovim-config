# Quick setup for a new mac

## On the new machine

```bash
git clone <this-repo> ~/.config/nvim
~/.config/nvim/setup/bootstrap.sh
```

That's it. The script asks for your password once (Homebrew) and takes a while on
the `brew bundle` step.

## What the script does

1. Installs the Xcode command line tools and Homebrew if they're missing.
2. Installs everything in `Brewfile` (9 formulas, 3 casks) — just what neovim
   and wezterm need: neovim, git, lazygit, ripgrep, fd, eza, node, go,
   tree-sitter, the nerd fonts and wezterm.
3. Symlinks the dotfiles in `dotfiles/` into your home folder, backing up
   anything already there into `~/.dotfiles-backup/<date>/`.
4. Installs tmux's plugin manager and your tmux plugins.
5. Installs the neovim plugins, language servers and formatters.

Because the dotfiles are **symlinks**, editing `~/.zshrc` edits the copy in this
repo — commit it and the next machine gets it.

## Files

| File | Goes to |
|---|---|
| `dotfiles/zshrc` | `~/.zshrc` |
| `dotfiles/p10k.zsh` | `~/.p10k.zsh` (powerlevel10k prompt) |
| `dotfiles/tmux.conf` | `~/.tmux.conf` |
| `dotfiles/wezterm.lua` | `~/.wezterm.lua` |
| `dotfiles/gitconfig` | `~/.gitconfig` |
| `dotfiles/tmux-cht.sh` | `~/.tmux-cht.sh` (prefix + i cheat sheet) |
| `dotfiles/claude-settings.json` | `~/.claude/settings.json` (Claude Code settings, including the sounds it plays when it's done) |
| `gaufre/gaufre` | stays here; `~/.tmux.conf` opens it in a popup with prefix + e (apple silicon build) |
| `hex/hex` | stays here; `~/.tmux.conf` opens it in a popup with prefix + Space — a cheat sheet of every binding in this config, read live from it (source next to it, apple silicon build) |


