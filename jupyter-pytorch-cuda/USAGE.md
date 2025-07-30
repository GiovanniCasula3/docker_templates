# Quick Start Guide

## 1. Setup
```bash
# Make script executable (Linux/macOS)
chmod +x setup.sh

# Run setup
./setup.sh
```

## 2. Configuration Options

### Default Values (Recommended)
- **Container Name**: simple-jupyter-cuda
- **Username**: jupyter
- **UID/GID**: 1000/1000 (standard user values)
- **Port**: 8823 (configurable)
- **Password**: Auto-generated (secure)

### Custom Configuration
During setup, you can customize:
- Project name for Docker Compose
- Container name (must be unique)
- Username (lowercase, alphanumeric with underscore/hyphen)
- UID/GID (use defaults unless you have specific requirements)
- Port (8000-9999 range)
- Password (auto-generate recommended)
- Additional volume mounts

## 3. File Structure After Setup

```
jupyter-pytorch-cuda/
├── .env                    # Configuration (keep secure!)
├── docker-compose.yml     # Generated compose file
├── requirements.txt       # Python dependencies
├── start.sh               # Start container script
├── stop.sh                # Stop container script
├── workspace/             # Your working directory
│   ├── test_cuda_setup.ipynb
│   └── test_script.py
└── cache/                 # Hugging Face model cache
```

## 4. First Run

```bash
# Start the environment
./start.sh

# Access JupyterLab
# Open browser: http://localhost:8823 (or your chosen port)
# Enter the password from setup
```

## 5. Testing

### In JupyterLab:
1. Open `test_cuda_setup.ipynb`
2. Run all cells to verify:
   - CUDA functionality
   - Flash Attention
   - Cache configuration
   - Package availability

### In Terminal:
```bash
# Connect to container
docker compose exec cuda-jupyter bash

# Run test script
python test_script.py
```

## 6. Daily Usage

```bash
# Start when needed
./start.sh

# Stop when done
./stop.sh

# View logs if issues
docker compose logs -f

# Add new packages
# Edit requirements.txt, then:
docker compose up --build
```

## 7. Cache Management

```bash
# Check cache size
du -sh ./cache

# View downloaded models
ls -la ./cache/huggingface/hub/

# Backup cache
tar -czf my-models-backup.tar.gz ./cache
```

## 8. Troubleshooting

### Container won't start:
```bash
# Check logs
docker compose logs

# Verify GPU access
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

### Permission issues:
```bash
# Fix cache permissions
sudo chown -R $(id -u):$(id -g) ./cache
```

### Port conflicts:
- Choose different port during setup
- Check: `lsof -i :8823` (Linux/macOS) - replace 8823 with your chosen port

### Flash Attention issues:
```bash
# Rebuild container
docker compose up --build
```
