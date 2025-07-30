#!/bin/bash

# Color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check prerequisites
check_prerequisites() {
    echo -e "${CYAN}Checking prerequisites...${NC}"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed. Please install Docker first.${NC}"
        exit 1
    fi

    # Check if Docker Compose is installed
    if ! command -v docker compose &> /dev/null; then
        echo -e "${RED}Error: Docker Compose is not installed. Please install Docker Compose first.${NC}"
        exit 1
    fi

    # Check for NVIDIA Docker runtime
    if ! docker info | grep -q nvidia; then
        echo -e "${YELLOW}Warning: NVIDIA Docker runtime not detected.${NC}"
        echo -e "${YELLOW}Please ensure you have nvidia-container-toolkit installed.${NC}"
        echo -e "${YELLOW}Installation: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html${NC}"
        read -p "Continue anyway? (y/N): " continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Check CUDA version on host
    if command -v nvidia-smi &> /dev/null; then
        echo -e "${GREEN}NVIDIA SMI detected:${NC}"
        nvidia-smi --query-gpu=driver_version,cuda_version --format=csv,noheader,nounits
    else
        echo -e "${YELLOW}Warning: nvidia-smi not found. Make sure NVIDIA drivers are installed.${NC}"
    fi
}

# Function to display banner
show_banner() {
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${CYAN}      CUDA JupyterLab Docker Setup (NVIDIA)${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${YELLOW}This script will help you set up a secure CUDA-enabled${NC}"
    echo -e "${YELLOW}JupyterLab environment using NVIDIA's PyTorch container.${NC}"
    echo -e "\n${YELLOW}Features included:${NC}"
    echo -e "  ✓ Latest JupyterLab 4.x with Python file support"
    echo -e "  ✓ NVIDIA PyTorch container with CUDA 12.4+ support"
    echo -e "  ✓ Flash-attention pre-installed"
    echo -e "  ✓ Local cache control for Hugging Face models"
    echo -e "  ✓ Code formatting and development tools"
    echo -e "${CYAN}======================================================${NC}"
}

# Function to generate secure password
generate_password() {
    openssl rand -base64 12 | tr -d "=+/" | cut -c1-12
}

# Function to display summary
show_summary() {
    echo -e "\n${CYAN}======================================================${NC}"
    echo -e "${CYAN}     CUDA JupyterLab Setup Complete (NVIDIA)${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${GREEN}Configuration:${NC}"
    echo -e "  Project name: ${CYAN}$COMPOSE_PROJECT_NAME${NC}"
    echo -e "  Container: ${CYAN}$CONTAINER_NAME${NC}"
    echo -e "  Base Image: ${CYAN}nvcr.io/nvidia/pytorch:24.06-py3${NC}"
    echo -e "  Port: ${CYAN}$JUPYTERLAB_PORT${NC}"
    echo -e "  Username: ${CYAN}$USERNAME${NC}"
    echo -e "  UID/GID: ${CYAN}$CONTAINER_UID/$CONTAINER_GID${NC}"
    echo -e "  Workspace: ${CYAN}./workspace${NC}"
    echo -e "  Cache: ${CYAN}./cache (local control)${NC}"
    echo -e "  Password: ${CYAN}[HIDDEN]${NC}"
    echo -e "\n${YELLOW}Features:${NC}"
    echo -e "  ✓ Latest JupyterLab 4.x"
    echo -e "  ✓ Python file editing and execution"
    echo -e "  ✓ Code formatting (Black, isort)"
    echo -e "  ✓ Flash-attention support"
    echo -e "  ✓ CUDA 12.4+ ready"
    echo -e "  ✓ PyTorch, Transformers, and ML libraries"
    echo -e "  ✓ Local Hugging Face cache control"
    echo -e "\n${YELLOW}Files created:${NC}"
    echo -e "  - Dockerfile (NVIDIA PyTorch base)"
    echo -e "  - docker-compose.yml (with GPU support)"
    echo -e "  - requirements.txt (modular dependencies)"
    echo -e "  - start.sh & stop.sh (control scripts)"
    echo -e "  - test_cuda_setup.ipynb (validation notebook)"
    echo -e "  - .env (configuration file)"
    echo -e "\n${GREEN}To start:${NC} ${CYAN}./start.sh${NC}"
    echo -e "${GREEN}To stop:${NC} ${CYAN}./stop.sh${NC}"
    echo -e "${GREEN}Access at:${NC} ${CYAN}http://localhost:$JUPYTERLAB_PORT${NC}"
    echo -e "${CYAN}======================================================${NC}"
}
