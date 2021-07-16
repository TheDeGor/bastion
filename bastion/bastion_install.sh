#!/usr/bin/env bash

env

if [[ $OSTYPE != "linux-gnu" ]]; then
  echo "This script is made for Linux, detected ${OSTYPE}"
  exit 127
fi

# Detect OS family
os_release=$(grep ^ID= < /etc/os-release)
eval "$os_release"

case $ID in
  ubuntu)
    echo "Ubuntu detected"
    os_type="ubuntu"
  ;;
  debian)
    echo "Debian detected"
    os_type="debian"
  ;;
  centos)
    echo "CentOS detected"
    os_type="centos"
  ;;
  *)
    echo "Sorry, this script doesn't support \"${ID}\" OS type"
    exit 127
  ;;
esac


# Update packet manager and upgrade packages
case $os_type in
  ubuntu | debian)
    sudo apt update && sudo apt upgrade -y
  ;;
  centos)
    sudo yum install epel-release -y
    sudo yum update -y
  ;;
esac

# Hardcoding vars

# TERRAFORM=true
# TERRAFORM_VER="1.0.2"
# ANSIBLE=true
# KUBECTL=true
# JQ=true
# HELM=true
# SOPS=true
# SOPS_VER="3.7.1"
# K9S=true
# ZSH=true

#tmux????????????????????????????????


# Install curl, git, pip and other useful staff with no choise)
case $os_type in
  debian)
    sudo apt install -y curl git python python-pip python3 python3-pip gnupg software-properties-common apt-transport-https wget
  ;;
  ubuntu)
    sudo apt install -y curl git python python3 python3-pip gnupg software-properties-common apt-transport-https wget
  ;;
  centos)
    sudo yum install -y curl git wget
    sudo dnf install -y python3
    sudo yum install -y python3-devel
    sudo dnf install -y python2
    sudo yum install -y python2-devel
    sudo yum groupinstall -y 'development tools'
    sudo ln -s /usr/bin/python2 /usr/bin/python
  ;;
esac

# Install terraform
if [ "$TERRAFORM" = true ]; then
  case $os_type in
    ubuntu | debian)
      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
      sudo apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
      sudo apt-get update && sudo apt-get install terraform="$TERRAFORM_VER"
      terraform -install-autocomplete
    ;;
    centos)
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
      sudo yum -y install "terraform-${TERRAFORM_VER}-1.x86_64"
    ;;
  esac
fi

# Install ansible
if [ "$ANSIBLE" = true ]; then
  case $os_type in
    ubuntu | debian)
      sudo apt install -y ansible
    ;;
    centos)
      python2 -m pip install --user ansible
    ;;
  esac
fi

# Install kubectl
if [ "$KUBECTL" = true ]; then
  case $os_type in
    ubuntu | debian)
      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
      sudo apt-get update
      sudo apt-get install -y kubectl
    ;;
    centos)
      cat <<EOF | sudo tee -a /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
      sudo yum install -y kubectl
    ;;
  esac
fi

# Install jq
if [ "$JQ" = true ]; then
  case $os_type in
    ubuntu | debian)
      sudo apt install -y jq
    ;;
    centos)
      sudo yum install -y jq
    ;;
  esac
fi

# Install helm
if [ "$HELM" = true ]; then
  case $os_type in
    ubuntu | debian)
      curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
      echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
      sudo apt-get update
      sudo apt-get install -y helm
    ;;
    centos)
      curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    ;;
  esac
fi


# Install sops
if [ "$SOPS" = true ]; then
  case $os_type in
    ubuntu | debian)
      sops_deb_name="sops_${SOPS_VER}_amd64.deb"
      wget "https://github.com/mozilla/sops/releases/download/v${SOPS_VER}/${sops_deb_name}"
      sudo apt install -y "./${sops_deb_name}"
      rm "${sops_deb_name}"
    ;;
    centos)
      sops_deb_name="sops-${SOPS_VER}-1.x86_64.rpm"
      wget "https://github.com/mozilla/sops/releases/download/v${SOPS_VER}/${sops_deb_name}"
      sudo yum localinstall -y "./${sops_deb_name}"
      rm "${sops_deb_name}"
    ;;
  esac
fi


# Install k9s
if [ "$K9S" = true ]; then
  wget https://github.com/derailed/k9s/releases/download/v0.24.14/k9s_Linux_x86_64.tar.gz
  tar zxf k9s_Linux_x86_64.tar.gz
  sudo mv k9s /usr/local/bin
  rm README.md LICENSE k9s_Linux_x86_64.tar.gz
fi


# Install zsh + oh-my-zsh + powerlevel10k + plugins

if [ "$ZSH" = true ]; then
  if command -v zsh &> /dev/null && command -v git &> /dev/null && command -v wget &> /dev/null; then
      echo -e "ZSH and Git are already installed\n"
  else
      if sudo apt install -y zsh git wget || sudo pacman -S zsh git wget || sudo dnf install -y zsh git wget || sudo yum install -y zsh git wget || sudo brew install git zsh wget || pkg install git zsh wget ; then
          echo -e "zsh wget and git Installed\n"
      else
          echo -e "Please install the following packages first, then try again: zsh git wget \n" && exit
      fi
  fi


  if mv -n ~/.zshrc "$HOME/.zshrc-backup-$(date +"%Y-%m-%d")"; then # backup .zshrc
      echo -e "Backed up the current .zshrc to .zshrc-backup-date\n"
  fi


  echo -e "Installing oh-my-zsh\n"
  if [ -d ~/.oh-my-zsh ]; then
      echo -e "oh-my-zsh is already installed\n"
  else
      git clone --depth=1 git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
  fi





  mkdir -p ~/.zsh_plugins       # external plugins, things, will be instlled in here

  if [ -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ]; then
      cd ~/.oh-my-zsh/plugins/zsh-autosuggestions && git pull
  else
      git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
  fi

  if [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
      cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
  else
      git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  fi

  if [ -d ~/.oh-my-zsh/custom/plugins/zsh-completions ]; then
      cd ~/.oh-my-zsh/custom/plugins/zsh-completions && git pull
  else
      git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions
  fi

  if [ -d ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search ]; then
      cd ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search && git pull
  else
      git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search
  fi


  # INSTALL FONTS

  echo -e "Installing Nerd Fonts version of Hack, Roboto Mono, DejaVu Sans Mono\n"

  wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf -P ~/.fonts/
  wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/
  wget -q --show-progress -N https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/

  fc-cache -fv ~/.fonts

  if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
      cd ~/.oh-my-zsh/custom/themes/powerlevel10k && git pull
  else
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
  fi

  if [ -d ~/.zsh_plugins/marker ]; then
      cd ~/.zsh_plugins/marker && git pull
  else
      git clone --depth 1 https://github.com/pindexis/marker ~/.zsh_plugins/marker
  fi

  if ~/.zsh_plugins/marker/install.py; then
      echo -e "Installed Marker\n"
  else
      echo -e "Marker Installation Had Issues\n"
  fi

  echo -e "\nSudo access is needed to change default shell\n"

  if [ $os_type = "centos" ]; then
    sudo dnf -y install util-linux-user
  fi
  

  
  if sudo chsh -s "$(which zsh)" "$(whoami)"; then
      echo -e "Installation Successful, exit terminal and enter a new session"
  else
      echo -e "Something is wrong"
  fi
  
  cd "$INSTALL_DIR" || exit 127
  cp -f ./.zshrc ~/
  cp -f ./.p10k.zsh ~/

fi
