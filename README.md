# Dotfiles

My Mac settings, managed with [chezmoi](https://www.chezmoi.io/) so I can reuse
them across machines.

## What's included

- Git ignore patterns
- tmux shortcuts and appearance
- Helix editor and language server settings
- GitHub CLI preferences and aliases
- Zsh configuration and tool integrations

Configurations live in `home/`. Chezmoi turns names like `dot_tmux.conf` into
`~/.tmux.conf` and writes regular files to your home directory.

## Set up a Mac

With Homebrew installed:

```sh
brew install chezmoi
chezmoi init https://github.com/Bhavesh-Suvalaka/dotfiles.git
chezmoi diff
chezmoi apply
```

Install the apps and language servers separately. Sign in to GitHub CLI with
`gh auth login`; credentials stay outside this repo.

Zsh loads Oh My Zsh, Powerlevel10k, shell plugins and CLI integrations when
installed. Keep machine-specific settings in `~/.zshrc.local`. Supporting files
such as `~/.aliases`, `~/.p10k.zsh`, `~/.zsh/worktree.zsh` and `~/profiles/` are
loaded when present and need to be managed separately.

## Work from this checkout

Edit the files under `home/`, then run from the repository root:

```sh
chezmoi --source "$PWD" diff
chezmoi --source "$PWD" apply
```

Commit and push your changes. On another Mac initialized with chezmoi, run
`chezmoi update` to pull and apply them.
