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
2. Installs everything in `Brewfile` (50 formulas, 7 casks) — neovim, tmux,
   lazygit, lazydocker, ripgrep, fzf, bat, eza, zoxide, yazi, delta, node, go,
   java, tree-sitter, the zsh plugins, the nerd fonts, wezterm, obsidian…
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

## Keeping it up to date

After installing something new with brew:

```bash
~/.config/nvim/setup/update-brewfile.sh
```

Then commit the changed `Brewfile`.

## Not handled by the script

- **ssh keys** — generate a new one and add it to GitHub; keys should never live
  in a repo.
- **Apps not from Homebrew** — your `.zshrc` adds Wireshark to the
  PATH, and it is not in the Brewfile. Install it by hand, or add it
  (`brew install --cask wireshark`) and re-run `update-brewfile.sh`.
- **Anything in the login keychain**, including git credentials. Your gitconfig
  uses `osxkeychain`, so you'll log in to GitHub again on the new machine.
- **Obsidian vault** — the app gets installed, the notes don't.
