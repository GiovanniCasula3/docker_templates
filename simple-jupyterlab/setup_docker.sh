#!/bin/bash

# JupyterLab Docker Setup Script
# Created: 2025-04-01
# Author: 0x4l3x
# Description: Interactive setup script for JupyterLab Docker environment with security considerations

# Color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Banner
echo -e "${CYAN}======================================================${NC}"
echo -e "${CYAN}          JupyterLab Docker Setup Assistant${NC}"
echo -e "${CYAN}======================================================${NC}"
echo -e "${YELLOW}This script will help you set up a secure JupyterLab${NC}"
echo -e "${YELLOW}environment in a Docker container.${NC}"
echo -e "${CYAN}======================================================${NC}"

# Ensure the directory structure
mkdir -p image
mkdir -p workspace


# Security check function
function check_password_strength {
    local password="$1"
    local length=${#password}
    
    if [[ $length -lt 12 ]]; then
        echo -e "${RED}Password is too short (minimum 12 characters)${NC}"
        return 1
    fi
    
    if ! [[ $password =~ [A-Z] ]]; then
        echo -e "${RED}Password must contain at least one uppercase letter${NC}"
        return 1
    fi
    
    if ! [[ $password =~ [a-z] ]]; then
        echo -e "${RED}Password must contain at least one lowercase letter${NC}"
        return 1
    fi
    
    if ! [[ $password =~ [0-9] ]]; then
        echo -e "${RED}Password must contain at least one number${NC}"
        return 1
    fi
    
    if ! [[ $password =~ [[:punct:]] ]]; then
        echo -e "${RED}Password must contain at least one special character${NC}"
        return 1
    fi

    return 0
}

# Function to validate port
function validate_port {
    local port=$1
    
    if ! [[ $port =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Port must be a number${NC}"
        return 1
    fi
    
    if [ "$port" -lt 8800 ] || [ "$port" -gt 8899 ]; then
        echo -e "${RED}Port must be between 8800 and 8899${NC}"
        return 1
    fi
    
    # Check if port is already in use
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${RED}Port $port is already in use${NC}"
        return 1
    fi
    
    return 0
}

# Interactive .env configuration
echo -e "\n${CYAN}Security Configuration${NC}"
echo -e "${YELLOW}Please provide the following information for secure setup:${NC}\n"

# Get container name with default value
DEFAULT_CONTAINER_NAME="jupyterlab-$(whoami)"
while true; do
    read -p "Enter a container name (default: ${DEFAULT_CONTAINER_NAME}): " CONTAINER_NAME
    CONTAINER_NAME=${CONTAINER_NAME:-$DEFAULT_CONTAINER_NAME}
    if [[ $CONTAINER_NAME =~ ^[a-zA-Z0-9_-]+$ ]]; then
        break
    else
        echo -e "${RED}Invalid container name. Use only letters, numbers, hyphens, and underscores.${NC}"
    fi
done

# Get JupyterLab port
while true; do
    read -p "Enter JupyterLab port (8800-8899): " JUPYTER_PORT
    if validate_port "$JUPYTER_PORT"; then
        break
    fi
done

# Get JupyterLab password
while true; do
    read -s -p "Enter JupyterLab password (min 12 chars with upper, lower, number, special): " JUPYTER_PASSWORD
    echo
    if check_password_strength "$JUPYTER_PASSWORD"; then
        read -s -p "Confirm password: " PASSWORD_CONFIRM
        echo
        if [ "$JUPYTER_PASSWORD" = "$PASSWORD_CONFIRM" ]; then
            break
        else
            echo -e "${RED}Passwords do not match${NC}"
        fi
    fi
done

# Get username
while true; do
    read -p "Enter username for the container (default: jupyter): " USERNAME
    if [ -z "$USERNAME" ]; then
        USERNAME="jupyter"
        break
    elif [[ $USERNAME =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        break
    else
        echo -e "${RED}Invalid username. Use lowercase letters, numbers, hyphens, and underscores only.${NC}"
    fi
done

# Get UID and GID
UID_CURRENT=$(id -u)
GID_CURRENT=$(id -g)

read -p "Enter UID for the container (default: $UID_CURRENT): " UID_INPUT
UID=${UID_INPUT:-$UID_CURRENT}

read -p "Enter GID for the container (default: $GID_CURRENT): " GID_INPUT
GID=${GID_INPUT:-$GID_CURRENT}

# Create .env file
cat > .env << EOF
# User configuration
UID=$UID
GID=$GID
USERNAME=$USERNAME

# JupyterLab configuration
CONTAINER_NAME=$CONTAINER_NAME
JUPYTER_PORT=$JUPYTER_PORT
JUPYTER_PASSWORD=$JUPYTER_PASSWORD
EOF

# Set permissions
chmod 600 .env

# Summary
echo -e "\n${GREEN}Configuration summary:${NC}"
echo -e "Container name: ${CYAN}$CONTAINER_NAME${NC}"
echo -e "JupyterLab port: ${CYAN}$JUPYTER_PORT${NC}"
echo -e "Username: ${CYAN}$USERNAME${NC}"
echo -e "UID: ${CYAN}$UID${NC}"
echo -e "GID: ${CYAN}$GID${NC}"
echo -e "Password: ${CYAN}[HIDDEN]${NC}"

# Start Docker container
echo -e "\n${YELLOW}Starting Docker container...${NC}"
docker compose up -d

# Check if container started successfully
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}JupyterLab container started successfully!${NC}"
    echo -e "You can access it at: ${CYAN}http://localhost:$JUPYTER_PORT${NC}"
    echo -e "Use the password you provided during setup to log in."
    echo -e "\n${YELLOW}Security Tips:${NC}"
    echo -e "1. Consider setting up HTTPS for production environments"
    echo -e "2. Keep your .env file secure and don't share it"
    echo -e "3. Change your password periodically"
    echo -e "4. Keep Docker and all packages updated regularly"
else
    echo -e "\n${RED}Failed to start JupyterLab container. Please check logs with:${NC}"
    echo -e "${CYAN}docker compose logs${NC}"
fi
echo -e "\n${CYAN}======================================================${NC}"
echo -e "${CYAN}          JupyterLab Docker Setup Complete${NC}"
echo -e "${CYAN}======================================================${NC}"
echo -e "${YELLOW}Thank you for using the JupyterLab Docker Setup Assistant!${NC}"
echo -e "${YELLOW}For more information, visit: https://jupyterlab.readthedocs.io${NC}"
echo -e "${CYAN}======================================================${NC}"

# Note: This script is for educational purposes and should be tested in a safe environment before use.
# Disclaimer: The author is not responsible for any data loss or security breaches that may occur as a result of using this script.
# Please ensure you understand the implications of running Docker containers and securing your JupyterLab environment.
# Always refer to the official documentation for best practices and security guidelines.
# End of script