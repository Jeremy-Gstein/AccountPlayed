# DEFAULT PATHS 
retail_path := "/home/jg/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_retail_/Interface/AddOns"
beta_path := "/home/jg/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_beta_/Interface/AddOns"
# ADDON METADATA
addon_name := "AccountPlayed"
# ADDON FILES (.lua .toc etc..)
files := "AccountPlayed.lua MinimapButton.lua AccountPlayed.toc"

# just list available commands B)
_default:
  @just --list

# sync local dir with beta path
sync-beta:
  @just _sync beta

# sync local dir with retail path
sync-retail:
  @just _sync retail

sync target:
  mkdir -p "{{ if target == "beta" { beta_path } else { retail_path } }}/{{ addon_name }}"
  cp {{ files }} "{{ if target == "beta" { beta_path } else { retail_path } }}/{{ addon_name }}"
  ls -larth "{{ if target == "beta" { beta_path } else { retail_path } }}/{{ addon_name }}"
  @echo "Done! /rl to see changes in game."

# remove beta addon (keeps local files)
rm-beta:
  @just _rm beta

# remove retail addon (keeps local files)
rm-retail:
  @just _rm retail

rm target:
  rm -rf "{{ if target == "beta" { beta_path } else { retail_path } }}/{{ addon_name }}"

# list beta dir with changes 
ls-beta:
  @just _ls beta

# list retail dir with changes 
ls-retail:
  @just _ls retail

# list _path showing recent changes.
ls target:
  ls -larth "{{ if target == "beta" { beta_path } else { retail_path } }}/{{ addon_name }}"

# git ci for packager
# example: just build 1.0.0 "some message here"
build tag message:
  git commit -am "Release: v{{tag}} - {{message}}"
  git push
  git tag -a "v{{tag}}" -m "Release: v{{tag}} - {{message}}"
  git push origin "v{{tag}}"

# push to repo without tagging commit (skip packager)
commit message:
  git add .
  git commit -am "{{message}}"
  git push

# check the set vaules for beta and retail paths.
debug:
  @echo "OS: [{{os()}}-{{arch()}}]-[{{num_cpus()}}(cores)]"
  @echo "Retail:{{retail_path}}/{{addon_name}}"
  @echo "Beta: {{beta_path}}/{{addon_name}}"

alias dbg := debug
