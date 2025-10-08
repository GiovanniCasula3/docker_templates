# Windows 11 in Docker (dockurr/windows)

This repository provides a ready-to-use setup for running a Windows 11 virtual machine inside Docker using the dockurr/windows image.  
The environment supports GPU passthrough (NVIDIA), RDP access, and web GUI access through port forwarding.

## Features
- Windows 11 virtualized inside Docker
- Configurable CPU cores and RAM size
- Audio and display forwarding (X11 support)
- NVIDIA GPU passthrough
- Access via both Web UI and Remote Desktop (RDP)
- Persistent storage via bind mount (`./windows`)

## Project structure
```
.
├── docker-compose.yml   # Docker Compose configuration
├── setup.sh             # Interactive setup script
└── windows/             # Persistent Windows disk and configuration
```

## Prerequisites
### On the host system
- Linux host with KVM support enabled (`/dev/kvm`)
- Docker and Docker Compose v2 installed
- NVIDIA Container Toolkit installed for GPU passthrough  
  ```bash
  sudo apt install -y nvidia-container-toolkit
  sudo systemctl restart docker
  ```
- (Optional) X11 display server if you want graphical output forwarded

## Setup instructions

### 1. Clone this project
```bash
git clone https://github.com/<your-repo>/Windows-11.git
cd Windows-11
```

### 2. Run the setup script
```bash
chmod +x setup.sh
./setup.sh
```

You will be prompted for:
- Container name  
- Web access port (default: 8006)  
- RDP port (default: 3389)

The script automatically creates a `.env` file with your chosen configuration and starts the container.

## Docker Compose overview
The container definition in `docker-compose.yml` includes:

```yaml
services:
  windows:
    image: dockurr/windows
    container_name: ${CONTAINER_NAME}
    environment:
      VERSION: "11"
      RAM_SIZE: "16G"
      CPU_CORES: "16"
      AUDIO: "1"
      DISPLAY: ${DISPLAY}
    devices:
      - /dev/kvm
      - /dev/net/tun
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    cap_add:
      - NET_ADMIN
    ports:
      - ${WEB_PORT}:8006
      - ${RDP_PORT}:3389/tcp
      - ${RDP_PORT}:3389/udp
    volumes:
      - ./windows:/storage
      - /tmp/.X11-unix:/tmp/.X11-unix
    stdin_open: true
    tty: true
    restart: always
```

## Accessing the VM
After the setup completes, you can access Windows in two ways:

| Method | URL / Host | Notes |
|--------|-------------|-------|
| Web interface | `http://localhost:<WEB_PORT>` | Browser-based access |
| RDP client | `localhost:<RDP_PORT>` | Use Microsoft Remote Desktop, Remmina, etc. |

Default credentials (if not changed):
- Username: `Administrator`  
- Password: `dockurr`

## Storage
All persistent data (virtual disk, configuration, snapshots) is stored inside the `./windows` folder:
```
./windows/data.img
```
If you need to expand the disk:
```bash
truncate -s +100G ./windows/data.img
```
Then extend the partition from within Windows using Disk Management.

## Useful commands
| Action | Command |
|--------|----------|
| Start container | `docker compose up -d` |
| Stop container | `docker compose down` |
| View logs | `docker compose logs -f` |
| Enter container shell | `docker exec -it <container_name> bash` |
| Check GPU passthrough | `docker exec -it <container_name> nvidia-smi` |

## Cleanup
To remove the container but keep your data:
```bash
docker compose down
```
To remove everything (including the disk image):
```bash
docker compose down -v
rm -rf windows/
```

