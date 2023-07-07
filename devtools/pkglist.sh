#!/usr/bin/env bash

declare -rx WORKSPACE="${HOME}/Workspace"
declare -rx PKGBUILDS="${WORKSPACE}/pkgrr/pkgbuilds"

declare -a package_list=$(fd . -t d --max-depth 1 $PKGBUILDS)



for pkg in ${package_list[@]}; do
  cd $pkg

  name=$(cat .SRCINFO | grep pkgbase | awk -F '=' '{ print $2 }' | xargs)
  url=$(cat .SRCINFO | grep -w url | awk -F '=' '{ print $2 }' | xargs)
  desc=$(cat .SRCINFO | grep pkgdesc | awk -F '=' '{ print $2 }' | xargs)
  ver=$(cat .SRCINFO | grep pkgver | awk -F '=' '{ print $2 }' | xargs)

  echo -e "| [$name]($url) | $desc | $ver |"

done
