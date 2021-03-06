#!/bin/bash
#
# Installer script for ATVFiles @VERSION@ via Makeself.

SRCDIR="$PWD"
COMMAND="${1:-install}"
PREFIX="${2:-}"
ATVFILES_DEST="${PREFIX}/System/Library/CoreServices/Finder.app/Contents/PlugIns"
ATVFILES_NAME="ATVFiles.frappliance"
ARCHIVE_NAME="@ARCHIVE_NAME@"

die() {
  echo $*
  exit 1
}

# make sure we're running as root, if not relaunch us
if [ "$USER" != "root" ]; then
  echo "This installer must be run as root."
  echo
  echo "Please enter your password below to authorize as root."
  echo "In most cases, this password is \"frontrow\"."
  sudo "$0" $*
  exit 0
fi

REMOUNT=0

# Check if / is mounted read only
if mount | grep ' on / '  | grep -q 'read-only'; then
  REMOUNT=1
  /sbin/mount -uw /
fi

if [ "$COMMAND" = "uninstall" ]; then
  echo "== Removing ATVFiles"
  /bin/rm -rf "$ATVFILES_DEST/$ATVFILES_NAME" || die "Unable to uninstall ATVFiles"

  echo "ATVFiles successfully uninstalled."
  echo
  echo "Finder must be restarted in order to complete the installation."
elif [ "$COMMAND" = "help" ]; then
  echo "Usage: $0 [action] [prefix]"
  echo
  echo "Install ATVFiles @VERSION@, optionally to a prefix"
  echo
  echo "Where action is:"
  echo "  install       Install ATVFiles"
  echo "  uninstall     Uninstall ATVFiles"
  echo
  echo "prefix is the root to a mounted install.  If specified, install will be automated"
  echo "and will not restart Finder."
elif [ "$COMMAND" = "install" ]; then
  
  # move atvfiles existing out of way
  if [ -d "$ATVFILES_DEST/$ATVFILES_NAME" ]; then
    echo "== Removing old ATVFiles"
    /bin/rm -rf "$ATVFILES_DEST/$ATVFILES_NAME" || die "Unable to remove old ATVFiles"
  fi

  echo "== Extracting ATVFiles"
  /usr/bin/ditto -k -x --rsrc "$SRCDIR/@ARCHIVE_NAME@" "$ATVFILES_DEST" || die "Unable to install ATVFiles"
  /usr/sbin/chown -R root:wheel "$ATVFILES_DEST/$ATVFILES_NAME"
  /bin/chmod -R 755 "$ATVFILES_DEST/$ATVFILES_NAME"
  
  echo "ATVFiles successfully installed."
  echo

  # Prompt to restart finder
  if [ "$PREFIX" = "" ]; then
    echo "Finder must be restarted in order to complete the installation."
    echo
    echo -n "Would you like to do this now? (Y/n) "
    read -e restartfinder
    if [[ "$restartfinder" == "" || "$restartfinder" == "Y" || "$restartfinder" == "y" ]]; then
      echo
      echo "== Restarting Finder"

      kill `ps awx | grep [F]inder | awk '{print $1}'`
    fi
  fi # prefix empty
fi

# remount root as we found it
if [ "$REMOUNT" = "1" ]; then
  /sbin/mount -ur /
fi

