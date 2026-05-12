###########################################
# WoW Addon Development Justfile Template #
###########################################
# Description: 
#   - an attempt at an arbitrary addon justfile template 
#   - created to replace custom .sh scripts with a single justfile.
#   - set the variables at the top or on the fly with --set $var_name $foo
# Features:
#   - list, remove, sync, and run commen git commands for WoW addon projects
#   - integrated with bigwigs/packager for easy tagged releases
# Example:
#   - `just ls retail` - List all files in the addons folder for retail WoW 
#   - `just build 1.0.3 "New: some comment here"` - Runs git add, git commit, and git tag to trigger a CI release build.
#   - `just help` - print all available commands
# Author: Jeremy-Gstein - jeremy51b5@pm.me

###############################
# CONFIGURE PROJECT VARIABLES #
###############################
# Specify name of addon
addon_name := "AccountPlayed"

# DEFAULT PATHS - Set based on the OS family
os := os_family()

retail_path := if os == "unix" { 
  "/home/$USER/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_retail_/Interface/AddOns" 
} else { 
  "C:\\Program Files (x86)\\World of Warcraft\\_retail_\\Interface\\AddOns" 
}

beta_path := if os == "unix" { 
  "/home/$USER/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_beta_/Interface/AddOns" 
} else { 
  "C:\\Program Files (x86)\\World of Warcraft\\_beta_\\Interface\\AddOns" 
}

classic_path := if os == "unix" { 
  "/home/$USER/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_classic_era_/Interface/AddOns" 
} else { 
  "C:\\Program Files (x86)\\World of Warcraft\\_classic_era_\\Interface\\AddOns" 
}

# ADDON FILES (.lua .toc etc..)
files := "*.lua *.toc Libs/ *.blp"

# just list available commands B)
_default:
  @just --list

# sync local dir with beta path
sync-beta:
  @just sync beta

# sync local dir with retail path
sync-retail:
  @just sync retail

# sync local dir with classic_era path
sync-classic:
  @just sync classic

sync-all:
  @just sync-retail
  @just sync-beta
  @just sync classic

# sync local files with addon dir
# usage: just sync beta | just sync retail

sync target:
  mkdir -p "{{ if target == 'beta' { beta_path } else if target == 'classic' { classic_path } else { retail_path } }}/{{ addon_name }}"
  cp -r {{ files }} "{{ if target == 'beta' { beta_path } else if target == 'classic' { classic_path } else { retail_path } }}/{{ addon_name }}"
  ls -larth "{{ if target == 'beta' { beta_path } else if target == 'classic' { classic_path } else { retail_path } }}/{{ addon_name }}"
  @echo "Done! /rl to see changes in game."

# remove beta addon (keeps local files)
rm-beta:
  @just rm beta

# remove retail addon (keeps local files)
rm-retail:
  @just rm retail

# remove classic addon (keeps local files)
rm-classic:
  @just rm classic

rm target:
  rm -rf "{{ if target == "beta" { 
    beta_path 
  } else if target == "classic" { 
    classic_path 
  } else { 
    retail_path 
  } }}/{{ addon_name }}"

# list beta dir with changes 
ls-beta:
  @just ls beta

# list retail dir with changes 
ls-retail:
  @just ls retail

# list classic dir with changes 
ls-classic:
  @just ls classic

# list _path showing recent changes
ls target:
  ls -larth "{{ if target == "beta" { beta_path } else if target == "classic" { classic_path } else { retail_path } }}/{{ addon_name }}"

# git ci for bigwigs/packager (gh action)
# example: just build 1.0.0 "some message here"
build tag message:
  git commit -am "Release: v{{tag}} - {{message}}"
  git push
  git tag -a "v{{tag}}" -m "Release: v{{tag}} - {{message}}"
  git push origin "v{{tag}}"

# fetch and pull latest git repo changes 
update:
  git fetch
  git pull
  git status

# get sha256sum of beta, retail, and local repo files
checksum: 
  @echo -e "\nRETAIL FILES:"
  for f in {{files}}; do sha256sum "{{retail_path}}/{{addon_name}}/$f"; done 
  @echo -e "\nBETA FILES:"
  for f in {{files}}; do sha256sum "{{beta_path}}/{{addon_name}}/$f"; done
  @echo -e "\nREPO FILES:"
  for f in {{files}}; do sha256sum "$PWD/$f"; done
  
# check the set vaules for beta and retail paths
debug:
  @echo -e "Debug Info for:\n\t[{{addon_name}}]\nGenerated at:\n\t{{datetime("[%m/%d/%y]-[%H:%M]")}}-{{uuid()}}"
  @echo -e "OS:\n\t[{{os_family()}}/{{os()}}-{{arch()}}]-[{{num_cpus()}}(cores)]"
  @echo "Paths:"
  @echo -e "\tRetail:{{retail_path}}/{{addon_name}}"
  @echo -e "\tBeta: {{beta_path}}/{{addon_name}}"
  @just checksum
