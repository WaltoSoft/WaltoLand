executeScript() {
  echoText -f "GIT Settings"

  echoText "Configuring GIT global settings"
  git config --global user.email "waltosoft@gmail.com"
  git config --global user.name "WaltoSoft"

  echoText "Generating SSH Key"
  ssh-keygen -t ed25519 -C "waltosoft@gmail.com"
}

executeScript
