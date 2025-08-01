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
- **Storage**: Configurable storage location for persistent data

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

### Local Project Directory (System Disk)
```
jupyter-pytorch-cuda/
├── .env                    # Configuration (keep secure!)
├── docker-compose.yml     # Generated compose file
├── requirements.txt       # Python dependencies
├── start.sh               # Start container script
├── stop.sh                # Stop container script
├── dockerimg/             # Docker configuration
│   └── Dockerfile
└── scripts/               # Setup scripts
```

### Container Data (Configurable Storage - JupyterLab Access Only)
```
<storage-location>/<project>/
├── workspace/             # Your working directory
│   ├── test_cuda_setup.ipynb
│   └── test_script.py
└── cache/                 # Hugging Face model cache
    └── huggingface/
        ├── hub/
        ├── datasets/
        └── transformers/
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
1. Open `test_script.ipynb`
2. Run all cells to verify:
   - CUDA functionality
   - Flash Attention
   - Storage configuration
   - Package availability

### In Terminal:
```bash
# Connect to container
docker compose exec cuda-jupyter bash
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

## 7. Storage Management

### Configurable Storage Benefits
- **High Capacity**: Choose storage locations with sufficient space for models
- **System Protection**: Root disk stays free for OS
- **Persistence**: Data survives container restarts
- **Clean Separation**: Config vs. data files

### Storage Commands
```bash
# Check storage usage 
du -sh <your-storage-path>/<project>

# View available space
df -h <your-storage-path>

# Backup project data
tar -czf my-project-backup.tar.gz <your-storage-path>/<project>

# View downloaded models (from JupyterLab terminal)
ls -la ~/.cache/huggingface/hub/
```

## 8. Troubleshooting

### Container won't start:
```bash
# Check logs
docker compose logs

# Verify GPU access
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi

# Check storage location availability
ls -la <your-storage-path>
```

### Storage issues:
```bash
# Verify storage location is accessible
df -h <your-storage-path>

# Check permissions (from project directory)
source .env
sudo ls -la <your-storage-path>/

# Fix permissions if needed
sudo chown -R $UID:$GID <your-storage-path>/$COMPOSE_PROJECT_NAME
```

### Port conflicts:
- Choose different port during setup
- Check: `lsof -i :8823` (Linux/macOS) - replace 8823 with your chosen port

### Storage space issues:
```bash
# Check storage space
df -h <your-storage-path>

# Clean old models (from JupyterLab terminal)
# Be careful - this deletes downloaded models
rm -rf ~/.cache/huggingface/hub/models--[unused-model-name]
```

## 9. Working with the Environment

### File Access
- **JupyterLab**: Full access to workspace and cache
- **SSH/Local**: Only configuration files visible
- **Data**: All work data stored in configured storage location automatically

### Model Downloads
```python
# Models automatically download to configured cache
from transformers import AutoModel
model = AutoModel.from_pretrained("bert-base-uncased")
# Stored in <storage-location>/<project>/cache/
```

### Workspace Organization
```python
# In JupyterLab, organize your work:
# ~/workspace/notebooks/     - Jupyter notebooks
# ~/workspace/scripts/       - Python scripts  
# ~/workspace/data/          - Data files
# ~/workspace/models/        - Custom model files
```

## 10. Best Practices

### Development Workflow
1. **Start container** with `./start.sh`
2. **Work in JupyterLab** - all files auto-saved to persistent storage
3. **Stop container** with `./stop.sh` when done
4. **Data persists** - no need to backup between sessions

### Storage Management
- **Monitor storage usage** periodically
- **Clean unused models** when space runs low
- **Backup important projects** before major changes
- **Keep configuration light** - only essentials in project directory

### Performance Tips
- **Use persistent storage** for all large data/models (automatic)
- **Monitor GPU memory** in JupyterLab
- **Use mixed precision** for large models
- **Clear GPU cache** between experiments