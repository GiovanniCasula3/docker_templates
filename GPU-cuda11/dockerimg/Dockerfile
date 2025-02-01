# Imagen base con soporte CUDA
FROM nvidia/cuda:11.2.2-base-ubuntu20.04

# Configuraciones iniciales
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias esenciales
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    git git-lfs apt-utils htop neovim locales zsh wget curl sudo

# Agregar el repositorio para Python y actualizar
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update

# Instalar Python 3.11.8 desde el PPA de deadsnakes
RUN apt-get install -y python3.11=3.11.8-1+focal1 python3.11-venv python3.11-dev

# Configura locales
RUN locale-gen en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    export LANGUAGE=en_US:en && \
    export LC_ALL=en_US.UTF-8

# Reinstala pip manualmente
RUN wget https://bootstrap.pypa.io/get-pip.py && python3.11 get-pip.py && rm get-pip.py

# Configura Python 3.11 como predeterminado
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Verifica que python3 apunte a python3.11
RUN python3 --version

# Instalar paquetes de Python
RUN python3.11 -m pip install --upgrade pip twine keyrings.alt pynvml fastgpu jupyterlab

# Configura Zsh
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.3/zsh-in-docker.sh)" && \
    sed -i '/^ZSH_THEME/c\ZSH_THEME="agnoster"' ~/.zshrc

# Crea usuario no root
ARG UID
ARG GID
ARG USER

RUN addgroup --gid $GID $USER && \
    adduser --disabled-password --shell /usr/bin/bash --gecos '' --uid $UID --gid $GID $USER && \
    adduser $USER sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Cambia al usuario no root
USER $USER
WORKDIR /home/$USER

# Comando predeterminado
CMD ["jupyter-lab", "--ip=0.0.0.0", "--port=8897", "--no-browser", "--allow-root"]

