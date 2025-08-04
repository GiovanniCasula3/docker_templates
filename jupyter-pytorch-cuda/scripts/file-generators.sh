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

# Storage configuration
CONTAINER_BASE_PATH=$CONTAINER_BASE_PATH
EOF
    
    echo -e "${GREEN}.env file created successfully${NC}"
}

# Function to generate the docker-compose.yml file
generate_docker_compose() {
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  cuda-jupyter:
    build:
      context: .
      dockerfile: dockerimg/Dockerfile
      args:
        USERNAME: \${USERNAME}
        UID: \${UID}
        GID: \${GID}
    container_name: \${CONTAINER_NAME}
    restart: unless-stopped
    ports:
      - "\${JUPYTERLAB_PORT}:8888"
    environment:
      - JUPYTER_ENABLE_LAB=yes
      - JUPYTER_TOKEN=\${JUPYTER_PASSWORD}
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    networks:
      - cuda-jupyter-network

networks:
  cuda-jupyter-network:
    driver: bridge
EOF

    echo -e "${GREEN}docker-compose.yml created successfully${NC}"
}

# Function to generate the Dockerfile
generate_dockerfile() {
    cat > dockerimg/Dockerfile << EOF
# Use NVIDIA's official PyTorch container (has all dependencies pre-configured)
FROM nvcr.io/nvidia/pytorch:24.06-py3

# Build arguments for user configuration
ARG USERNAME=jupyter
ARG UID=1000
ARG GID=1000

# Update and install system dependencies
USER root
RUN apt-get update && apt-get install -y \\
    curl \\
    git \\
    vim \\
    htop \\
    tree \\
    sudo \\
    build-essential \\
    && rm -rf /var/lib/apt/lists/*

# Create user with home directory and set up environment
RUN groupadd -g \${GID} \${USERNAME} && \\
    useradd -m -u \${UID} -g \${GID} -s /bin/bash \${USERNAME} && \\
    echo "\${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install additional Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Note: workspace and cache directories will be created from within the container
# This avoids permission issues with external storage

# Switch to user
USER \${USERNAME}
WORKDIR /home/\${USERNAME}

# Note: Environment variables will be set from within the Jupyter notebook
# when directories are created

# Expose JupyterLab port
EXPOSE 8888

# Start JupyterLab
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser"]
EOF

    echo -e "${GREEN}Dockerfile created successfully${NC}"
}

# Function to generate requirements.txt
generate_requirements() {
    cat > requirements.txt << 'EOF'
# Core JupyterLab and extensions
jupyterlab>=4.0.0
jupyter-lsp
jupyterlab-lsp

# Code formatting and linting
black
isort
flake8
mypy

# Data science and ML libraries
numpy
pandas
matplotlib
seaborn
plotly
scikit-learn

# Hugging Face ecosystem
transformers
datasets
tokenizers
accelerate

# Flash Attention (if compatible)
flash-attn

# Additional useful libraries
tqdm
requests
pyyaml
python-dotenv
ipywidgets

# Development tools
pytest
jupyter-book
EOF

    echo -e "${GREEN}requirements.txt created successfully${NC}"
}

# Function to generate control scripts
generate_control_scripts() {
    # Create start.sh script
    cat > start.sh << 'EOF'
#!/bin/bash

# Color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}Starting CUDA JupyterLab Container...${NC}"

# Source environment variables
source .env

echo -e "${YELLOW}Note: All directories will be created inside the container${NC}"
echo -e "${YELLOW}No external volume mounts - container storage is self-contained${NC}"

# Build and start the container
echo "Building and starting container..."
docker compose up --build -d

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}Container started successfully!${NC}"
    echo -e "Access JupyterLab at: ${CYAN}http://localhost:$JUPYTERLAB_PORT${NC}"
    echo -e "Password: ${CYAN}$JUPYTER_PASSWORD${NC}"
    echo -e "\n${GREEN}� CONTAINER STORAGE ACTIVE${NC}"
    echo -e "  All data stored inside the container"
    echo -e "  Workspace and cache created via Jupyter notebook"
    echo -e "\n${YELLOW}Features available:${NC}"
    echo -e "  ✓ Latest JupyterLab 4.x with Python file support"
    echo -e "  ✓ NVIDIA PyTorch container with CUDA support"
    echo -e "  ✓ Flash-attention pre-installed"
    echo -e "  ✓ Persistent storage for models and data"
    echo -e "  ✓ Code formatting and Python execution"
    echo -e "  ✓ ML/DL libraries: PyTorch, Transformers, Datasets, etc."
    echo -e "\n${YELLOW}Commands:${NC}"
    echo -e "  View logs: ${CYAN}docker compose logs -f${NC}"
    echo -e "  Stop: ${CYAN}./stop.sh${NC} or ${CYAN}docker compose down${NC}"
    echo -e "  Rebuild: ${CYAN}docker compose up --build${NC}"
else
    echo -e "\n${RED}Failed to start container. Check logs with:${NC}"
    echo -e "${CYAN}docker compose logs${NC}"
    exit 1
fi
EOF

    # Create stop.sh script
    cat > stop.sh << 'EOF'
#!/bin/bash

# Color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Stopping CUDA JupyterLab Container...${NC}"

# Source environment variables to get container name
if [ -f .env ]; then
    source .env
    echo -e "Stopping container: ${CYAN}$CONTAINER_NAME${NC}"
else
    echo -e "${YELLOW}Warning: .env file not found, using docker compose down${NC}"
fi

docker compose down

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Container stopped successfully.${NC}"
    echo -e "To start again, run: ${CYAN}./start.sh${NC}"
else
    echo -e "${RED}Error stopping container. You may need to stop it manually:${NC}"
    echo -e "${CYAN}docker stop $CONTAINER_NAME${NC}"
fi
EOF

    chmod +x start.sh
    chmod +x stop.sh
    
    echo -e "${GREEN}Control scripts created successfully${NC}"
}