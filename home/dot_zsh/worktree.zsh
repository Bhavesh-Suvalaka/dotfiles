# Git worktree helpers. Each feature gets a sibling folder: <repo>__<branch with / as __>.
# Sourced from ~/.zshrc. They are functions, not scripts, because they must cd.

# Create a worktree off the freshly fetched main branch, then cd into it
wt-new() {
  local branch=$1
  if [ -z "$branch" ]; then
    echo "Usage: wt-new <branch-name>"
    return 1
  fi

  local root
  root="$(git rev-parse --show-toplevel)" || return 1
  local repo="${root:t}"
  local wt_path="${root:h}/${repo}__${branch//\//__}"

  # start from the repo's main branch, freshly fetched
  local base
  for b in main master; do
    git show-ref --verify --quiet "refs/heads/$b" && base=$b && break
  done
  if [ -z "$base" ]; then
    echo "wt-new: no main or master branch found"
    return 1
  fi
  git fetch origin "$base" --quiet

  git worktree add "$wt_path" -b "$branch" "origin/$base" || return 1

  if [[ -f "$root/.idea/gradle.xml" ]]; then
    mkdir -p "$wt_path/.idea"
    cp "$root/.idea/gradle.xml" "$wt_path/.idea/gradle.xml"
    echo "Copied .idea/gradle.xml to worktree"
  fi

  echo "Worktree created at: $wt_path"
  cd "$wt_path"
}

# Checkout a PR branch into a sibling worktree, then cd into it
wt-pr() {
  local pr=$1
  if [ -z "$pr" ]; then
    echo "Usage: wt-pr <pr-number>"
    return 1
  fi

  local root
  root="$(git rev-parse --show-toplevel)" || return 1
  local repo="${root:t}"

  local branch
  branch="$(gh pr view "$pr" --json headRefName -q '.headRefName')" || return 1
  if [ -z "$branch" ]; then
    echo "wt-pr: could not resolve a branch for PR #$pr"
    return 1
  fi

  local wt_path="${root:h}/${repo}__${branch//\//__}"

  git fetch origin "$branch" --quiet

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$wt_path" "$branch" || return 1
  else
    git worktree add "$wt_path" -b "$branch" "origin/$branch" || return 1
  fi

  if [[ -f "$root/.idea/gradle.xml" ]]; then
    mkdir -p "$wt_path/.idea"
    cp "$root/.idea/gradle.xml" "$wt_path/.idea/gradle.xml"
    echo "Copied .idea/gradle.xml to worktree"
  fi

  echo "Worktree created at: $wt_path (PR #$pr → $branch)"
  cd "$wt_path"
}

# List all worktrees
alias wt-ls='git worktree list'

# Remove a worktree by branch name. Its Claude history is archived, not deleted.
wt-rm() {
  local branch=$1
  if [ -z "$branch" ]; then
    echo "Usage: wt-rm <branch-name>"
    return 1
  fi

  local root
  root="$(git rev-parse --show-toplevel)" || return 1
  local repo="${root:t}"
  local wt_path="${root:h}/${repo}__${branch//\//__}"

  if [[ "$PWD" == "$wt_path"* ]]; then
    echo "wt-rm: you are inside $wt_path — cd out first"
    return 1
  fi
  if ! git worktree list --porcelain | grep -qx "worktree $wt_path"; then
    echo "wt-rm: $wt_path is not a worktree of this repo"
    return 1
  fi

  git worktree remove "$wt_path" || {
    echo "wt-rm: worktree has uncommitted changes."
    echo "       Inspect it, or re-run with: git worktree remove --force '$wt_path'"
    return 1
  }

  # Claude names a history folder after the path: every char except A-Z a-z 0-9 - becomes "-".
  local history="$HOME/.claude/projects/${wt_path//[^A-Za-z0-9-]/-}"
  if [ -d "$history" ]; then
    mkdir -p "$HOME/.claude/archive"
    mv "$history" "$HOME/.claude/archive/${wt_path:t}" \
      && echo "Claude history archived: ~/.claude/archive/${wt_path:t}"
  fi

  git worktree prune
  git branch -d "$branch" 2>/dev/null || {
    echo "Branch '$branch' has unmerged commits — kept."
    echo "Delete it with: git branch -D '$branch'"
  }

  echo "Worktree removed: $wt_path"
}

# cd into a sibling worktree
wt-cd() {
  local branch=$1
  if [ -z "$branch" ]; then
    echo "Usage: wt-cd <branch-name>"
    return 1
  fi

  local root
  root="$(git rev-parse --show-toplevel)" || return 1
  local repo="${root:t}"
  local wt_path="${root:h}/${repo}__${branch//\//__}"

  if [[ ! -d "$wt_path" ]]; then
    echo "wt-cd: no worktree at $wt_path"
    git worktree list
    return 1
  fi

  cd "$wt_path"
}
