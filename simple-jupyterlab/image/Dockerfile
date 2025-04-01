FROM python:3.11-slim

# Set arguments for user creation
ARG USERNAME=jupyter
ARG UID=1000
ARG GID=1000

# Install essential packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    sudo \
    tini \
    vim \
    build-essential \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user with specified UID and GID
RUN groupadd -g $GID $USERNAME && \
    useradd -m -u $UID -g $GID -s /bin/bash $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Install Python packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    jupyterlab \
    numpy \
    pandas \
    matplotlib \
    scikit-learn \
    seaborn \
    ipywidgets

# Create and set permissions for workspace directory
RUN mkdir -p /home/$USERNAME/workspace && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME

# Switch to the non-root user
USER $USERNAME
WORKDIR /home/$USERNAME/workspace

# Expose port for JupyterLab
EXPOSE 8888

# Use tini as entrypoint for proper signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--ServerApp.terminals_enabled=True", "--ContentsManager.allow_hidden=True"]