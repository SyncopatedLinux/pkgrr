#!/usr/bin/env bash
set -e

declare -rx PACKAGES="${HOME}/Packages"
declare -rx REPOSITORY_LOCAL="${HOME}/Repository"

declare -rx WORKSPACE="${HOME}/Workspace"
declare -rx PKGBUILDS="${WORKSPACE}/pkgrr/pkgbuilds"

declare -rx AUTOBUILD="${WORKSPACE}/syncopated/pkgrr/devtools/autobuild.sh"

file_removed() {
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: $2 was removed from $1" >> monitor_log
}

file_modified() {
    local PKGDIR=$1
    local PKGNAME=$(basename $PKGDIR)

    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: The file $1$2 was modified" >> monitor_log

    if [[ $FILE == 'PKGBUILD' ]]; then
      $AUTOBUILD $PKGDIR
    fi

}

file_created() {
    TIMESTAMP=`date`
    echo "[$TIMESTAMP]: The file $1$2 was created" >> monitor_log
}

if [ ! -f $HOME/monitor_log ]; then
  touch $HOME/monitor_log
else
  cat /dev/null > $PKGBUILDS/monitor_log
fi

inotifywait --include "PKGBUILD" -q -m -r -e modify,delete,create $1 | while read DIRECTORY EVENT FILE; do
    case $EVENT in
        MODIFY*)
            file_modified "$DIRECTORY" "$FILE"
            ;;
        CREATE*)
            file_created "$DIRECTORY" "$FILE"
            ;;
        DELETE*)
            file_removed "$DIRECTORY" "$FILE"
            ;;
    esac
done
