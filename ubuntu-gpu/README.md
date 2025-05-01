# Instrucciones para configurar JupyterLab con Ubuntu y soporte NVIDIA

Este documento te guiará a través de la configuración y uso de tu entorno JupyterLab basado en Ubuntu con soporte para GPUs NVIDIA.

## Requisitos previos

1. **Docker Engine**: Asegúrate de tener instalado Docker Engine en tu servidor
2. **Docker Compose**: Necesitarás Docker Compose para gestionar los contenedores
3. **NVIDIA Container Toolkit**: Necesario para poder usar GPUs dentro de contenedores

## Instalación del NVIDIA Container Toolkit

Si aún no tienes el NVIDIA Container Toolkit instalado, sigue estos pasos:

```bash
# Configurar el repositorio
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Actualizar e instalar
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Reiniciar Docker
sudo systemctl restart docker
```

## Estructura de directorios

Primero, crea esta estructura de directorios:

```
ubuntu-jupyter/
├── .env
├── docker-compose.yml
├── access_container.sh
├── dockerimg/
│   ├── Dockerfile
│   └── requirements.txt
└── volume/
    └── (Aquí se montarán tus archivos)
```

## Configuración

1. **Modifica el archivo `.env`** con tu información:
   - Ajusta `UID` y `GID` para que coincidan con tu usuario en el sistema host (usa `id -u` y `id -g` para averiguarlos)
   - Cambia `USER` a tu nombre de usuario
   - Cambia el `JUPYTER_PASSWORD` a algo seguro

2. **Configura los puertos** en `.env` si es necesario:
   - `JUPYTERLAB_PORT`: El puerto en el que se expondrá JupyterLab (por defecto 8899)

3. **Ajusta los requisitos** en `dockerimg/requirements.txt` según tus necesidades

## Construcción y ejecución

```bash
# Dar permisos de ejecución al script de acceso
chmod +x access_container.sh

# Crear el directorio de volumen si no existe
mkdir -p volume

# Construir la imagen (puede tardar varios minutos la primera vez)
docker-compose build

# Iniciar el contenedor
docker-compose up -d
```

## Acceso a JupyterLab

Podrás acceder a JupyterLab a través de:
- `http://direccion-de-tu-servidor:JUPYTERLAB_PORT`
- Usa el token definido en `JUPYTER_PASSWORD` para iniciar sesión

## Configuración de VS Code para edición remota

Para editar desde VS Code a través de SSH:

1. Instala la extensión "Remote - SSH" en VS Code
2. Conecta a tu servidor mediante SSH
3. Navega a la carpeta `volume` de este proyecto
4. Todo lo que guardes aquí estará disponible en tu JupyterLab

## Acceso al contenedor

Si necesitas acceder directamente al contenedor:

```bash
# Usando el script proporcionado
./access_container.sh
```

## Verificación de GPU

Para verificar que NVIDIA está correctamente configurado dentro del contenedor:

```bash
# Accede al contenedor
./access_container.sh

# Dentro del contenedor, ejecuta:
nvidia-smi
```

## Detener el contenedor

```bash
docker-compose down
```

## Solución de problemas

- Si tienes problemas con los permisos, asegúrate de que los valores de `UID` y `GID` en `.env` coinciden con tu usuario en el host
- Si no puedes conectar con JupyterLab, verifica que el puerto está abierto en tu firewall
- Para problemas con GPUs, verifica que NVIDIA Container Toolkit está correctamente instalado y configurado

---

Con estas instrucciones deberías tener un entorno JupyterLab funcional basado en Ubuntu con soporte para GPUs NVIDIA, accesible a través de SSH desde VS Code.
