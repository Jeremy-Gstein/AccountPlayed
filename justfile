###########################################
# WoW Addon Development Justfile Template #
###########################################
# Description: 
#   - an attempt at an arbitrary addon justfile template 
#   - created to replace custom .sh scripts with a single justfile.
#   - set the variables at the top or on the fly with --set $var_name $foo
# Author: Jeremy-Gstein

###############################
# CONFIGURE PROJECT VARIABLES #
###############################
# Specify name of addon
addon_name := "AccountPlayed"
# DEFAULT PATHS 
retail_path := "/home/jg/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_retail_/Interface/AddOns"
beta_path := "/home/jg/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_beta_/Interface/AddOns"
# ADDON FILES (.lua .toc etc..)
files := "AccountPlayed.lua MinimapButton.lua AccountPlayed.toc"

# just list available commands B)
_default:
  @just --list

# sync local dir with beta path
sync-beta:
  @just sync beta

# sync local dir with retail path
sync-retail:
  @just sync retail

sync-all:
  @just sync-retail
  @just sync-beta

# sync local files with addon dir
# usage: just sync beta | just sync retail
sync target:
  mkdir -p "{{ if target == "beta" { beta_path } else { retail_path } }}/{{ addon_name }}"
  cp {{ files }} "{{ if target == "beta" { beta_path } else { retail_path } }}/{{ addon_name }}"
  ls -larth "{{ if target == "beta" { beta_path } else { retail_path } }}/{{ addon_name }}"
  @echo "Done! /rl to see changes in game."

# remove beta addon (keeps local files)
rm-beta:
  @just rm beta

# remove retail addon (keeps local files)
rm-retail:
  @just rm retail

rm target:
  rm -rf "{{ if target == "beta" { beta_path } else { retail_path } }}/{{ addon_name }}"

# list beta dir with changes 
ls-beta:
  @just ls beta

# list retail dir with changes 
ls-retail:
  @just ls retail

# list _path showing recent changes
ls target:
  ls -larth "{{ if target == "beta" { beta_path } else { retail_path } }}/{{ addon_name }}"

# git ci for packager
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
