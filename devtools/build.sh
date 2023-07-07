#!/usr/bin/env bash
set -e

declare -rx timestampe=$(date +%Y%m%d%H%M)

#########################################################################
#                             set colors                                 #
#########################################################################

declare -rx ALL_OFF="\e[1;0m"
declare -rx BBOLD="\e[1;1m"
declare -rx BLUE="${BBOLD}\e[1;34m"
declare -rx GREEN="${BBOLD}\e[1;32m"
declare -rx RED="${BBOLD}\e[1;31m"
declare -rx YELLOW="${BBOLD}\e[1;33m"

say () {
  local statement=$1
  local color=$2

  echo -e "${color}${statement}${ALL_OFF}"
}

#########################################################################
#                             set locations                             #
#########################################################################

declare -rx SRCDEST="${HOME}/Packages/sources"
declare -rx REPOSITORY_LOCAL="${HOME}/Repository"

declare -rx WORKSPACE="${HOME}/Workspace"
declare -rx PKGBUILDS="${WORKSPACE}/syncopated/pkgrr/pkgbuilds"

#########################################################################
#                             set functions                             #
#########################################################################

declare -rx CHROOT="/mnt/chroots/arch"

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
    arch-nspawn -C $pacman_conf -M $makepkg_conf $CHROOT/root pacman -Sy
}

build () {

  cd "${PKGBUILDS}/${pkgname}"

  makechrootpkg -n -c -r $CHROOT

  if [ $? = 0 ]; then
    ssh -T ninjabot notify-send "build\ complete\ for\ ${pkgname}-${arch}"
  fi
}

cleanup() {

  if [[ ! $DEBUG ]]; then
    rm -f "$HOME/.makepkg.conf"
    unmount_chroot
    rm -rf $SRCDEST && mkdir -p $SRCDEST
    rm -f "${HOME}/.makepkg.conf"
  fi

}

cd $WORKSPACE/syncopated/pkgrr && git fetch && git pull

unmount_chroot
#########################################################################
#                             Greetings                                 #
#########################################################################

gum style \
  --foreground 014 --border-foreground 024 --border double \
  --align center --width 50 --margin "1 2" --padding "2 4" \
  'Hello.' && sleep 1 && clear

#########################################################################

cd $PKGBUILDS

say "select packages to build" $GREEN
say "-------------------------" $GREEN

if [[ "${1}" == 'all' ]]; then
  package_selection=$(fd . -t d --max-depth=1 $PKGBUILDS -x echo -e {/})
elif [[ "${1}" == 'package' ]]; then
  package_selection=$2
else
  package_selection=$(fd . -t d --max-depth=1 $PKGBUILDS -x echo -e {/} | gum filter --no-limit )
fi

say "${package_selection}" $BLUE

#########################################################################

say "Select cpu architecture" $GREEN
say "------------------------" $GREEN

architectures=$(gum choose --no-limit all "x86_64" "x86_64_v3")

if [[ $architectures == 'all' ]]; then
  architectures=("x86_64" "x86_64_v3")
fi

#########################################################################
trap cleanup SIGINT SIGTERM ERR EXIT

if [[ ${3} == 'debug' ]]; then
  declare -rx DEBUG="True"
  say "Debug...\n" $RED
fi

for arch in ${architectures[@]}; do

  mkdir -pv $SRCDEST

  for name in ${package_selection[@]}; do

    pacman_conf="${WORKSPACE}/syncopated/pkgrr/devtools/pacman-${arch}.conf"
    makepkg_conf="${WORKSPACE}/syncopated/pkgrr/devtools/makepkg-${arch}.conf"

    say $pacman_conf $BLUE
    say $makepkg_conf $BLUE
    say "--------------------------\n" $GREEN

    mount_chroot
    create_chroot
    update_chroot

    declare -x pkgname=$name

    ssh -T ninjabot notify-send "starting\ build\ for\ ${pkgname}-${arch}"

    build $pkgname || if [[ ! $DEBUG ]]; then continue; else break; fi

  done

  if [ ! $? = 0 ]; then
    ssh -T ninjabot notify-send -u critical -t 290000 "build\ failed\ for\ ${pkgname}-${arch}"
    exit
  fi

done

gum confirm "deploy package(s) to repository?" && . deploy.sh

# end of program
