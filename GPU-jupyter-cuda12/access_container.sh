#!/bin/bash


#JUPYTERLAB_CONTAINER_NAME=$(grep '^JUPYTERLAB_CONTAINER_NAME=' .env | cut -d '=' -f2 | tr -d ' "')

#if [ -z "$JUPYTERLAB_CONTAINER_NAME" ]; then
#  echo "[!] Error: Variable JUPYTERLAB_CONTAINER_NAME not defined in .env."
#  exit 1
#fi

# docker exec -it -u 0 "$JUPYTERLAB_CONTAINER_NAME" bash

docker exec -it -u $UID jupyterlab_gpu_dalgora bash
