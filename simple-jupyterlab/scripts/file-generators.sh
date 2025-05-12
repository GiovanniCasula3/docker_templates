#!/bin/bash

# Function to generate the .env file
generate_env_file() {
    cat > .env << EOF
# Project configuration
COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME

# User configuration
UID=$CONTAINER_UID
GID=$CONTAINER_GID
USERNAME=$USERNAME

# JupyterLab configuration
CONTAINER_NAME=$CONTAINER_NAME
JUPYTERLAB_PORT=$JUPYTERLAB_PORT
JUPYTER_PASSWORD=$JUPYTER_PASSWORD
EOF
    
    echo -e "${GREEN}.env file created successfully${NC}"
}

# Function to generate the docker-compose.yml file
generate_docker_compose() {
    # Construct volumes section for docker-compose.yml
    VOLUMES_CONFIG=""
    for VOLUME in "${VOLUMES[@]}"; do
        VOLUMES_CONFIG+="            - ${VOLUME}\n"
    done
    VOLUMES_CONFIG=${VOLUMES_CONFIG%\\n}
    
    cat > docker-compose.yml << EOF
version: '3'
services:
    jupyterlab:
        env_file:
            - .env
        build: 
            context: ./image
            dockerfile: ./Dockerfile
            args:
                UID: \${UID}
                GID: \${GID}
                USERNAME: \${USERNAME}
                JUPYTERLAB_PORT: \${JUPYTERLAB_PORT}
        image: jupyterlab-\${CONTAINER_NAME}:latest
        container_name: \${CONTAINER_NAME}
        environment: 
            - JUPYTER_ENABLE_LAB=yes
            - NB_UID=\${UID}
            - NB_GID=\${GID}
            - JUPYTER_TOKEN=\${JUPYTER_PASSWORD}
        ports:
            - \${JUPYTERLAB_PORT}:\${JUPYTERLAB_PORT}
        volumes:
$(echo -e "$VOLUMES_CONFIG")
        user: \${UID}:\${GID}
        restart: unless-stopped
        networks:
            - jupyter-network

networks:
    jupyter-network:
        driver: bridge
EOF
    
    echo -e "${GREEN}docker-compose.yml created successfully${NC}"
}

# Function to generate the Dockerfile
generate_dockerfile() {
    cat > ./image/Dockerfile << EOF
FROM python:3.11-slim

# Set arguments for user creation
ARG USERNAME=$USERNAME
ARG UID=$CONTAINER_UID
ARG GID=$CONTAINER_GID
ARG JUPYTERLAB_PORT=$JUPYTERLAB_PORT

# Install essential packages
RUN apt-get update && \\
       apt-get install -y --no-install-recommends \\
           zsh \\
           wget \\
           curl \\
           git \\
           sudo \\
           tini \\
           unzip \\
           vim \\
           build-essential \\
           openssl \\
           libssl-dev \\
           ca-certificates && \\
       apt-get clean && \\
       rm -rf /var/lib/apt/lists/*

# Create user with specified UID and GID
RUN groupadd -g $CONTAINER_GID $USERNAME && \\
       useradd -m -u $CONTAINER_UID -g $CONTAINER_GID -s /bin/bash $USERNAME && \\
       echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \\
       chmod 0440 /etc/sudoers.d/$USERNAME


# Install Jupyterlab
RUN pip install --no-cache-dir --upgrade pip && \\
       pip install --no-cache-dir jupyterlab

# Copy the requirements file to the workspace directory
COPY requirements.txt /home/$USERNAME/workspace/requirements.txt

# Install Python packages from requirements.txt
RUN pip install --no-cache-dir -r /home/$USERNAME/workspace/requirements.txt

# Create and set permissions for workspace directory
RUN mkdir -p /home/$USERNAME/workspace && \\
       chown -R $USERNAME:$USERNAME /home/$USERNAME

# Install oh-my-zsh
RUN sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN ln -sf /bin/bash /bin/sh
RUN chsh -s \$(which zsh)

# Generate self-signed SSL certificate for Jupyter
RUN mkdir -p /home/$USERNAME/ssl/private && \\
   mkdir -p /home/$USERNAME/ssl/certs && \\
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\
   -keyout /home/$USERNAME/ssl/private/jupyter.key \\
   -out /home/$USERNAME/ssl/certs/jupyter.crt \\
   -subj "/C=US/ST=None/L=None/O=None/OU=None/CN=localhost" && \\
   chmod 600 /home/$USERNAME/ssl/private/jupyter.key && \\
   chmod 644 /home/$USERNAME/ssl/certs/jupyter.crt && \\
   chown -R $USERNAME:$USERNAME /home/$USERNAME/ssl


# Switch to the non-root user
USER $USERNAME
WORKDIR /home/$USERNAME/workspace

ENV SHELL=/bin/zsh

# Use tini as entrypoint for proper signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start JupyterLab  #  --ServerApp.terminals_enabled=True ??
CMD ["sh", "-c", "jupyter lab  --no-browser --allow-root  --ip=0.0.0.0 --port=$JUPYTERLAB_PORT --notebook-dir=/home/$USERNAME/workspace  --ContentsManager.allow_hidden=True \\
   --NotebookApp.certfile=/home/$USERNAME/ssl/certs/jupyter.crt --NotebookApp.keyfile=/home/$USERNAME/ssl/private/jupyter.key"]
EOF

    
    echo -e "${GREEN}Dockerfile created successfully${NC}"
}
