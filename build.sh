#!/usr/bin/bash

# Move the contents of folder to WoW Addons location for testing
addon_path="/home/jg/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_retail_/Interface/AddOns"
beta_path="/home/jg/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_beta_/Interface/AddOns"
addon_name="AccountPlayed"
IS_BETA=true
beta_addon="$beta_path/$addon_name"
retail_addon="$addon_path/$addon_name"
addon=$([ "$IS_BETA" = true ] && echo "$beta_addon" || echo "$retail_addon")

files=("AccountPlayed.lua" "AccountPlayed.toc" "MinimapButton.lua")

# check if addon dir exists in WoW path.
if [[ ! -d "$addon" ]]; then
    mkdir -p "$addon"
fi

lazy_sync() {
    echo "Moving ${files[*]} -> $addon"
    if cp "${files[@]}" "$addon"; then
        ls -larth "$addon"
        printf "\n\nDone! /rl to see changes in game."
        exit 0
    else
        echo "error copying files to $addon.. check paths are correct"
        exit 1
    fi
}

lazy_rm() {
    read -rp "Delete $addon?? [y/N]: " choice
    case "$choice" in
        y|Y) rm -rf "$addon" ;;
        *) exit 0 ;;
    esac
}

# Git release flow
lazy_build() { 
  read -p "Create Tag for new build: " TAG
  read -p "Create Message for new build: " COMMENT
  git commit -am "Release: v$TAG - $COMMENT"
  git push
  git tag -a v$TAG -m "Release: v$TAG - $COMMENT"
  git push origin v$TAG
}


# Loop through all args and allow combinations 
# of multiple args when passed.
for arg in "$@"; do
  case "$arg" in
    s|-s|sync|--sync) lazy_sync;;
    b|-b|build|--build) lazy_build;;
    rm|remove|--rm|--remove) lazy_rm ;;
    *) echo "No arg passed default to sync" ;; 
  esac
done
# if nothing passed just sync.
if [[ $# -eq 0 ]]; then
  lazy_sync
fi
