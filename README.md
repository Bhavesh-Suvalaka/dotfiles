# Dotfiles

Mac settings and a Homebrew package list, managed with [chezmoi](https://www.chezmoi.io/). This repo makes it easier to set up the same tools and preferences on another Mac.

## What's here

- Zsh settings, shared aliases and Powerlevel10k prompt
- tmux and Zellij settings
- Helix settings
- mise tool versions
- Git and GitHub CLI preferences
- Homebrew tools and Mac apps in `Brewfile`

Chezmoi stores settings under `home/` and applies them to your home directory. For example, `home/dot_zshrc` becomes `~/.zshrc`. Machine-specific shell settings belong in `~/.zshrc.local`; keep credentials out of this repo.

## Set up a Mac

Install Apple's Command Line Tools and [Homebrew](https://brew.sh/), then run:

```sh
brew install chezmoi
chezmoi init https://github.com/Bhavesh-Suvalaka/dotfiles.git
chezmoi diff
chezmoi apply
brew bundle --file="$HOME/.local/share/chezmoi/Brewfile"
```

Review `chezmoi diff` before applying. The Brewfile installs the listed command-line tools and apps, including Node.js with npm, Maccy and Rectangle. Sign in to services such as GitHub separately. App Store and organization-managed apps need their usual installation process.

## Change settings

Edit a managed setting with chezmoi, then preview and apply it:

```sh
chezmoi edit ~/.zshrc
chezmoi diff
chezmoi apply
```

Add an existing file with `chezmoi add ~/.config/example/config`. Review changes, then commit and push them from chezmoi's source repository. On another Mac, run `chezmoi update` to pull and apply updates.

## Keep the Brewfile current

Edit `Brewfile` when you want to add or remove an app or tool. To compare it with the current Mac, create a separate Homebrew snapshot:

```sh
brew bundle dump --file=/tmp/Brewfile.snapshot --force
```

Review the snapshot and copy only the entries you still want into `Brewfile`, then commit and push. The snapshot may include dependencies and apps you don't want on every Mac.
