#!/bin/bash

# Obtener el nombre del contenedor desde el archivo .env
JUPYTERLAB_CONTAINER_NAME=$(grep '^JUPYTERLAB_CONTAINER_NAME=' .env | cut -d '=' -f2 | tr -d ' "')

# Acceder al contenedor con una sesión interactiva
docker exec -it "$JUPYTERLAB_CONTAINER_NAME" bash
