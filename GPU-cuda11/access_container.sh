#!/bin/bash

# Cargar variables del archivo .env
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Verifica que las variables necesarias estén definidas
if [[ -z "$UID" || -z "$GID" || -z "$USER" || -z "$JUPYTERLAB_PORT" || -z "$JUPYTERLAB_CONTAINER_NAME" || -z "$JUPYTER_PASSWORD" ]]; then
    echo "Missing one or more required variables in the .env file"
    exit 1
fi

# Inicia el contenedor si no está corriendo
if ! docker ps -q -f name="$JUPYTERLAB_CONTAINER_NAME" > /dev/null; then
    echo "Container $JUPYTERLAB_CONTAINER_NAME is not running. Starting it..."
    docker run -d $JUPYTERLAB_CONTAINER_NAME$
else
    echo "Container $JUPYTERLAB_CONTAINER_NAME is already running."
fi

# Accede al contenedor
docker exec -it "$JUPYTERLAB_CONTAINER_NAME" /bin/bash

