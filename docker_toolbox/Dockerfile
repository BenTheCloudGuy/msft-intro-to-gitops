FROM mcr.microsoft.com/devcontainers/base:bullseye

# Set the Arguments for container
ARG PWSH_VERSION="v7.4.3"
ARG PWSH_FILENAME="powershell_7.4.3-1.deb_amd64.deb"
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

# Set the Arguments for the User
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install common packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    apt-utils \
    openssh-client \
    gnupg2 \
    dirmngr \
    iproute2 \
    procps \
    iputils-ping \
    lsof \
    htop \
    net-tools \
    psmisc \
    curl \
    wget \
    rsync \
    ca-certificates \
    unzip \
    zip \
    nano \
    vim \
    vim-tiny \
    less \
    jq \
    build-essential \
    software-properties-common \
    lsb-release \
    apt-transport-https \
    dialog \
    libc6 \
    libgcc1 \
    libkrb5-3 \
    libgssapi-krb5-2 \
    libicu-dev \
    liblttng-ust-dev \
    libstdc++6 \
    libssl-dev \
    libffi-dev \
    zlib1g \
    locales \
    sudo \
    ncdu \
    man-db \
    strace \
    manpages \
    manpages-dev \
    init-system-helpers \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Powershell Core
RUN wget -q https://github.com/PowerShell/PowerShell/releases/download/${PWSH_VERSION}/${PWSH_FILENAME} \
    && sudo dpkg -i ${PWSH_FILENAME} \
    && apt-get update -y \
    && apt-get install -f \
    && rm -f ${PWSH_FILENAME}

# Install Azure Powershell Modules
RUN pwsh -c "Install-Module -Name Az -Force" \
    && pwsh -c "Install-Module -Name AzureAD -RequiredVersion 2.0.2.140 -Force" \
    && pwsh -c "Install-Module -Name Microsoft.Graph -Force" \
    && pwsh -c "Install-Module -Name powershell-yaml -Force"

# Install Azure Tools
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && az config set extension.dynamic_install_allow_preview=true \
    && az extension add --name bastion

# Install Terraform & Packer
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y \
        terraform \
        packer \
    && terraform --version \
    && packer --version

# Install Ansible
RUN apt-get install -y ansible \
    && ansible-galaxy collection install azure.azcollection 

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && gh --version

# User Scope
USER ${USERNAME}