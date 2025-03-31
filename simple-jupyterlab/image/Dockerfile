FROM python:3.11-slim

# Install common Unix CLI tools
    RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    sudo \
    tini \
    vim \
    btop \
    build-essential \
    cmake \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    unzip \
    nodejs \
    psmisc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# Upgrade pip and install Python packages including JupyterLab and typical packages
RUN pip install --upgrade pip && \
    pip install \
      jupyterlab \
      numpy \
      pandas \
      matplotlib \
      scikit-learn \
      seaborn

# Create a non-root user to run the container securely
RUN useradd -ms /bin/bash jupyter && \
    mkdir -p /home/jupyter/work && \
    chown -R jupyter:jupyter /home/jupyter/work

WORKDIR /home/jupyter/work


RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.3/zsh-in-docker.sh)"
RUN sed -i '/^ZSH_THEME/c\ZSH_THEME="agnoster"' ~/.zshrc
RUN ln -sf /bin/bash /bin/sh

# Switch to the non-root user
USER jupyter
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

# Expose port 8892 for JupyterLab
EXPOSE 8892

# use tini as the entrypoint
ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["bash", "-c", "source ~/.bashrc && jupyter lab --ip 0.0.0.0 --port=8892 --no-browser --allow-root --ContentsManager.allow_hidden=True  --ServerApp.terminals_enabled=True"]
