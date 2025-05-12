#!/bin/bash

# Security check function
check_password_strength() {
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

# Function to check all Docker used ports
get_docker_used_ports() {
    docker ps --format '{{.Ports}}' | grep -o '[0-9]\+->' | sed 's/->//' | sort -nu
}

# Enhanced function to validate port
validate_port() {
    local port=$1
    
    if ! [[ $port =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Port must be a number${NC}"
        return 1
    fi
    
    if [ "$port" -lt 8800 ] || [ "$port" -gt 8899 ]; then
        echo -e "${RED}Port must be between 8800 and 8899${NC}"
        return 1
    fi
    
    # Check if port is already in use by the system
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${RED}Port $port is already in use by the system${NC}"
        return 1
    fi
    
    # Check if port is already used by Docker
    if get_docker_used_ports | grep -q "^${port}$"; then
        echo -e "${RED}Port $port is already used by another Docker container${NC}"
        return 1
    fi
    
    return 0
}

# Function to validate project name
validate_project_name() {
    local name="$1"
    
    # Check if name follows Docker Compose naming rules
    if ! [[ $name =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]]; then
        echo -e "${RED}Invalid project name. Use letters, numbers, dots, underscores, and hyphens. Must start with a letter or number.${NC}"
        return 1
    fi
    
    # Check if a container with this name already exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
        echo -e "${RED}A container with the name '$name' already exists. Please choose a different name.${NC}"
        return 1
    fi
    
    return 0
}

# Function to check if container name is already in use
check_container_name_exists() {
    local container_name="$1"
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo -e "${RED}ERROR: Container name '$container_name' is already in use${NC}"
        return 1
    fi
    return 0
}

# Function to check for easy passwords
check_easy_password() {
    local password="$1"
    local common_passwords=("password" "123456" "12345678" "qwerty" "abc123" "111111" "123456789" "1234567" "monkey" "letmein")
    for cp in "${common_passwords[@]}"; do
        if [[ "${password,,}" == "$cp" ]]; then
            echo -e "${RED},,, really? ,,,${NC}"
            return 1
        fi
    done
    # Check if all characters are identical
    if [[ "$password" =~ ^(.)\1+$ ]]; then
        echo -e "${RED}Password is too simple: repeated characters${NC}"
        return 1
    fi
    # Check for common sequential patterns
    if echo "$password" | grep -Eiq '1234|abcd|qwerty'; then
        echo -e "${RED}Password seems to contain common sequences${NC}"
        return 1
    fi
    return 0
}
