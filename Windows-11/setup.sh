#!/bin/bash

# --- Setup script for Windows container using dockurr ---

# Ask for container name
read -p "Enter container name: " CONTAINER_NAME

# Ask for web port
read -p "Enter web port (default: 8006): " WEB_PORT
WEB_PORT=${WEB_PORT:-8006}

# Ask for RDP port
read -p "Enter RDP port (default: 3389): " RDP_PORT
RDP_PORT=${RDP_PORT:-3389}

# Write variables to .env
cat > .env <<EOF
# Environment variables for docker-compose
CONTAINER_NAME=${CONTAINER_NAME}
WEB_PORT=${WEB_PORT}
RDP_PORT=${RDP_PORT}
EOF

echo "✅ .env file created:"
cat .env

# Launch container in detached mode
docker compose up -d

# Print access information
echo ""
echo "✅ Container '${CONTAINER_NAME}' started successfully."
echo "   Web access URL: http://localhost:${WEB_PORT}"
echo "   RDP access: localhost:${RDP_PORT}"