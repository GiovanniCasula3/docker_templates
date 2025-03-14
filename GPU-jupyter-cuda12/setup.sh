#!/bin/bash

# Export UID, GID, and USER as environment variables
export UID=$(id -u)
export GID=$(id -g)
export USER=$(whoami)

# Define the path to the .env file
ENV_FILE=".env"

# Log the start of the script
echo "[+] Starting environment setup for Docker configuration..."

# Create the .env file
echo "[+] Creating .env file at $ENV_FILE..."
touch "$ENV_FILE"
echo ".env file created."

# Write the user configuration to the .env file
echo "[+] Writing user configuration to .env file..."
echo "# USER CONFIG" > "$ENV_FILE"
echo "UID=$UID" >> "$ENV_FILE"
echo "GID=$GID" >> "$ENV_FILE"
echo "USER=$USER" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"
echo "User configuration written: UID=$UID, GID=$GID, USER=$USER."

# Prompt for the JupyterLab configuration variables
echo "[+] Please enter JupyterLab configuration..."

echo "# JUPYTER LAB CONFIG" >> "$ENV_FILE"
read -p "\tEnter COMPOSE_PROJECT_NAME: " COMPOSE_PROJECT_NAME
echo "COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME" >> "$ENV_FILE"
echo "\t[+] Set COMPOSE_PROJECT_NAME to $COMPOSE_PROJECT_NAME."

read -p "\tEnter JUPYTERLAB_CONTAINER_NAME: " JUPYTERLAB_CONTAINER_NAME
echo "JUPYTERLAB_CONTAINER_NAME=$JUPYTERLAB_CONTAINER_NAME" >> "$ENV_FILE"
echo "\t[+] Set JUPYTERLAB_CONTAINER_NAME to $JUPYTERLAB_CONTAINER_NAME."

read -p "\tEnter JUPYTERLAB_PORT: " JUPYTERLAB_PORT
echo "JUPYTERLAB_PORT=$JUPYTERLAB_PORT" >> "$ENV_FILE"
echo "\t[+] Set JUPYTERLAB_PORT to $JUPYTERLAB_PORT."

read -sp "\tEnter JUPYTER_PASSWORD (input will be hidden): " JUPYTER_PASSWORD
echo -e "\n[+] JUPYTER_PASSWORD set."
echo "JUPYTER_PASSWORD=$JUPYTER_PASSWORD" >> "$ENV_FILE"

# Log completion of .env file setup
echo "[+] .env file configuration complete."

# Launch Docker Compose
echo "[+] Starting Docker Compose..."
docker compose up -d
if [ $? -eq 0 ]; then
    echo "[+] Docker Compose started successfully."
else
    echo "[-] Error: Docker Compose failed to start."
fi

echo "Setup completed."

