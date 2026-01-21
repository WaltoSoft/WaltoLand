executeScript() {
  echoText -f "bashrc"

  doit() {
    echoText "Backing up existing .bashrc scripts"
    cp $HOME_DIR/.bashrc $HOME_DIR/.bashrc.waltoland.bkp
    cp $HOME_DIR/.bashrc_custom $HOME_DIR/.bashrc_custom.waltoland.bkp

    echoText "Copying new bashrc configuration scripts"
    cp $REPO_DIR/dotfiles/.bashrc $HOME_DIR/.bashrc
    cp $REPO_DIR/dotfiles/.bashrc_custom $HOME_DIR/.bashrc_custom
  }

  if ! doit ; then
    echoText -c $COLOR_ERROR "ERROR: An error occured copying bashrc scripts"
    exit 1
  fi

  echoText -c $COLOR_SUCCESS "bashrc scripts successfully copied"
}

executeScript
