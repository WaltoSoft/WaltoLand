executeScript() {
  echoText -f "Gnome Settings"
  echoText "Finalizing Gnome Settings"

  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
}

executeScript