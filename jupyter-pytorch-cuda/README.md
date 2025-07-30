# CUDA JupyterLab Docker Template

A comprehensive Docker template for setting up a CUDA-enabled JupyterLab environment using NVIDIA's official PyTorch container. This template provides a complete development environment for machine learning, deep learning, and AI research with GPU acceleration.

## 🚀 Features

### Core Components
- **Latest JupyterLab 4.x** with Python file editing and execution support
- **NVIDIA PyTorch Container** (nvcr.io/nvidia/pytorch:24.06-py3) with CUDA 12.4+ support
- **Flash Attention** pre-installed for efficient transformer models
- **Local Cache Control** for Hugging Face models and datasets
- **Comprehensive ML/DL Libraries** including PyTorch, Transformers, Datasets, and more

### Development Tools
- **Code Formatting**: Black, isort integration
- **Jupyter Extensions**: ipywidgets, code formatter, enhanced notebook support
- **Development Utilities**: Git, htop, vim, debugging tools
- **Python Environment**: Optimized for ML/AI development

### Cache Management
- **Local Cache Directory**: `./cache` folder for complete control over model downloads
- **Persistent Storage**: Models and datasets persist between container restarts
- **Space Management**: Easy monitoring and cleanup of cached models
- **Offline Capability**: Downloaded models available without internet connection

## 📋 Prerequisites

### System Requirements
- Docker Engine 20.10+ with Docker Compose
- NVIDIA GPU with compatible drivers (recommended: 470+)
- NVIDIA Container Toolkit installed
- At least 8GB GPU memory (recommended for most models)
- 20GB+ free disk space (for base image and cache)

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
# If using this template
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
- Volume mounting configuration

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
├── scripts/
│   ├── utils.sh            # Utility functions and colors
│   ├── validation.sh       # Input validation functions
│   ├── config.sh           # Configuration gathering
│   └── file-generators.sh  # File generation functions
├── workspace/              # JupyterLab workspace (mounted)
│   ├── test_cuda_setup.ipynb  # CUDA validation notebook
│   └── test_script.py      # Python test script
└── cache/                  # Local Hugging Face cache (mounted)
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

## 🎯 Cache Management

### Local Cache Benefits
- **Complete Control**: Manage which models are downloaded and stored
- **Offline Access**: Use downloaded models without internet connection
- **Space Management**: Easy monitoring and cleanup of cache directory
- **Reproducibility**: Consistent model versions across sessions
- **Backup Capability**: Cache directory can be backed up or shared

### Cache Directory Structure
```
cache/
├── huggingface/
│   ├── hub/              # Model files
│   ├── datasets/         # Dataset cache
│   └── transformers/     # Tokenizer cache
└── other-ml-caches/      # Other ML library caches
```

### Managing Cache
```bash
# View cache size
du -sh ./cache

# Clean specific model cache
rm -rf ./cache/huggingface/hub/models--<model-name>

# Backup cache
tar -czf cache-backup.tar.gz ./cache

# Restore cache
tar -xzf cache-backup.tar.gz
```

## 🧪 Testing Your Setup

### Automated Tests
The template includes comprehensive tests:

1. **Jupyter Notebook**: `workspace/test_cuda_setup.ipynb`
   - CUDA functionality verification
   - Flash Attention testing
   - Cache configuration validation
   - Package availability check
   - GPU performance benchmarking

2. **Python Script**: `workspace/test_script.py`
   - Command-line testing
   - Automated test suite
   - Environment validation

### Manual Verification
```python
# Test CUDA
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"GPU count: {torch.cuda.device_count()}")

# Test Flash Attention
import flash_attn
print(f"Flash Attention: {flash_attn.__version__}")

# Test cache
from transformers import AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained("microsoft/DialoGPT-small")
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

### Volume Mounting
During setup, you can add additional volumes:
```
./your-data:/home/jupyter/data
./your-models:/home/jupyter/models
```

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

2. **Permission Issues with Cache**
   ```bash
   # Fix cache permissions
   sudo chown -R $(id -u):$(id -g) ./cache
   ```

3. **Port Already in Use**
   ```bash
   # Check what's using the port
   lsof -i :8977
   # Or choose a different port during setup
   ```

4. **Out of GPU Memory**
   ```python
   # Clear cache and use smaller batch sizes
   torch.cuda.empty_cache()
   ```

5. **Flash Attention Import Error**
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

## 📝 License

This template is provided as-is for educational and research purposes. Please ensure compliance with:
- NVIDIA Container License (for base image)
- Individual package licenses
- Your organization's policies

## 🤝 Contributing

Feel free to submit issues and improvements to enhance this template for the machine learning community.

---

**Note**: This template is optimized for NVIDIA GPUs and CUDA development. For CPU-only environments, consider using the standard JupyterLab template instead.
