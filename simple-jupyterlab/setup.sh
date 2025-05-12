#!/bin/bash

# JupyterLab Docker Setup Script
# Created: 2025-04-07
# Description: Main script for JupyterLab Docker environment setup

# Import helper functions
source ./scripts/utils.sh
source ./scripts/validation.sh
source ./scripts/config.sh
source ./scripts/file-generators.sh

# Check prerequisites from utils.sh
check_prerequisites
show_banner

# Ensure the directory structure
mkdir -p image
mkdir -p workspace

# Get configuration from user from config.sh
get_project_config  
get_user_config
get_security_config
get_volume_config

# Generate configuration files from file-generators.sh
generate_env_file 
generate_docker_compose
generate_dockerfile

# Set permissions
chmod 600 .env

# Start Docker container
echo -e "\n${YELLOW}Starting Docker container...${NC}"
docker compose up -d

# Check if container started successfully
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}JupyterLab container started successfully!${NC}"
    echo -e "You can access it at: ${CYAN}http://<server_ip>:$JUPYTERLAB_PORT${NC}"
    echo -e "Use the password you provided during setup to log in."
else
    echo -e "\n${RED}Failed to start JupyterLab container. Please check logs with:${NC}"
    echo -e "${CYAN}docker compose logs${NC}"
fi

# Display summary from utils.sh
show_summary
