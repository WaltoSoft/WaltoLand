CORE_PACKAGE_LIST=(
  "hyprland"
)

PACKAGE_LIST=(
  "base-devel"                   #Tools for development
  "blueman"                      #GUI for bluetooth
  "bluez"                        #Provides bluetooth protocol stack
  "bluez-utils"                  #Provides the bluetooth utility"
  "dunst"                        #Notification Daemon
  "fastfetch"                    #Pretty display in terminal window
  "gdm"                          #Dispaly manager, provides login screen
  "git"                          #git source control
  "gtk4-layer-shell"             #Needed for Hyprland gtk4 integration, also used in system panel
  "gnome-text-editor"            #Gnome Text Editor
  "jq"                           #
  "kitty"                        #kitty terminal window
  "man-db"                       #Man pages
  "microsoft-edge-stable-bin"    #Microsoft Edge
  "networkmanager"               #Network Manager
  "network-manager-applet"       #Applet for Network Manager
  "pipewire"                     #For screensharing
  "xdg-desktop-portal-hyprland"  #Handles a lot of stuff for desktop like file pickers, screensharing, etc.
  "nautilus"                     #Nautilus File Manager
  "noto-fonts"                   #Fonts
  "polkit-gnome"                 #Authentication agent
  "rustup"                       #Rust
  "swww"                         #Wallpaper service
  "ttf-nerd-fonts-symbols"       #Icons and Symbols
  "visual-studio-code-bin"       #Visual Studio Code
  "xdg-utils"                    #
)

executeScript() {
  local yayPackage=yay-bin
  local yayUrl="https://aur.archlinux.org/${yayPackage}"
  local yayGitFolder="${GIT_DIR}/${yayPackage}"

  echoText -f "Packages"
  configurePacman
  installYay
  installPackages "Core Packages" "${CORE_PACKAGE_LIST[*]}"
  installPackages "Packages" "${PACKAGE_LIST[*]}"
  configureTextEditor
}

configurePacman() {
  sudo pacman -Syyu
  sudo pacman -Fy
}

installYay() {
  if ! $(isPackageInstalled $yayPackage) ; then
    echoText "Installing yay"
    removeExistingFolder $yayGitFolder
    cloneRepo $yayUrl $yayGitFolder "${yayGitFolder}/PKGBUILD"

    cd $yayGitFolder

    local yayVersion=$(grep '^pkgver=' ./PKGBUILD | cut -d'=' -f2)
    local yayRelease=$(grep '^pkgrel=' ./PKGBUILD | cut -d'=' -f2)
    local installFile="${yayPackage}-${yayVersion}-${yayRelease}-x86_64.pkg.tar.zst"

    buildIt() {
      echoText "Building the '${yayPackage}' package"
      makepkg -s --noconfirm

      if [ ! -f $installFile ] ; then
        echoText -c $COLOR_ERROR "ERROR: Installation file '${installFile}' could not be found for '${yayPackage}'"
        exit 1
      fi

      echoText "'${yayPackage}' was successfully built"
    }

    installIt() {
      echoText "Installing '${yayPackage}'"
      sudo pacman -U $installFile --noconfirm
    }

    if buildIt && installIt ; then
      if $(isPackageInstalled $yayPackage) ; then
        echoText -c $COLOR_SUCCESS "YAY!!! '${yayPackage}' installed successfully"
        cd $GIT_DIR
        rm -rf $yayGitFolder
      else
        echoText -c $COLOR_ERROR "ERROR: '${yayPackage}' is not installed"
        exit 1
      fi
    else
      echoText -c $COLOR_ERROR "ERROR: '${yayPackage}' could not be built and installed"
      exit 1
    fi

  else
    echoText -c $COLOR_SUCCESS "YAY!!! yay is already installed!"
  fi
}

installPackages() {
  existsOrExit $1, "installPackages was called without a package list description"
  existsOrExit $2, "installPackages was called without a list of packages"

  local listDescription=$1
  local packageList=($2)
  local packagesToInstall=()
  local aursToInstall=()

  if [ ${#packageList[@]} -gt 0 ] ; then
    echoText "Beginning installation for the '${listDescription}' group"
  fi

  for package in "${packageList[@]}"; do
    if $( isPackageInstalled $package ) ; then
      echoText "Package '${package}' is already installed"
    elif $( isPackageAvailable $package ) ; then
      echoText "Queuing package '${package}' to be installed with pacman"
      packagesToInstall+=("${package}")
    elif $( isAurAvailable $package ) ; then
      echoText "Queuing package '${package}' to be installed with yay"
      aursToInstall+=("${package}")
    else
      echoText -c $COLOR_ERROR "Unknown package '${package}'"
      exit 1
    fi
  done

  installPacmanPackages() {
    if [[ ${#packagesToInstall[@]} -gt 0 ]] ; then
      echoText "Installing pacman pacakges: ${packagesToInstall[*]}"
      sudo pacman -S --noconfirm "${packagesToInstall[@]}"
    else
      echoText "No pacman packages to install"
    fi
  }

  installYayPackages() {
    if [[ ${#aursToInstall[@]} -gt 0 ]] ; then
      echoText "Installing yay packages: ${aursToInstall[*]}"
      yay -S --noconfirm "${aursToInstall[@]}"
    else
      echoText "No yay packages to install"
    fi
  }

  local hasErrors=false

  if ! installPacmanPackages ; then
    echoText -c $COLOR_ERROR "ERROR: An error occurred installing pacman packages"
    exit 1
  fi

  if ! installYayPackages ; then 
    echoText -c $COLOR_ERROR "ERROR: An error occurred installing yay packages"
    exit 1
  fi

  for package in "${packageList[@]}"; do
    if $( isPackageInstalled $package ) ; then
      echoText "Package '${package}' installed successfully"
    else
      echoText "Package '${package}' was not installed"
      exit 1
    fi
  done

  echoText -c $COLOR_SUCCESS "All packages for the ${listDescription} group installed successfully"
}


isPackageInstalled() {
  existsOrExit $1 "isPackageInstalled was called with no package name"  
  local package="$1"

  if sudo pacman -Qi $package &> /dev/null; then
    echo true
  else
    echo false
  fi
}

isPackageAvailable() {
  existsOrExit $1 "isPackageAvailable was called with no package name"
  local package="$1"

  if sudo pacman -Si $package &> /dev/null; then
    echo true
  else
    echo false
  fi
}

isAurAvailable() {
  existsOrExit $1 "isAurAvailable was called with no package name"

  local package="$1"

  if yay -Si $package &> /dev/null; then
    echo true
  else
    echo false
  fi
}

configureTextEditor() {
  if $(isPackageInstalled nautilus) && $(isPackageInstalled xdg-utils) ; then
    echoText "Nautilus file manager detected"
    xdg-mime default org.gnome.Nautilus.desktop inode/directory
    local defaultValue=$(xdg-mime query default "inode/directory")
    echoText -c $COLOR_SUCCESS "Successfully set '${defaultValue}' as default file explorer..."
  fi
}

executeScript
