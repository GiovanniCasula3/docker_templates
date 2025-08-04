#!/bin/bash

# Enhanced password strength check function
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

# Function to check for easy/common passwords
check_easy_password() {
    local password="$1"
    
    # Check for common patterns
    if [[ $password =~ ^123456789 ]] || [[ $password =~ ^password ]] || [[ $password =~ ^qwerty ]]; then
        echo -e "${RED}Password contains common patterns${NC}"
        return 1
    fi
    
    # Check for sequential characters
    if [[ $password =~ abcd ]] || [[ $password =~ 1234 ]]; then
        echo -e "${RED}Password contains sequential patterns${NC}"
        return 1
    fi
    
    return 0
}

# Function to get all Docker used ports
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
    
    if [ "$port" -lt 8000 ] || [ "$port" -gt 9999 ]; then
        echo -e "${RED}Port must be between 8000 and 9999${NC}"
        return 1
    fi
    
    # Check if port is already in use by Docker containers
    if docker ps --format '{{.Ports}}' | grep -q ":$port->"; then
        echo -e "${RED}Port $port is already used by a Docker container${NC}"
        return 1
    fi
    
    # Check if port is in use by system (Linux/macOS)
    if command -v lsof &> /dev/null; then
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo -e "${RED}Port $port is already in use by the system${NC}"
            return 1
        fi
    fi
    
    return 0
}

# Function to validate project name
validate_project_name() {
    local project_name="$1"
    
    if [[ ! $project_name =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${RED}Project name can only contain letters, numbers, hyphens, and underscores${NC}"
        return 1
    fi
    
    if [[ ${#project_name} -lt 3 ]]; then
        echo -e "${RED}Project name must be at least 3 characters long${NC}"
        return 1
    fi
    
    return 0
}

# Function to check if container name already exists
check_container_name_exists() {
    local container_name="$1"
    
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo -e "${RED}Container name '$container_name' already exists${NC}"
        return 1
    fi
    
    return 0
}

# Function to validate volume paths
validate_volume_path() {
    local volume_path="$1"
    
    # Extract the host path (before the colon)
    local host_path=$(echo "$volume_path" | cut -d':' -f1)
    
    # Check if it's an absolute path
    if [[ ! "$host_path" =~ ^/ ]] && [[ ! "$host_path" =~ ^\. ]]; then
        echo -e "${RED}Volume path must be absolute or relative (starting with ./)${NC}"
        return 1
    fi
    
    # Warn about relative paths and suggest external storage usage
    if [[ "$host_path" =~ ^\. ]]; then
        echo -e "${YELLOW}Warning: Relative path detected ($host_path)${NC}"
        echo -e "${YELLOW}This will create directories in your local project folder.${NC}"
        echo -e "${YELLOW}Consider using external storage paths like: ${CONTAINER_BASE_DIR:-/var/lib/containers/[project]}/[folder]${NC}"
        
        read -p "Continue with local directory creation? (y/N): " confirm_local
        if [[ ! "$confirm_local" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Volume path rejected by user${NC}"
            return 1
        fi
        
        # Only create directory if user explicitly confirms
        mkdir -p "$host_path" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to create directory: $host_path${NC}"
            return 1
        fi
    fi
    
    # Check if path exists or can be created
    if [[ ! "$host_path" =~ ^\. ]]; then
        if [ ! -d "$(dirname "$host_path")" ]; then
            echo -e "${YELLOW}Parent directory does not exist: $(dirname "$host_path")${NC}"
            echo -e "${YELLOW}Will be created during setup if permissions allow${NC}"
        fi
    fi
    
    return 0
}

# Function to validate username
validate_username() {
    local username="$1"
    
    if [[ ! $username =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        echo -e "${RED}Username must start with a letter or underscore and contain only lowercase letters, numbers, hyphens, and underscores${NC}"
        return 1
    fi
    
    if [[ ${#username} -lt 2 ]]; then
        echo -e "${RED}Username must be at least 2 characters long${NC}"
        return 1
    fi
    
    return 0
}