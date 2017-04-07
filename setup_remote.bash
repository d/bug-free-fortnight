#!/bin/bash

set -e -u -o pipefail

main() {
  local curpath
  local user
  curpath=$1
  shift

  user=$(whoami)

  git config --global receive.denyCurrentBranch updateInstead

  sudo mkdir -p "$curpath"
  sudo chown -R "$user" "$curpath"

  for repo in $@; do
    repopath="$curpath/$repo"
    if [[ ! -e "$repopath" ]]; then
        mkdir -p "$repopath"
        git init "$repopath"
      echo "Created directory on remote at $repopath."
    else
      echo "Directory already exists on remote at $repopath."
    fi
  done
}

main "$@"
