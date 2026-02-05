create-branch-from-main() {
  if [[ -z "$1" ]]; then
    echo "Usage: create-branch-from-main <branch-name>"
    return 1
  fi

  # Only fetch the 'main' branch from origin
  echo "Fetching 'main' branch from origin..."
  git fetch origin main
  
  echo "Creating new branch '$1' from 'main'..."
  git checkout --no-track -b "$1" origin/main
}