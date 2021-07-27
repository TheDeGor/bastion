FROM ubuntu:20.10

ARG TERRAFORM_VER="1.0.3"
ARG SOPS_VER="3.7.1"

ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && apt-get update \
  && apt-get install --no-install-recommends -y sudo wget \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && apt-get autoremove -y \
  && apt-get clean -y

USER $USERNAME

WORKDIR /home/$USERNAME

RUN sudo apt update && sudo apt upgrade -y && \
    sudo apt install --no-install-recommends -y \
      curl \
      git \
      python \
      python3 \
      python3-pip \
      gnupg \
      software-properties-common \
      sudo apt-transport-https \
      wget \
      sudo apt-transport-https \
      ca-certificates \
      gnupg \
      net-tools \
      dnsutils \
      lsb-release \
      vim \
      fontconfig && \
    echo "Docker" && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list && \
    sudo apt-get update && \
    sudo apt-get install --no-install-recommends -y docker-ce docker-ce-cli containerd.io && \
    echo "Terraform" && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
    sudo apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    sudo apt-get update && sudo apt-get install --no-install-recommends -y terraform="$TERRAFORM_VER" && \
    terraform -install-autocomplete && \
    echo "Ansible" && \
    sudo apt install --no-install-recommends -y ansible && \
    echo "Kubectl" && \
    curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list && \
    sudo apt-get update && \
    sudo apt-get install --no-install-recommends -y kubectl && \
    echo "jq" && \
    sudo apt install --no-install-recommends -y jq && \
    curl -sS https://baltocdn.com/helm/signing.asc | sudo apt-key add - && \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    sudo apt-get update && \
    echo "Helm" && \
    sudo apt-get install --no-install-recommends -y helm && \
    echo "Sops" && \
    sops_deb_name="sops_${SOPS_VER}_amd64.deb" && \
    sudo wget "https://github.com/mozilla/sops/releases/download/v${SOPS_VER}/${sops_deb_name}" && \
    sudo apt install --no-install-recommends -y "./${sops_deb_name}" && \
    sudo rm "${sops_deb_name}" && \
    echo "K9S" && \
    sudo wget https://github.com/derailed/k9s/releases/download/v0.24.14/k9s_Linux_x86_64.tar.gz && \
    sudo tar zxf k9s_Linux_x86_64.tar.gz && \
    sudo mv k9s /usr/local/bin && \
    sudo rm README.md LICENSE k9s_Linux_x86_64.tar.gz && \
    echo "Zsh" && \
    sudo apt install --no-install-recommends -y zsh && \
    git clone --depth=1 git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    mkdir -p ~/.zsh_plugins && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search && \
    wget https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf -P ~/.fonts/ && \
    wget https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Regular/complete/Roboto%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/ && \
    wget https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf -P ~/.fonts/ && \
    sudo fc-cache -fv ~/.fonts && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
    sudo chsh -s "$(which zsh)" "$(whoami)" && \
    sudo apt-get autoremove -y && \
    sudo apt-get clean -y 
RUN ls -la ~
COPY . /home/$USERNAME
RUN ls -la ~

LABEL Name = "bastion-host" \
      Version = "0.0.1" \
      Architecture = "amd64"

HEALTHCHECK --interval=5s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1 || exit 1

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]