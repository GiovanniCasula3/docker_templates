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

    echo -e "${GREEN}✓ Docker and Docker Compose are available${NC}"
    echo -e "${CYAN}Note: CUDA support provided by NVIDIA PyTorch container${NC}"

    # Check for external storage (can be configured during setup)
    echo -e "\n${CYAN}Storage Configuration${NC}"
    echo -e "${YELLOW}You can configure custom storage locations during setup${NC}"
    echo -e "${YELLOW}Choose locations with sufficient space for models and datasets${NC}"
}

# Function to display banner
show_banner() {
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${CYAN}   CUDA JupyterLab Docker Setup (NVIDIA Container)${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${YELLOW}This script will help you set up a secure CUDA-enabled${NC}"
    echo -e "${YELLOW}JupyterLab environment using NVIDIA's PyTorch container.${NC}"
    echo -e "\n${GREEN}💾 CONFIGURABLE STORAGE${NC}"
    echo -e "${YELLOW}Container data storage location is configurable${NC}"
    echo -e "${YELLOW}Storage configuration available during setup${NC}"
    echo -e "\n${YELLOW}Features included:${NC}"
    echo -e "  ✓ Latest JupyterLab 4.x with Python file support"
    echo -e "  ✓ NVIDIA PyTorch container with CUDA 12.4+ support"
    echo -e "  ✓ Flash-attention pre-installed"
    echo -e "  ✓ Local cache control for Hugging Face models"
    echo -e "  ✓ Code formatting and development tools"
    echo -e "  ✓ Data persistence between container restarts"
    echo -e "${CYAN}======================================================${NC}"
}

# Function to generate secure password
generate_password() {
    openssl rand -base64 12 | tr -d "=+/" | cut -c1-12
}

# Function to display summary for configurable storage
show_summary_configurable() {
    echo -e "\n${CYAN}======================================================${NC}"
    echo -e "${CYAN}  CUDA JupyterLab Setup Complete (NVIDIA Container)${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${GREEN}Configuration:${NC}"
    echo -e "  Project name: ${CYAN}$COMPOSE_PROJECT_NAME${NC}"
    echo -e "  Container: ${CYAN}$CONTAINER_NAME${NC}"
    echo -e "  Base Image: ${CYAN}nvcr.io/nvidia/pytorch:24.06-py3${NC}"
    echo -e "  Port: ${CYAN}$JUPYTERLAB_PORT${NC}"
    echo -e "  Username: ${CYAN}$USERNAME${NC}"
    echo -e "  UID/GID: ${CYAN}$CONTAINER_UID/$CONTAINER_GID${NC}"
    echo -e "  Password: ${CYAN}[HIDDEN]${NC}"
    echo -e "\n${GREEN}💾 CONTAINER STORAGE:${NC}"
    echo -e "  Storage Location: ${CYAN}${CONTAINER_BASE_DIR}${NC}"
    echo -e "  ${GREEN}✓ Persistent storage configured${NC}"
    echo -e "\n${YELLOW}Features:${NC}"
    echo -e "  ✓ Latest JupyterLab 4.x"
    echo -e "  ✓ Python file editing and execution"
    echo -e "  ✓ Code formatting (Black, isort)"
    echo -e "  ✓ Flash-attention support"
    echo -e "  ✓ CUDA 12.4+ ready"
    echo -e "  ✓ PyTorch, Transformers, and ML libraries"
    echo -e "  ✓ Hugging Face cache management"
    echo -e "  ✓ Data persistence between container restarts"
    echo -e "\n${YELLOW}Files created:${NC}"
    echo -e "  - Dockerfile (NVIDIA PyTorch base)"
    echo -e "  - docker-compose.yml (with GPU support)"
    echo -e "  - requirements.txt (modular dependencies)"
    echo -e "  - start.sh & stop.sh (container control scripts)"
    echo -e "  - .env (configuration file with storage paths)"
    echo -e "\n${GREEN}To start:${NC} ${CYAN}./start.sh${NC}"
    echo -e "${GREEN}To stop:${NC} ${CYAN}./stop.sh${NC}"
    echo -e "${GREEN}Access at:${NC} ${CYAN}http://localhost:$JUPYTERLAB_PORT${NC}"
    echo -e "\n${YELLOW}Storage Benefits:${NC}"
    echo -e "  💾 Models and datasets stored in configured location"
    echo -e "  🔄 Data persists between container restarts"
    echo -e "  📁 Easy backup of ${CONTAINER_BASE_PATH} directory"
    echo -e "${CYAN}======================================================${NC}"
}

# Function to display original summary (for compatibility)
show_summary() {
    show_summary_configurable
}