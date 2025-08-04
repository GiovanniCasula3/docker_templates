#!/bin/bash

# CUDA JupyterLab Docker Setup Script - NVIDIA Container Edition
# Description: Main script for CUDA JupyterLab Docker environment setup
# Uses NVIDIA's official PyTorch container with CUDA 12.2+ support
# Configurable storage location for containers

# Import helper functions
source ./scripts/utils.sh
source ./scripts/validation.sh
source ./scripts/config.sh
source ./scripts/file-generators.sh

# Check prerequisites and show banner
check_prerequisites
show_banner

# Ensure the local directory structure (for scripts and configs only)
mkdir -p dockerimg
# Note: workspace or cache directories will be created from within the container

# Get configuration from user
get_project_config  
get_user_config
get_security_config
get_volume_config

# Storage configuration
echo -e "${YELLOW}Configuring container with persistent storage...${NC}"

echo -e "${GREEN}Storage configuration completed${NC}"
echo -e "  Location: ${CONTAINER_BASE_PATH}"

# Storage directories will be created by start.sh script
echo -e "${YELLOW}Storage directories will be created when container starts...${NC}"

# Generate configuration files
generate_env_file 
generate_docker_compose
generate_dockerfile
generate_requirements
generate_control_scripts

# Set permissions for local config files
chmod 600 .env
chmod +x start.sh
chmod +x stop.sh

echo -e "\n${GREEN}Setup complete!${NC}"
echo -e "${YELLOW}Container will use internal storage only${NC}"
echo -e "${YELLOW}You can now start the container with: ${CYAN}./start.sh${NC}"
echo -e "${YELLOW}Or use Docker Compose directly: ${CYAN}docker compose up -d${NC}"

# Display summary
show_summary