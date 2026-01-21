executeScript() {
  echoText -f "Dot files"
  echoText "Copying Hyperland Dot files"

  doit() {
    sudo rsync -avhp -I $REPO_DIR/dotfiles/ /home/billy
  }

  if ! doit ; then
    echoText -c $COLOR_ERROR "ERROR: An error occured copying Dot files"
    exit 1
  fi

  echoText -c $COLOR_SUCCESS "Dot files successfully copied"
}

executeScript
