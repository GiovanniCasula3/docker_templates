# Partimos de una imagen base de Ubuntu
FROM ubuntu:22.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Actualización del sistema y configuraciones básicas
RUN apt-get update && apt-get upgrade -y

# Instalar locales y herramientas básicas
RUN apt-get install -y --no-install-recommends \
    locales \
    zsh \
    wget \
    curl \
    sudo \
    vim \
    git \
    git-lfs \
    htop \
    software-properties-common \
    gnupg \
    ca-certificates \
    net-tools \
    iputils-ping \
    openssh-client \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && git lfs install

ENV LANG en_US.utf8

# Instalar los drivers de NVIDIA y CUDA
RUN apt-get update && apt-get install -y --no-install-recommends \
    nvidia-driver-535 \
    nvidia-utils-535 \
    && rm -rf /var/lib/apt/lists/*

# Instalar CUDA Toolkit (versión compatible con tus drivers)
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get -y install cuda-toolkit-12-2 \
    && rm cuda-keyring_1.1-1_all.deb \
    && rm -rf /var/lib/apt/lists/*

# Configurar ZSH
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.3/zsh-in-docker.sh)" \
    && sed -i '/^ZSH_THEME/c\ZSH_THEME="agnoster"' ~/.zshrc

# Añadir usuario no-root con los UID y GID específicos
ARG UID=1013
ARG GID=1013
ARG USER=dalgora

RUN groupadd --gid $GID $USER \
    && useradd --create-home --shell /bin/zsh --uid $UID --gid $GID $USER \
    && adduser $USER sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /home/$USER/.jupyter \
    && chown -R $USER:$USER /home/$USER/.jupyter

# Asegurarnos de que los directorios de Jupyter tengan los permisos correctos
RUN mkdir -p /home/$USER/.local/share/jupyter \
    && chown -R $USER:$USER /home/$USER/.local

# Configuración global de git
RUN git config --global pull.rebase true \
    && git config --global rebase.autoStash true

# Instalar Python y herramientas relacionadas
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    && python3 -m pip install --upgrade pip \
    && ln -s /usr/bin/python3 /usr/bin/python

# Instalar Jupyter y extensiones como root para acceso global
RUN pip3 install --no-cache-dir \
    jupyter \
    jupyterlab>=4.0.6 \
    jupyter-collaboration \
    jupyter_server>=2.0.0 \
    jedi-language-server \
    python-language-server \
    python-lsp-server \
    'python-lsp-server[all]' \
    jupyter-resource-usage \
    ipywidgets \
    lckr_jupyterlab_variableinspector \
    jupyterlab-spellchecker \
    jupyterlab_execute_time

# Paquetes generales de Python
RUN pip3 install --no-cache-dir \
    twine \
    keyrings.alt \
    pynvml \
    fastgpu

# Instalar PyTorch con soporte para CUDA
RUN pip3 install --no-cache-dir \
    torch \
    torchvision \
    torchaudio \
    --extra-index-url https://download.pytorch.org/whl/cu122

# Cambiar al usuario creado
USER $USER

# Configurar PATH y otras variables de entorno
RUN echo 'export PATH=$PATH:~/.local/bin' >> /home/$USER/.bashrc \
    && echo 'export PATH=$PATH:~/.local/bin' >> /home/$USER/.zshrc \
    && mkdir -p /home/$USER/.local/bin \
    && echo "alias sudo='sudo '" >> /home/$USER/.zshrc \
    && echo "alias apt='sudo apt'" >> /home/$USER/.zshrc

# Instalar kernel de Python para Jupyter
RUN python -m ipykernel install --user

# Instalar algunas herramientas útiles a nivel de usuario
RUN pip3 install --user --no-cache-dir \
    black \
    flake8 \
    isort \
    mypy \
    pytest \
    jupyterlab-git

# Copiar requirements.txt y instalar dependencias adicionales
COPY --chown=$USER:$USER requirements.txt /home/$USER/
RUN pip3 install --user --no-cache-dir -r "/home/$USER/requirements.txt"

# Configurar el shell
ENV SHELL=/bin/zsh

# Crear y establecer directorio de trabajo con permisos correctos
RUN sudo mkdir -p /home/$USER/host_data \
    && sudo chown -R $USER:$USER /home/$USER/host_data
WORKDIR /home/$USER/host_data

# Variables de entorno para CUDA
ENV PATH="/usr/local/cuda-12.2/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-12.2/lib64:${LD_LIBRARY_PATH}"

# Asegurar que el usuario puede ejecutar apt dentro del contenedor
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Verificar conectividad a internet
RUN ping -c 4 8.8.8.8 || echo "Advertencia: No hay conexión a Internet. Verifica la configuración de red del contenedor."

# Crear un script para instalar paquetes adicionales fácilmente
RUN echo '#!/bin/bash\n\
sudo apt-get update\n\
sudo apt-get install -y $@\n\
' > /home/$USER/.local/bin/install-pkg && \
    chmod +x /home/$USER/.local/bin/install-pkg

# Comando para iniciar JupyterLab con permisos de ejecución para el usuario
CMD ["bash", "-c", "source ~/.bashrc && jupyter lab --ip 0.0.0.0 --no-browser --collaborative --allow-root --ContentsManager.allow_hidden=True"]
