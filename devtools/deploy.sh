#!/usr/bin/env bash
set -e

declare -rx GPG="36A6ECD355DB42B296C0CEE2157CA2FC56ECC96A"

declare -rx MIRRORS=("bender.syncopated.net" "ec2-user@syncopated.hopto.org")

declare -rx PACKAGES="${HOME}/Packages"

declare -rx LOCAL_REPO="${HOME}/Repository"

phrase=$(gum input --password)

architectures=("x86_64" "x86_64_v3")

for arch in ${architectures[@]}; do

  if [[ $arch == 'x86_64' ]]; then
    declare -x repo_db="syncopated.db.tar.gz"
  elif [[ $arch == 'x86_64_v3' ]]; then
    declare -x repo_db="syncopated-v3.db.tar.gz"
  fi

  cd "${PACKAGES}/${arch}"

  echo "select package(s) to move into the repository"
  echo -e "press CTRL+C to select nothing\n"

  package_selection=$(fd . -e .zst -a ${PACKAGES}/${arch} -x echo -e {} | gum filter --no-limit --height 30)

  if [[ -z $package_selection ]]; then

    echo "package selection empty"
    exit

  else

    for pkg in ${package_selection[@]}; do
      mv -v $pkg "${LOCAL_REPO}/${arch}"
    done

    cd "${LOCAL_REPO}/${arch}" && echo -e "signing packages\n"

    for pkg in *.zst; do
      echo "${phrase}" | gpg2 -v --batch --yes --detach-sign --pinentry-mode loopback --passphrase --passphrase-fd 0 --out ${LOCAL_REPO}/${arch}/$pkg.sig --sign $pkg
    done

    echo "refreshing repository database" && repo-add -n -k $GPG $repo_db *.pkg.tar.zst -s
  fi

  for mirror in ${MIRRORS[@]}; do
    echo -e "syncing local repository to remote ${mirror}\n"
    rsync -avP --delete  "${LOCAL_REPO}/${arch}/" "${mirror}:/usr/share/nginx/html/packages/archlinux/${arch}/" || continue
  done

done
