# CUDA JupyterLab Docker Template

A comprehensive Docker template for setting up a CUDA-enabled JupyterLab environment using NVIDIA's official PyTorch container. This template provides a complete development environment for machine learning, deep learning, and AI research with GPU acceleration and configurable persistent storage.

## 🚀 Features

### Core Components
- **Latest JupyterLab 4.x** with Python file editing and execution support
- **NVIDIA PyTorch Container** (nvcr.io/nvidia/pytorch:24.06-py3) with CUDA 12.4+ support
- **Flash Attention** pre-installed for efficient transformer models
- **Configurable Storage** for persistent data and model storage
- **Comprehensive ML/DL Libraries** including PyTorch, Transformers, Datasets, and more

### Development Tools
- **Code Formatting**: Black, isort integration
- **Jupyter Extensions**: ipywidgets, code formatter, enhanced notebook support
- **Development Utilities**: Git, htop, vim, debugging tools
- **Python Environment**: Optimized for ML/AI development

### Storage Management
- **Configurable Storage**: Choose your preferred storage location during setup
- **Persistent Storage**: Models and datasets persist between container restarts
- **Flexible Configuration**: Support for various storage backends
- **Offline Capability**: Downloaded models available without internet connection

## 📋 Prerequisites

### System Requirements
- Docker Engine 20.10+ with Docker Compose
- NVIDIA GPU with compatible drivers (recommended: 470+)
- NVIDIA Container Toolkit installed
- At least 8GB GPU memory (recommended for most models)
- **Storage location with sufficient space** (100GB+ recommended for models)

### NVIDIA Container Toolkit Installation
```bash
# Ubuntu/Debian
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

### Verify GPU Access
```bash
# Test NVIDIA Docker runtime
docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi
```

## 🛠️ Quick Start

### 1. Clone or Download
```bash
# Clone the template to your user directory
git clone <repository-url> jupyter-pytorch-cuda
cd jupyter-pytorch-cuda
```

### 2. Run Setup
```bash
chmod +x setup.sh
./setup.sh
```

The setup script will guide you through:
- Project and container naming
- User configuration (default: jupyter with UID 1000, GID 1000)
- Security settings (port and password)
- Storage configuration (customizable location)

### 3. Start the Environment
```bash
./start.sh
```

### 4. Access JupyterLab
Open your browser and navigate to:
```
http://localhost:<your-port>
```
Use the password you configured during setup.

## 📁 Directory Structure

### Local Project Directory (System Disk)
```
jupyter-pytorch-cuda/
├── setup.sh                 # Main setup script
├── start.sh                 # Container start script  
├── stop.sh                  # Container stop script
├── docker-compose.yml       # Generated Docker Compose configuration
├── requirements.txt         # Python package dependencies
├── .env                     # Environment variables (generated)
├── dockerimg/
│   └── Dockerfile          # NVIDIA PyTorch container configuration
└── scripts/
    ├── utils.sh            # Utility functions and colors
    ├── validation.sh       # Input validation functions
    ├── config.sh           # Configuration gathering
    └── file-generators.sh  # File generation functions
```

### Container Data (Persistent Storage - Only Accessible via JupyterLab)
```
<storage-location>/<project>/
├── workspace/              # JupyterLab workspace
│   ├── test_cuda_setup.ipynb  # CUDA validation notebook
│   └── test_script.py      # Python test script
└── cache/                  # Hugging Face and ML model cache
    └── huggingface/
        ├── hub/            # Model files
        ├── datasets/       # Dataset cache
        └── transformers/   # Tokenizer cache
```

## 📦 Included Packages

### Core ML/DL Libraries
- **PyTorch** (latest from NVIDIA container)
- **Transformers** for NLP models
- **Datasets** for data loading and processing
- **Accelerate** for distributed training
- **Flash Attention** for efficient attention mechanisms

### Data Science Stack
- **NumPy**, **Pandas** for data manipulation
- **Matplotlib**, **Seaborn**, **Plotly** for visualization
- **Scikit-learn** for traditional ML

### Development Tools
- **JupyterLab 4.x** with extensions
- **Black**, **isort** for code formatting
- **IPython** enhanced shell
- **Jupyter Server Proxy** for additional services

### Research Tools
- **Sentence Transformers** for embeddings
- **PEFT** for parameter-efficient fine-tuning
- **Optimum** for model optimization
- **Weights & Biases** for experiment tracking
- **TensorBoard** for visualization

## 🎯 Storage Management

### Configurable Storage Benefits
- **High Capacity**: Choose storage locations with sufficient space for models and datasets
- **System Protection**: Keeps root disk free for OS operations
- **Data Persistence**: Models and work persist between container restarts
- **Clean Separation**: Configuration files separate from data files
- **Easy Management**: All container data in chosen storage location

### Storage Directory Structure
```
<your-chosen-path>/<your-project>/
├── workspace/              # Your notebooks and scripts
├── cache/                  # Automatic model downloads
│   ├── huggingface/       # Hugging Face models
│   └── other-ml-caches/   # Other ML library caches
```

### Managing Storage
```bash
# View storage usage
du -sh <your-chosen-path>/<project>

# View available space
df -h <your-chosen-path>

# Backup project data
tar -czf backup.tar.gz <your-chosen-path>/<project>
```

## 🧪 Testing Your Setup

### Automated Tests
The template includes comprehensive tests accessible via JupyterLab:

1. **Jupyter Notebook**: `test_script.ipynb`
   - CUDA functionality verification
   - Flash Attention testing
   - Storage configuration validation
   - Package availability check
   - GPU performance benchmarking

### Manual Verification
```python
# Test CUDA (run in JupyterLab)
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"GPU count: {torch.cuda.device_count()}")

# Test Flash Attention
import flash_attn
print(f"Flash Attention: {flash_attn.__version__}")

# Test storage location
import os
print(f"Working directory: {os.getcwd()}")
print(f"Home directory: {os.path.expanduser('~')}")
```

## 🔧 Customization

### Adding Packages
Edit `requirements.txt` before running setup:
```txt
# Add your packages
your-package>=1.0.0
another-package
```

### Custom Dockerfile Modifications
Edit `dockerimg/Dockerfile` to add:
- System packages via `apt-get install`
- Custom Python packages
- Environment variables
- Additional configuration

## 📊 Performance Optimization

### GPU Memory Management
```python
# Clear GPU cache
torch.cuda.empty_cache()

# Monitor GPU memory
print(f"Memory allocated: {torch.cuda.memory_allocated() / 1024**3:.2f} GB")
print(f"Memory reserved: {torch.cuda.memory_reserved() / 1024**3:.2f} GB")
```

### Flash Attention Usage
```python
from flash_attn import flash_attn_func

# Use in your models for efficient attention computation
# Supports different attention mechanisms with optimized CUDA kernels
```

## 🛠️ Management Commands

```bash
# Start container
./start.sh

# Stop container  
./stop.sh

# View logs
docker compose logs -f

# Rebuild with new requirements
docker compose up --build

# Enter container shell
docker compose exec cuda-jupyter bash

# Monitor GPU usage
docker compose exec cuda-jupyter nvidia-smi
```

## 🐛 Troubleshooting

### Common Issues

1. **NVIDIA Docker Runtime Not Found**
   ```bash
   # Install NVIDIA Container Toolkit
   sudo apt-get update
   sudo apt-get install -y nvidia-container-toolkit
   sudo systemctl restart docker
   ```

2. **Storage Not Available**
   ```bash
   # Check if storage location is accessible
   source .env
   ls -la "$(dirname "$CONTAINER_BASE_PATH")"
   # Ensure the storage location has sufficient space and permissions
   ```

3. **Permission Issues with Storage**
   ```bash
   # Fix permissions (run from project directory)
   source .env
   sudo chown -R $UID:$GID "$CONTAINER_BASE_PATH"
   ```

4. **Port Already in Use**
   ```bash
   # Check what's using the port
   lsof -i :8823  # replace with your chosen port
   # Or choose a different port during setup
   ```

5. **Out of GPU Memory**
   ```python
   # Clear cache and use smaller batch sizes
   torch.cuda.empty_cache()
   ```

6. **Flash Attention Import Error**
   ```bash
   # Rebuild container - Flash Attention may need compilation
   docker compose up --build
   ```

### Performance Issues
- Ensure adequate GPU memory for your models
- Use mixed precision training (`torch.cuda.amp`)
- Monitor GPU utilization with `nvidia-smi`
- Consider model quantization for large models

## 🔒 Security Notes

- Container runs with specific UID/GID for proper file permissions
- JupyterLab requires password authentication
- Only necessary ports are exposed
- Use strong passwords (12+ characters with mixed case, numbers, symbols)
- Data stored in persistent storage is accessible only via JupyterLab interface

## 📝 License

This template is provided as-is for educational and research purposes. Please ensure compliance with:
- NVIDIA Container License (for base image)
- Individual package licenses
- Your organization's policies

## 🤝 Contributing

Feel free to submit issues and improvements to enhance this template for the machine learning community.

---

**Note**: This template is optimized for NVIDIA GPUs and CUDA development. Container data is automatically stored in your configured storage location to preserve system disk space and provide persistent storage for ML models and datasets.