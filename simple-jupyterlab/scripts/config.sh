#!/bin/bash

# Function to get project configuration
get_project_config() {
    echo -e "\n${CYAN}Project Configuration${NC}"
    echo -e "${YELLOW}======================================================${NC}"
    
    # Get COMPOSE_PROJECT_NAME with default value
    DEFAULT_PROJECT_NAME="jupyterlab-$(whoami)"
    while true; do
        read -p "Enter a project name for Docker Compose (default: ${DEFAULT_PROJECT_NAME}): " COMPOSE_PROJECT_NAME
        COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-$DEFAULT_PROJECT_NAME}
        if validate_project_name "$COMPOSE_PROJECT_NAME"; then
            break
        fi
    done

    # Get container name with default value
    DEFAULT_CONTAINER_NAME="jupyterlab-$(whoami)"
    while true; do
        read -p "Enter a container name (default: ${DEFAULT_CONTAINER_NAME}): " CONTAINER_NAME
        CONTAINER_NAME=${CONTAINER_NAME:-$DEFAULT_CONTAINER_NAME}
        if [[ $CONTAINER_NAME =~ ^[a-zA-Z0-9_-]+$ ]] && check_container_name_exists "$CONTAINER_NAME"; then
            break
        else
            echo -e "${RED}Invalid container name. Use only letters, numbers, hyphens, and underscores and ensure it's not already in use.${NC}"
        fi
    done
}

# Function to get user configuration
get_user_config() {
    echo -e "\n${CYAN}User Configuration${NC}"
    echo -e "${YELLOW}======================================================${NC}"
    
    # Get username - with clearer explanation
    echo -e "${YELLOW}The default username 'jupyter' is recommended for compatibility.${NC}"
    echo -e "${YELLOW}Only change if you have a specific reason to do so.${NC}"
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

    # Get UID and GID - with clearer explanation
    UID_CURRENT=$(id -u)
    GID_CURRENT=$(id -g)

    echo -e "${YELLOW}For proper file permissions, UID and GID should match your system user.${NC}"
    echo -e "${YELLOW}The defaults are set to your current user's UID ($UID_CURRENT) and GID ($GID_CURRENT).${NC}"
    echo -e "${YELLOW}Changing these values may cause permission issues with mounted volumes.${NC}"

    read -p "Enter UID for the container (recommended: $UID_CURRENT): " CONTAINER_UID_INPUT
    CONTAINER_UID=${CONTAINER_UID_INPUT:-$UID_CURRENT}

    read -p "Enter GID for the container (recommended: $GID_CURRENT): " CONTAINER_GID_INPUT
    CONTAINER_GID=${CONTAINER_GID_INPUT:-$GID_CURRENT}
}

# Function to get security configuration
get_security_config() {
    echo -e "\n${CYAN}Security Configuration${NC}"
    echo -e "${YELLOW}======================================================${NC}"
    
    # Get JupyterLab port
    while true; do
        read -p "Enter JupyterLab port (8800-8899): " JUPYTERLAB_PORT
        if validate_port "$JUPYTERLAB_PORT"; then
            break
        fi
    done

    # Get JupyterLab password
    while true; do
        read -s -p "Enter a secure password for the JupyterLab server: " JUPYTER_PASSWORD
        echo
        if check_password_strength "$JUPYTER_PASSWORD" && check_easy_password "$JUPYTER_PASSWORD"; then
            read -s -p "Confirm password: " PASSWORD_CONFIRM
            echo
            if [ "$JUPYTER_PASSWORD" = "$PASSWORD_CONFIRM" ]; then
                break
            else
                echo -e "${RED}Passwords do not match${NC}"
            fi
        else
            echo -e "${RED}Seriously? This password is so weak, even my grandma's cat could hack it. And you're in a cybersecurity group? Come on!${NC}"
            echo -e "${YELLOW}Please try again.${NC}"
            echo -e "${YELLOW}Note: Password must be at least 12 characters long, contain uppercase, lowercase, numbers, and special characters.${NC}"
            echo -e "${YELLOW}Avoid using common passwords or sequences.${NC}"
        fi
    done
}

# Function to get volume configuration
get_volume_config() {
    echo -e "\n${CYAN}Volume Configuration${NC}"
    echo -e "${YELLOW}Volumes allow you to persist data and share files between your host and the container.${NC}"
    echo -e "${YELLOW}The workspace directory is already mounted by default.${NC}"
    echo -e "${YELLOW}======================================================${NC}"

    # Default volumes array with the workspace directory
    VOLUMES=("./workspace:/home/${USERNAME}/workspace")

    # Ask if user wants to mount additional volumes
    while true; do
        read -p "Do you want to mount additional volumes? (y/n, default: n): " ADD_VOLUMES
        ADD_VOLUMES=${ADD_VOLUMES:-n}
        if [[ "$ADD_VOLUMES" =~ ^[Yy]$ ]]; then
            # Get source path
            read -p "Enter host source path (absolute path recommended): " HOST_PATH
            if [ ! -d "$HOST_PATH" ]; then
                echo -e "${YELLOW}Warning: Directory '$HOST_PATH' doesn't exist. It will be created.${NC}"
                mkdir -p "$HOST_PATH"
            fi
            
            # Get container destination path
            read -p "Enter container destination path (e.g., /home/${USERNAME}/data): " CONTAINER_PATH
            
            # Add to volumes array
            VOLUMES+=("${HOST_PATH}:${CONTAINER_PATH}")
            
            read -p "Add another volume? (y/n, default: n): " CONTINUE
            CONTINUE=${CONTINUE:-n}
            if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
                break
            fi
        else
            break
        fi
    done

    # Display selected volumes
    echo -e "\n${GREEN}Selected volumes:${NC}"
    for VOLUME in "${VOLUMES[@]}"; do
        echo -e "  - ${CYAN}${VOLUME}${NC}"
    done
}
