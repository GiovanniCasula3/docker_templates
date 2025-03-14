### COURTESY OF ANGEL'S (APANIZO) WISDOM AND PATIENCE 

### BASE IMAGE ###
# FIRST: check cuda version with: nvidia-smi 
# sudo ubuntu-drivers devices
# sudo ubuntu-drivers install (el driver más actual)
FROM nvidia/cuda:12.2.2-devel-ubuntu22.04

### SYSTEM UPDATE, CONFIGURATIONS AND PYTHON INSTALL ###

RUN apt-get update

# Install locales and essentials
RUN apt-get update --fix-missing && \
    apt-get install -y locales zsh wget curl sudo vim git htop \
    python3 python3-pip python3-dev python3-venv && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    python3 -m pip install --upgrade pip && \
    rm -rf /var/lib/apt/lists/*

ENV LANG en_US.utf8

# Use zsh in docker console
RUN apt-get install -y zsh wget curl
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.3/zsh-in-docker.sh)"
RUN sed -i '/^ZSH_THEME/c\ZSH_THEME="agnoster"' ~/.zshrc

# Giving root permissions to $USER
# Add non-root user (call this with the specific UID and GID of the host, to share permissions)
ARG UID=$UID
ARG GID=$GID
ARG USER=$USER


RUN apt-get install sudo
RUN apt-get install vim -y
RUN apt-get install neovim -y
RUN addgroup --gid $GID $USER
RUN adduser --disabled-password --shell /usr/bin/bash --gecos '' --uid $UID --gid $GID $USER
RUN adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# git global configuration
RUN apt-get install -y git
RUN git config --global pull.rebase true
RUN git config --global rebase.autoStash true

# Install htop
RUN apt-get install -y htop

# Python general stuff
RUN apt-get install -y python3 python3-pip python3-dev python3-venv
RUN python3 -m pip install --upgrade pip

RUN ln -s /usr/bin/python3 /usr/bin/python

### Cleaning libraries
RUN rm -rf /var/lib/apt/lists/*

### INSTALL JUPYTER WITH COLLABORATION, AND PYTHON CODE ASSISTANT ###
RUN pip3 install jupyter
RUN pip3 install -U jupyterlab>4.0.6
RUN pip3 install jupyter-collaboration
RUN pip3 install -U jupyter_server>2.0.0

RUN pip3 install -U jedi-language-server
RUN pip3 install -U python-language-server
RUN pip3 install -U python-lsp-server
RUN pip3 install 'python-lsp-server[all]'

### PACKAGES ###
# General pip packages
RUN pip install --upgrade twine keyrings.alt pynvml fastgpu

# PYTORCH 
# INSTRUCTIONS: https://pytorch.org/get-started/previous-versions/
RUN pip3 install torch torchvision torchaudio

### SWITCHING TO USER AND MOVING FORWARD ###
USER $USER

### EXPORTING PATH ###
RUN echo 'export PATH=$PATH:~/.local/bin' >> /home/$USER/.bashrc

# JUPYTER STUFF #2
RUN pip3 install -U jupyter-resource-usage ipywidgets lckr_jupyterlab_variableinspector \
                        jupyterlab-spellchecker jupyterlab_execute_time

# Setup IPython kernel
RUN python -m ipykernel install --user

# Place to install other python packages in the requirements.txt file
COPY requirements.txt /home/$USER
RUN pip3 install -r "/home/$USER/requirements.txt"

# Set the shell to zsh
ENV SHELL=/bin/zsh

### Create a directory for host data and set it as the working directory ###
RUN mkdir -p /home/$USER/host_data
WORKDIR /home/$USER/host_data

