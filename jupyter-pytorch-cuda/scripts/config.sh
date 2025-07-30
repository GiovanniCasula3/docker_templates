#!/bin/bash

# Function to get project configuration
get_project_config() {
    echo -e "\n${CYAN}Project Configuration${NC}"
    echo -e "${YELLOW}======================================================${NC}"
    
    # Get COMPOSE_PROJECT_NAME with default value
    DEFAULT_PROJECT_NAME="cuda-jupyter-$(whoami)"
    while true; do
        read -p "Enter a project name for Docker Compose (default: ${DEFAULT_PROJECT_NAME}): " COMPOSE_PROJECT_NAME
        COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-$DEFAULT_PROJECT_NAME}
        if validate_project_name "$COMPOSE_PROJECT_NAME"; then
            break
        fi
    done

    # Get container name with default value
    DEFAULT_CONTAINER_NAME="simple-jupyter-cuda"
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
    
    # Get username - with default for CUDA environment
    echo -e "${YELLOW}The default username 'jupyter' is recommended for compatibility.${NC}"
    echo -e "${YELLOW}This provides a standard user configuration for container environments.${NC}"
    while true; do
        read -p "Enter username for the container (default: jupyter): " USERNAME
        if [ -z "$USERNAME" ]; then
            USERNAME="jupyter"
            break
        elif validate_username "$USERNAME"; then
            break
        fi
    done

    # Get UID and GID - with defaults for container environment
    DEFAULT_UID="1000"
    DEFAULT_GID="1000"
    CURRENT_UID=$(id -u)
    CURRENT_GID=$(id -g)

    echo -e "${YELLOW}For container environments, standard UID/GID values are recommended.${NC}"
    echo -e "${YELLOW}Default: UID=$DEFAULT_UID, GID=$DEFAULT_GID (standard container values)${NC}"
    echo -e "${YELLOW}Current system: UID=$CURRENT_UID, GID=$CURRENT_GID${NC}"
    echo -e "${YELLOW}Using non-standard values may cause permission issues with mounted volumes.${NC}"

    read -p "Enter UID for the container (default: $DEFAULT_UID): " CONTAINER_UID_INPUT
    CONTAINER_UID=${CONTAINER_UID_INPUT:-$DEFAULT_UID}

    read -p "Enter GID for the container (default: $DEFAULT_GID): " CONTAINER_GID_INPUT
    CONTAINER_GID=${CONTAINER_GID_INPUT:-$DEFAULT_GID}

    # Validate UID and GID are numbers
    if ! [[ $CONTAINER_UID =~ ^[0-9]+$ ]] || ! [[ $CONTAINER_GID =~ ^[0-9]+$ ]]; then
        echo -e "${RED}UID and GID must be numbers${NC}"
        exit 1
    fi
}

# Function to get security configuration
get_security_config() {
    echo -e "\n${CYAN}Security Configuration${NC}"
    echo -e "${YELLOW}======================================================${NC}"
    
    # Get JupyterLab port
    while true; do
        read -p "Enter JupyterLab port (8000-9999, default: 8823): " JUPYTERLAB_PORT
        JUPYTERLAB_PORT=${JUPYTERLAB_PORT:-8823}
        if validate_port "$JUPYTERLAB_PORT"; then
            break
        fi
    done

    # Get JupyterLab password
    echo -e "${YELLOW}Choose password setup method:${NC}"
    echo -e "1. Generate a secure password automatically"
    echo -e "2. Enter a custom password"
    
    while true; do
        read -p "Select option (1/2): " password_option
        case $password_option in
            1)
                JUPYTER_PASSWORD=$(generate_password)
                echo -e "Generated password: ${CYAN}$JUPYTER_PASSWORD${NC}"
                echo -e "${YELLOW}Please save this password! You'll need it to access JupyterLab.${NC}"
                break
                ;;
            2)
                while true; do
                    read -s -p "Enter a secure password for JupyterLab: " JUPYTER_PASSWORD
                    echo
                    if check_password_strength "$JUPYTER_PASSWORD" && check_easy_password "$JUPYTER_PASSWORD"; then
                        read -s -p "Confirm password: " PASSWORD_CONFIRM
                        echo
                        if [ "$JUPYTER_PASSWORD" = "$PASSWORD_CONFIRM" ]; then
                            break 2
                        else
                            echo -e "${RED}Passwords do not match${NC}"
                        fi
                    else
                        echo -e "${RED}Password doesn't meet security requirements.${NC}"
                        echo -e "${YELLOW}Requirements: At least 12 characters, uppercase, lowercase, numbers, and special characters.${NC}"
                        echo -e "${YELLOW}Avoid common patterns and sequences.${NC}"
                    fi
                done
                ;;
            *)
                echo -e "${RED}Please select 1 or 2${NC}"
                ;;
        esac
    done
}

# Function to get volume configuration
get_volume_config() {
    echo -e "\n${CYAN}Volume Configuration${NC}"
    echo -e "${YELLOW}======================================================${NC}"
    
    # Default volumes for CUDA JupyterLab
    VOLUMES=()
    VOLUMES+=("./workspace:/home/$USERNAME/workspace")
    VOLUMES+=("./cache:/home/$USERNAME/.cache")
    
    echo -e "${GREEN}Default volumes configured:${NC}"
    echo -e "  - ${CYAN}./workspace:/home/$USERNAME/workspace${NC} (JupyterLab workspace)"
    echo -e "  - ${CYAN}./cache:/home/$USERNAME/.cache${NC} (Hugging Face cache - local control)"
    
    echo -e "\n${YELLOW}The cache volume allows you to control model downloads locally.${NC}"
    echo -e "${YELLOW}Models will be stored in ./cache and persist between container restarts.${NC}"
    
    # Ask if user wants to add additional volumes
    read -p "Do you want to add additional volume mounts? (y/N): " add_volumes
    if [[ "$add_volumes" =~ ^[Yy]$ ]]; then
        while true; do
            read -p "Enter additional volume (host:container format, or 'done' to finish): " additional_volume
            if [ "$additional_volume" = "done" ]; then
                break
            fi
            
            if [[ "$additional_volume" =~ ^[^:]+:[^:]+$ ]]; then
                if validate_volume_path "$additional_volume"; then
                    VOLUMES+=("$additional_volume")
                    echo -e "${GREEN}Added volume: $additional_volume${NC}"
                fi
            else
                echo -e "${RED}Invalid volume format. Use host:container format (e.g., ./data:/home/$USERNAME/data)${NC}"
            fi
        done
    fi
    
    echo -e "\n${GREEN}Final volume configuration:${NC}"
    for VOLUME in "${VOLUMES[@]}"; do
        echo -e "  - ${CYAN}${VOLUME}${NC}"
    done
}
