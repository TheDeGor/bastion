#!/usr/bin/env bash

# Hardcoded vars

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

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
# magenta=$(tput setaf 5)
# cyan=$(tput setaf 6)
reset=$(tput sgr0)

if [[ $OSTYPE != "linux-gnu" ]]; then
  echo "This script is made for Linux, ${red}detected ${OSTYPE}${reset}"
  exit 127
fi

# Detect OS family
os_release=$(grep ^ID= < /etc/os-release)
eval "$os_release"

case $ID in
  ubuntu)
    echo "${green}Ubuntu detected${reset}"
    os_type="ubuntu"
  ;;
  debian)
    echo "${green}Debian detected${reset}"
    os_type="debian"
  ;;
  centos)
    echo "${green}CentOS detected${reset}"
    os_type="centos"
  ;;
  *)
    echo "Sorry, this script doesn't support ${red}\"${ID}\" OS type${reset}"
    exit 127
  ;;
esac


# Update packet manager and upgrade packages
echo "${green}${reset}"

echo "${green}Update packet manager and upgrade packages${reset}"
case $os_type in
  ubuntu | debian)
    DEBIAN_FRONTEND=noninteractive sudo apt update -qq 2> /dev/null && DEBIAN_FRONTEND=noninteractive sudo apt upgrade -y -qq 2> /dev/null
  ;;
  centos)
    sudo yum install epel-release -y -q > /dev/null
    sudo yum update -y -q > /dev/null
    sudo yum install -y -q yum-utils  > /dev/null
  ;;
esac




# Install curl, git, pip and other useful staff with no choise)
echo "${green}Install curl, git, wget, pip and other useful staff${reset}"

case $os_type in
  debian)
    DEBIAN_FRONTEND=noninteractive sudo apt install -y \
      curl \
      git \
      python \
      python-pip \
      python3 \
      python3-pip \
      gnupg \
      software-properties-common \
      apt-transport-https \
      wget \
      apt-transport-https \
      ca-certificates \
      gnupg \
      lsb-release \
      -qq 2> /dev/null
      curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update -qq 2> /dev/null
      sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io > /dev/null
  ;;
  ubuntu)
    DEBIAN_FRONTEND=noninteractive sudo apt install -y \
      curl \
      git \
      python \
      python3 \
      python3-pip \
      gnupg \
      software-properties-common \
      apt-transport-https \
      wget \
      apt-transport-https \
      ca-certificates \
      gnupg \
      lsb-release \
      -qq 2> /dev/null
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update -qq 2> /dev/null
      sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io > /dev/null

  ;;
  centos)
    sudo yum install -q -y curl git wget > /dev/null
    sudo dnf install -q -y python3 > /dev/null
    sudo yum install -q -y python3-devel > /dev/null
    sudo dnf install -q -y python2 > /dev/null
    sudo yum install -q -y python2-devel > /dev/null
    sudo yum groupinstall -q -y 'development tools' > /dev/null
    sudo ln -s /usr/bin/python2 /usr/bin/python > /dev/null
    sudo yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -q -y{ docker-ce docker-ce-cli containerd.io

  ;;
esac

# Install terraform
echo "${green}Install terraform${reset}"

if [ "$TERRAFORM" = true ]; then
  case $os_type in
    ubuntu | debian)
      curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - > /dev/null
      sudo apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /dev/null
      DEBIAN_FRONTEND=noninteractive sudo apt-get update -qq > /dev/null && sudo apt-get install terraform="$TERRAFORM_VER" -qq > /dev/null
      terraform -install-autocomplete > /dev/null
    ;;
    centos)

      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo  > /dev/null
      sudo yum -y -q install "terraform-${TERRAFORM_VER}-1.x86_64" > /dev/null
    ;;
  esac
fi

# Install ansible
echo "${green}Install ansible${reset}"

if [ "$ANSIBLE" = true ]; then
  case $os_type in
    ubuntu | debian)
      DEBIAN_FRONTEND=noninteractive sudo apt install -y ansible -qq > /dev/null
    ;;
    centos)
      python2 -m pip install --user ansible > /dev/null
    ;;
  esac
fi

# Install kubectl
echo "${green}Install kubectl${reset}"

if [ "$KUBECTL" = true ]; then
  case $os_type in
    ubuntu | debian)
      curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - > /dev/null
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list > /dev/null
      DEBIAN_FRONTEND=noninteractive sudo apt-get update -qq > /dev/null
      DEBIAN_FRONTEND=noninteractive sudo apt-get install -y kubectl -qq > /dev/null
    ;;
    centos)
      cat <<EOF | sudo tee -a /etc/yum.repos.d/kubernetes.repo > /dev/null
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
      sudo yum install -y -q kubectl  > /dev/null
    ;;
  esac
fi

# Install jq
echo "${green}Install jq${reset}"

if [ "$JQ" = true ]; then
  case $os_type in
    ubuntu | debian)
      DEBIAN_FRONTEND=noninteractive sudo apt install -y jq -qq > /dev/null
    ;;
    centos)
      sudo yum install -y -q jq  > /dev/null
    ;;
  esac
fi

# Install helm
echo "${green}Install helm${reset}"

if [ "$HELM" = true ]; then
  case $os_type in
    ubuntu | debian)
      curl -sS https://baltocdn.com/helm/signing.asc | sudo apt-key add - > /dev/null
      echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null
      DEBIAN_FRONTEND=noninteractive sudo apt-get update -qq > /dev/null
      DEBIAN_FRONTEND=noninteractive sudo apt-get install -y helm -qq > /dev/null
    ;;
    centos)
      curl -sS https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash  > /dev/null
    ;;
  esac
fi


# Install sops
echo "${green}Install sops${reset}"

if [ "$SOPS" = true ]; then
  case $os_type in
    ubuntu | debian)
      sops_deb_name="sops_${SOPS_VER}_amd64.deb"
      wget -q "https://github.com/mozilla/sops/releases/download/v${SOPS_VER}/${sops_deb_name}"
      DEBIAN_FRONTEND=noninteractive sudo apt install -qq -y "./${sops_deb_name}" > /dev/null
      rm "${sops_deb_name}"
    ;;
    centos)
      sops_deb_name="sops-${SOPS_VER}-1.x86_64.rpm"
      wget -q "https://github.com/mozilla/sops/releases/download/v${SOPS_VER}/${sops_deb_name}"
      sudo yum localinstall -y -q "./${sops_deb_name}"  > /dev/null
      rm "${sops_deb_name}"
    ;;
  esac
fi


# Install k9s
echo "${green}Install k9s${reset}"

if [ "$K9S" = true ]; then
  wget -q https://github.com/derailed/k9s/releases/download/v0.24.14/k9s_Linux_x86_64.tar.gz
  tar zxf k9s_Linux_x86_64.tar.gz
  sudo mv k9s /usr/local/bin
  rm README.md LICENSE k9s_Linux_x86_64.tar.gz
fi


# Install zsh + oh-my-zsh + powerlevel10k + plugins
echo "${green}Install zsh + oh-my-zsh + powerlevel10k + plugins${reset}"

if [ "$ZSH" = true ]; then
  if command -v zsh &> /dev/null; then
      echo -e "${green}ZSH is already installed\n${reset}"
  else
      if DEBIAN_FRONTEND=noninteractive sudo apt install -qq -y zsh 2> /dev/null || sudo dnf install -y -q zsh 2> /dev/null || sudo yum install -y -q zsh 2> /dev/null ; then
          echo -e "${green}ZSH installed\n${reset}"
      else
          echo -e "${red}Please install the following packages first, then try again: zsh git wget \n${reset}" && exit
      fi
  fi


  if mv -n ~/.zshrc "$HOME/.zshrc-backup-$(date +"%Y-%m-%d")" > /dev/null; then # backup .zshrc
      echo -e "${green}Backed up the current .zshrc to .zshrc-backup-date\n${reset}"
  fi


  echo -e "${green}Install oh-my-zsh\n${reset}"
  if [ -d ~/.oh-my-zsh ]; then
      echo -e "${green}oh-my-zsh is already installed\n${reset}"
  else
      git clone --quiet --depth=1 git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh > /dev/null
  fi


  mkdir -p ~/.zsh_plugins       # external plugins, things, will be instlled in here
  echo "${green}Install plugins${reset}"
  if [ -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ]; then
      cd ~/.oh-my-zsh/plugins/zsh-autosuggestions && git pull
  else
      git clone --quiet --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions > /dev/null
  fi

  if [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
      cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
  else
      git clone --quiet --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting > /dev/null
  fi

  if [ -d ~/.oh-my-zsh/custom/plugins/zsh-completions ]; then
      cd ~/.oh-my-zsh/custom/plugins/zsh-completions && git pull
  else
      git clone --quiet --depth=1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions > /dev/null
  fi

  if [ -d ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search ]; then
      cd ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search && git pull
  else
      git clone --quiet --depth=1 https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search > /dev/null
  fi


  # INSTALL FONTS

  echo -e "${green}Install Nerd Fonts version of Hack, Roboto Mono, DejaVu Sans Mono\n${reset}"

  wget -q https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf -P ~/.fonts/
  wget -q https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/
  wget -q https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/

  fc-cache -fv ~/.fonts
  echo -e "${green}Install Powerlevel10k\n${reset}"

  if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
      cd ~/.oh-my-zsh/custom/themes/powerlevel10k && git pull
  else
      git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
  fi

  if [ -d ~/.zsh_plugins/marker ]; then
      cd ~/.zsh_plugins/marker && git pull
  else
      git clone --quiet --depth 1 https://github.com/pindexis/marker ~/.zsh_plugins/marker > /dev/null
  fi

  if ~/.zsh_plugins/marker/install.py > /dev/null; then
      echo -e "${green}Installed Marker\n${reset}"
  else
      echo -e "${yellow}Marker Installation Had Issues\n${reset}"
  fi

  echo -e "\n${yellow}Sudo access is needed to change default shell\n${reset}"

  if [ $os_type = "centos" ]; then
    echo -e "${green}Install chsh\n${reset}"
    sudo dnf -y -q install util-linux-user
  fi
  
  cd "$INSTALL_DIR" || exit 127
  echo -e "${green}Copy ZSH and powerlevel10k config${reset}"
  cp -f ./.zshrc ~/
  cp -f ./.p10k.zsh ~/
  
  echo -e "${green}Changing SHELL to ZSH${reset}"
  if sudo chsh -s "$(which zsh)" "$(whoami)"; then
      echo -e "${blue}Installation Successful${reset}"
  else
      echo -e "${red}Something went wrong${reset}"
  fi

fi
