#!/usr/bin/env bash
set -e

declare -rx timestampe=$(date +%Y%m%d%H%M)

declare -rx PACKAGES="${HOME}/Packages"
declare -rx SRCDEST="${PACKAGES}/sources"

declare -rx REPOSITORY_LOCAL="${HOME}/Repository"

declare -rx WORKSPACE="${HOME}/Workspace"
declare -rx PKGBUILDS="${WORKSPACE}/pkgrr/pkgbuilds"

declare -rx CHROOT="/mnt/chroots/arch"

declare -x PKGDIR=$1
declare -x pkgname=$(basename $PKGDIR)

#######################################
#           set functions             #
#######################################

unmount_chroot() {
  if mountpoint -q $CHROOT; then sudo umount $CHROOT; fi
}

mount_chroot() {
  unmount_chroot
  sudo mount --mkdir -t tmpfs -o defaults,size=8G tmpfs $CHROOT
}

set_configs () {
  if [ -L "${HOME}/.makepkg.conf" ]; then
    ln -sf $makepkg_conf $HOME/.makepkg.conf
  else
    rm -f $HOME/.makepkg.conf || exit
    ln -s $makepkg_conf $HOME/.makepkg.conf
  fi
}

create_chroot() {
  set_configs
  mkarchroot -C $pacman_conf -M $makepkg_conf $CHROOT/root base-devel
}

update_chroot() {
    arch-nspawn -C $pacman_conf -M $makepkg_conf $CHROOT/root pacman -Scc --noconfirm
    arch-nspawn -C $pacman_conf -M $makepkg_conf $CHROOT/root pacman -Syu
}

build () {
  cd $PKGDIR
  makechrootpkg -n -c -r $CHROOT
}

cleanup() {
	unmount_chroot
  rm -rf $SRCDEST && mkdir -p $SRCDEST
  rm -f $HOME/.makepkg.conf
}

#######################################
#                                     #
#######################################
trap cleanup SIGINT SIGTERM ERR EXIT

architectures=("x86_64" "x86_64_v3")

for arch in ${architectures[@]}; do

  mkdir -pv $SRCDEST

  declare -x pacman_conf="${WORKSPACE}/syncopated/pkgrr/devtools/pacman-${arch}.conf"
  declare -x makepkg_conf="${WORKSPACE}/syncopatd/pkgrr/devtools/makepkg-${arch}.conf"

  mount_chroot
  create_chroot
  update_chroot

  ssh -T ninjabot notify-send "starting\ build\ for\ ${pkgname}-${arch}"

  build || exit

  if [ ! $? = 0 ]; then
    ssh -T ninjabot notify-send -u critical -t 290000 "build\ failed\ for\ ${pkgname}-${arch}"
  else
    ssh -T ninjabot notify-send "build\ complete\ for\ ${pkgname}-${arch}"
  fi

  sleep 1

done

# end of program
