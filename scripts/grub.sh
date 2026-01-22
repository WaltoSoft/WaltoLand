executeScript() {
  local grubScriptFile=/boot/grub/grub.cfg
  local grubConfigFile=/etc/default/grub
  local grubThemesFolder=/usr/share/grub/themes

  if $(isPackageInstalled grub) && [ -f $grubScriptFile ] ; then
    if [ ! -f "${grubConfigFile}.waltoland.bkp" ] && [ ! -f "${grubScriptFile}.waltoland.bkp" ]; then
      echoText -f "Grub"
      echoText "Configuring Grub"

      sudo cp $grubConfigFile "${grubConfigFile}.waltoland.bkp"
      sudo cp $grubScriptFile "${grubScriptFile}.waltoland.bkp"

      sudo ensureFolder $grubThemesFolder/arch-linux

      echoText "Setting grub theme to arch-linux"
      sudo tar -C $grubThemesFolder/arch-linux -xf $REPO_DIR/archives/grub/arch-linux.tar
      
      sudo sed -i "/^GRUB_DEFAULT=/c\GRUB_DEFAULT=saved
      /^GRUB_GFXMODE=/c\GRUB_GFXMODE=1920x1080
      /^GRUB_TERMINAL_OUTPUT=console/c\#GRUB_TERMINAL_OUTPUT=console
      /^GRUB_THEME=/c\GRUB_THEME=\"${grubThemesFolder}/arch-linux/theme.txt\"
      /^#GRUB_THEME=/c\GRUB_THEME=\"${grubThemesFolder}/arch-linux/theme.txt\"
      /^#GRUB_SAVEDEFAULT=true/c\GRUB_SAVEDEFAULT=true" $grubConfigFile

      echoText "Making the new grub script file"
      sudo grub-mkconfig -o $grubScriptFile

      echoText -c $COLOR_SUCCESS "Grub configuration complete!"
    fi
  fi
}

executeScript
