FROM nvidia/cuda:12.2.2-devel-ubuntu22.04 AS builder

# Run as root only when needed
USER root

# Consolidate apt-get update and installation in one layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget \
      curl \
      git \
      file \
      sudo \
      python3 \
      python3-pip \
      python3-dev \
      openjdk-21-jdk \
      build-essential \
      cmake \
      libssl-dev \
      libffi-dev \
      libxml2-dev \
      libxslt1-dev \
      zlib1g-dev \
      unzip \
      nodejs \
      psmisc \
      p7zip-full \
      p7zip-rar \
      libreadline-dev \
      software-properties-common \
      net-tools && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Configure git global options
RUN git config --global pull.rebase true && \
    git config --global rebase.autoStash true 

# Upgrade pip, link python and set locale
RUN python3 -m pip install --upgrade pip && \
    ln -s /usr/bin/python3 /usr/bin/python
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install general Python pip packages
RUN pip install --upgrade twine keyrings.alt pynvml fastgpu

# Configure IPython for faster completion (system-wide)
RUN mkdir /etc/ipython && \
    echo "c.Completer.use_jedi = False" > /etc/ipython/ipython_config.py

# Install Jupyter, Lab and server packages (pin versions when possible)
RUN pip install --upgrade jupyter jupyterlab jupyter-server

# Install Oh-My-Zsh script securely (download to temp, then remove)
RUN wget -O /tmp/zsh-in-docker.sh https://github.com/deluan/zsh-in-docker/releases/download/v1.1.3/zsh-in-docker.sh && \
    chmod +x /tmp/zsh-in-docker.sh && \
    sh /tmp/zsh-in-docker.sh && \
    rm /tmp/zsh-in-docker.sh

# Define build args for user creation with default values for safety
ARG UID=${UID}
ARG GID=${GID}
ARG USER=${USER}

# Create non-root user and add to sudoers with no password prompting
RUN addgroup --gid ${GID} ${USER} && \
    adduser --disabled-password --gecos '' --uid ${UID} --gid ${GID} ${USER} && \
    adduser ${USER} sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to non-root to reduce privilege exposure
USER ${USER}

# Python packages installation as non-root: upgrade setuptools and install libraries  
RUN pip install --upgrade setuptools
RUN pip install r2pipe capstone keystone-engine unicorn angr pyelftools lief scapy
RUN pip install scikit-learn fastgpu nbdev pandas transformers tensorflow-addons \
    tensorflow pymongo emoji python-dotenv plotly torch torchvision torchaudio

# Install additional tools via pip:
# • avclass from avclass-malicialab
# • capa from flare-capa
# • magika, tqdm, requests, beautifulsoup4, upsetplot, matplotlib and logging
RUN pip install avclass-malicialab flare-capa magika tqdm requests beautifulsoup4 upsetplot matplotlib logging

# Download capa rules, unzip and modify the default rules path inside the installed flare-capa module.
# The sed command updates the variable RULES_PATH_DEFAULT_STRING in the file.
RUN wget -O /home/${USER}/work/v4.0.0.zip https://github.com/mandiant/capa-rules/archive/refs/tags/v4.0.0.zip && \
    unzip /home/${USER}/work/v4.0.0.zip -d /home/${USER}/work && \
    RULES_PATH="/home/${USER}/work/capa-rules-4.0.0" && \
    FILE=$(python -c "import os, flare_capa; print(os.path.join(os.path.dirname(flare_capa.__file__), 'capa', 'main.py'))") && \
    sed -i "s|^RULES_PATH_DEFAULT_STRING.*|RULES_PATH_DEFAULT_STRING = \"$RULES_PATH\"|" $FILE


# Define Ghidra variables (ensure the zip name is set)
ARG GHIDRA_VERSION=11.3.1
ARG GHIDRA_URL=https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.3.1_build/ghidra_11.3.1_PUBLIC_20250219.zip
ARG GHIDRA_SHA256=bcda0a9de8993444766cc255964c65c042b291ddaf6c50d654e316e442b441fa
ENV GHIDRA_ZIP=ghidra_${GHIDRA_VERSION}.zip

# Download, verify (optional), and extract Ghidra as root (temporarily switching back if needed)
USER root
RUN wget -qO /tmp/${GHIDRA_ZIP} ${GHIDRA_URL} && \
    # Uncomment the next line if you wish to verify the checksum
    # echo "${GHIDRA_SHA256}  /tmp/${GHIDRA_ZIP}" | sha256sum -c - && \
    unzip -q /tmp/${GHIDRA_ZIP} -d /opt && \
    rm /tmp/${GHIDRA_ZIP} && \
    ln -s /opt/ghidra_${GHIDRA_VERSION} /opt/ghidra && \
    echo 'export PATH=/opt/ghidra:$PATH' > /etc/profile.d/ghidra.sh && \
    chmod +x /etc/profile.d/ghidra.sh

# Switch back to non-root user and configure shell and Jupyter kernel.
USER ${USER}
RUN echo 'export PATH=$PATH:~/.local/bin' >> /home/${USER}/.bashrc && \
    echo 'ZSH_THEME="agnoster"' >> /home/${USER}/.zshrc && \
    python -m ipykernel install --user


ENV SHELL=/bin/zsh
WORKDIR /home/${USER}/work

# Use exec to run jupyter lab so signals are correctly handled
CMD exec jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --ContentsManager.allow_hidden=True
