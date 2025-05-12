#!/bin/bash

# Color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check prerequisites
check_prerequisites() {
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
}

# Function to display banner
show_banner() {
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${CYAN}          JupyterLab Docker Setup Assistant${NC}"
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${YELLOW}This script will help you set up a secure JupyterLab${NC}"
    echo -e "${YELLOW}environment in a Docker container.${NC}"
    echo -e "${CYAN}======================================================${NC}"
}

# Function to display summary
show_summary() {
    echo -e "\n${CYAN}======================================================${NC}"
    echo -e "${CYAN}          JupyterLab Docker Setup Complete${NC}"
    echo -e "\n${GREEN}Configuration summary:${NC}"
    echo -e "          Project name: ${CYAN}$COMPOSE_PROJECT_NAME${NC}"
    echo -e "          Container name: ${CYAN}$CONTAINER_NAME${NC}"
    echo -e "          JupyterLab port: ${CYAN}$JUPYTERLAB_PORT${NC}"
    echo -e "          Username: ${CYAN}$USERNAME${NC}"
    echo -e "          UID: ${CYAN}$UID${NC}"
    echo -e "          GID: ${CYAN}$GID${NC}"
    echo -e "          Password: ${CYAN}[HIDDEN]${NC}"
    echo -e "          Volumes: ${CYAN}"
    for VOLUME in "${VOLUMES[@]}"; do
        echo -e "            - ${CYAN}${VOLUME}${NC}"
    done
    echo -e "${CYAN}======================================================${NC}"
    echo -e "${YELLOW}Note: The container will restart automatically unless stopped.${NC}"
}
