executeScript() {
  set -e

  SCRIPT_DIR=$(dirname "$(realpath "$0")")
  source $SCRIPT_DIR/library.sh
  source $SCRIPT_DIR/start.sh
  source $SCRIPT_DIR/packageInstall.sh
  source $SCRIPT_DIR/dotfiles.sh
  source $SCRIPT_DIR/bashrc.sh
  source $SCRIPT_DIR/services.sh
  source $SCRIPT_DIR/grub.sh
  source $SCRIPT_DIR/gnome.sh
  source $SCRIPT_DIR/git.sh

  echoText "Installing WaltoLand desktop file as an option for launching a wayland session"
  sudo cp $SCRIPT_DIR/waltoland.desktop /usr/share/wayland-sessions/waltoland.desktop

  source $SCRIPT_DIR/reboot.sh
  echoText -c $COLOR_SUCCESS "Installation complete!"
}

HOME_DIR=$1
executeScript
