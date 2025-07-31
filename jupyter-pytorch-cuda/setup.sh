#!/bin/bash

# CUDA JupyterLab Docker Setup Script - NVIDIA Container Edition
# Created: 2025-07-30
# Description: Main script for CUDA JupyterLab Docker environment setup
# Uses NVIDIA's official PyTorch container with CUDA 12.2+ support
# Fixed cache permissions for Hugging Face models

# Import helper functions
source ./scripts/utils.sh
source ./scripts/validation.sh
source ./scripts/config.sh
source ./scripts/file-generators.sh

# Check prerequisites and show banner
check_prerequisites
show_banner

# Ensure the directory structure
mkdir -p dockerimg
mkdir -p workspace
mkdir -p cache

# Get configuration from user
get_project_config  
get_user_config
get_security_config
get_volume_config

# Generate configuration files
generate_env_file 
generate_docker_compose
generate_dockerfile
generate_requirements
generate_test_files
generate_control_scripts

# Set permissions
chmod 600 .env
chmod +x start.sh
chmod +x stop.sh

# Set cache directory permissions
echo -e "${YELLOW}Setting cache directory permissions...${NC}"
chown -R $CONTAINER_UID:$CONTAINER_GID ./cache 2>/dev/null || chmod -R 777 ./cache

echo -e "\n${GREEN}Setup complete!${NC}"
echo -e "${YELLOW}You can now start the container with: ${CYAN}./start.sh${NC}"
echo -e "${YELLOW}Or use Docker Compose directly: ${CYAN}docker compose up -d${NC}"

# Display summary
show_summary
