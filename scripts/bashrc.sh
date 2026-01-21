executeScript() {
  echoText -f "bashrc"

  doit() {
    echoText "Backing up existing .bashrc scripts"
    cp $HOME_DIR/.bashrc $HOME_DIR/.bashrc.bkp
    cp $HOME_DIR/.bashrc_waltoland $HOME_DIR/.bashrc_waltoland.bkp

    echoText "Copying new bashrc configuration scripts"
    cp $REPO_DIR/dotfiles/.bashrc $HOME_DIR/.bashrc
    cp $REPO_DIR/dotfiles/.bashrc_waltoland $HOME_DIR/.bashrc_waltoland
  }

  if ! doit ; then
    echoText -c $COLOR_ERROR "ERROR: An error occured copying bashrc scripts"
    exit 1
  fi

  echoText -c $COLOR_SUCCESS "bashrc scripts successfully copied"
}

executeScript
