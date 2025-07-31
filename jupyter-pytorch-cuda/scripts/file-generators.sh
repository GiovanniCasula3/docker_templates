#!/bin/bash

# Function to generate the .env file
generate_env_file() {
    cat > .env << EOF
# Project configuration
COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME

# User configuration
UID=$CONTAINER_UID
GID=$CONTAINER_GID
USERNAME=$USERNAME

# JupyterLab configuration
CONTAINER_NAME=$CONTAINER_NAME
JUPYTERLAB_PORT=$JUPYTERLAB_PORT
JUPYTER_PASSWORD=$JUPYTER_PASSWORD
EOF
    
    echo -e "${GREEN}.env file created successfully${NC}"
}

# Function to generate the docker-compose.yml file
generate_docker_compose() {
    # Construct volumes section for docker-compose.yml
    VOLUMES_CONFIG=""
    for VOLUME in "${VOLUMES[@]}"; do
        VOLUMES_CONFIG+="            - ${VOLUME}\n"
    done
    VOLUMES_CONFIG=${VOLUMES_CONFIG%\\n}
    
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  cuda-jupyter:
    build:
      context: .
      dockerfile: dockerimg/Dockerfile
      args:
        USERNAME: \${USERNAME}
        USER_UID: \${UID}
        USER_GID: \${GID}
        JUPYTERLAB_PORT: \${JUPYTERLAB_PORT}
    image: cuda-jupyter-\${CONTAINER_NAME}:latest
    container_name: \${CONTAINER_NAME}
    ports:
      - "\${JUPYTERLAB_PORT}:\${JUPYTERLAB_PORT}"
    volumes:
$(echo -e "$VOLUMES_CONFIG")
    environment:
      - JUPYTER_TOKEN=\${JUPYTER_PASSWORD}
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=compute,utility
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped
    stdin_open: true
    tty: true
    networks:
      - cuda-jupyter-network

networks:
  cuda-jupyter-network:
    driver: bridge
EOF

    echo -e "${GREEN}docker-compose.yml created successfully${NC}"
}

# Function to generate the Dockerfile
generate_dockerfile() {
    cat > dockerimg/Dockerfile << EOF
# Use NVIDIA's official PyTorch container (has all dependencies pre-configured)
FROM nvcr.io/nvidia/pytorch:24.06-py3

# Update system packages and install required tools
RUN apt-get update && apt-get install -y \
    vim \
    curl \
    wget \
    tini \
    zip \
    unzip \
    sudo \
    git \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Install ninja for faster compilation
RUN pip install ninja

# Copy requirements and install Python packages
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt

# Install flash-attn (should work out of the box with this container)
ENV MAX_JOBS=4
RUN pip install flash-attn --no-build-isolation

# User creation arguments
ARG USERNAME=jupyter
ARG USER_UID=1000
ARG USER_GID=1000
ARG JUPYTERLAB_PORT=8977

# Create user and group
RUN groupadd -g $USER_GID $USERNAME || true && \
    useradd -m -u $USER_UID -g $USER_GID -s /bin/bash $USERNAME || true

# Add user to sudo group
RUN usermod -aG sudo $USERNAME 2>/dev/null || true

# Set environment variable for runtime
ENV USERNAME=$USERNAME

# Create directories with correct permissions
RUN mkdir -p /home/$USERNAME/workspace && \
    mkdir -p /home/$USERNAME/.cache && \
    chown -R $USERNAME:$USER_GID /home/$USERNAME

# Switch to user
USER $USERNAME
WORKDIR /home/$USERNAME/workspace

# Set up JupyterLab configuration with Python file support
RUN jupyter lab --generate-config && \
    echo "c.ServerApp.allow_origin = '*'" >> /home/\$USERNAME/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.allow_root = True" >> /home/\$USERNAME/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.ip = '0.0.0.0'" >> /home/\$USERNAME/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.open_browser = False" >> /home/\$USERNAME/.jupyter/jupyter_lab_config.py && \
    echo "c.ServerApp.port = $JUPYTERLAB_PORT" >> /home/\$USERNAME/.jupyter/jupyter_lab_config.py

# Expose port
EXPOSE $JUPYTERLAB_PORT

# Use tini as entrypoint
ENTRYPOINT ["/usr/bin/tini", "--"]

# Start JupyterLab with enhanced configuration
CMD ["sh", "-c", "jupyter lab --ip=0.0.0.0 --port=$JUPYTERLAB_PORT --no-browser --notebook-dir=/home/\$USERNAME/workspace --allow-root"]
EOF

    echo -e "${GREEN}Dockerfile created successfully${NC}"
}

# Function to generate requirements.txt
generate_requirements() {
    cat > requirements.txt << 'EOF'
# Core ML/DL libraries (versions will be managed by NVIDIA container)
# These are already included in the base image but listed for reference
# torch
# torchvision 
# torchaudio
# transformers
# datasets

# Jupyter essentials (upgraded versions)
jupyterlab>=4.0
ipywidgets>=8.0
nbconvert>=7.0
ipykernel>=6.0
jupyterlab-code-formatter>=2.0
black>=23.0
isort>=5.0

# Data science essentials
numpy>=1.24
pandas>=2.0
matplotlib>=3.7
seaborn>=0.12
plotly>=5.0
scikit-learn>=1.3

# Deep Learning and NLP
accelerate>=0.20
sentence-transformers>=2.2
einops>=0.6
safetensors>=0.3

# Development and utilities
tqdm>=4.64
requests>=2.28
pillow>=9.0
opencv-python>=4.7
jupyter-server-proxy>=4.0

# Monitoring and logging
wandb>=0.15
tensorboard>=2.13

# Additional useful packages for ML research
datasets>=2.12
evaluate>=0.4
peft>=0.4
bitsandbytes>=0.41
optimum>=1.8

# Optional: Hugging Face Hub utilities
huggingface-hub>=0.15
EOF

    echo -e "${GREEN}requirements.txt created successfully${NC}"
}

# Function to generate test files
generate_test_files() {
    # Create test notebook
    mkdir -p workspace
    cat > workspace/test_cuda_setup.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# CUDA and Flash Attention Test\n",
    "\n",
    "This notebook tests the CUDA setup, flash_attention installation, and cache configuration."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import torch\n",
    "import sys\n",
    "import os\n",
    "\n",
    "print(f\"Python version: {sys.version}\")\n",
    "print(f\"PyTorch version: {torch.__version__}\")\n",
    "print(f\"CUDA available: {torch.cuda.is_available()}\")\n",
    "if torch.cuda.is_available():\n",
    "    print(f\"CUDA version: {torch.version.cuda}\")\n",
    "    print(f\"GPU count: {torch.cuda.device_count()}\")\n",
    "    for i in range(torch.cuda.device_count()):\n",
    "        print(f\"GPU {i}: {torch.cuda.get_device_name(i)}\")\n",
    "        print(f\"  Memory: {torch.cuda.get_device_properties(i).total_memory / 1024**3:.1f} GB\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Test flash attention\n",
    "try:\n",
    "    import flash_attn\n",
    "    print(f\"Flash Attention version: {flash_attn.__version__}\")\n",
    "    print(\"✓ Flash Attention successfully imported!\")\n",
    "    \n",
    "    # Test flash attention functionality\n",
    "    from flash_attn import flash_attn_func\n",
    "    print(\"✓ Flash Attention functions available!\")\n",
    "except ImportError as e:\n",
    "    print(f\"✗ Flash Attention import failed: {e}\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Test cache directory and Hugging Face integration\n",
    "import os\n",
    "from pathlib import Path\n",
    "\n",
    "cache_dir = Path.home() / \".cache\"\n",
    "hf_cache_dir = cache_dir / \"huggingface\"\n",
    "\n",
    "print(f\"Cache directory: {cache_dir}\")\n",
    "print(f\"Cache exists: {cache_dir.exists()}\")\n",
    "print(f\"Cache writable: {os.access(cache_dir, os.W_OK)}\")\n",
    "print(f\"HF cache directory: {hf_cache_dir}\")\n",
    "\n",
    "# Test Hugging Face model download with local cache\n",
    "try:\n",
    "    from transformers import AutoTokenizer\n",
    "    print(\"\\n--- Testing Hugging Face Cache ---\")\n",
    "    tokenizer = AutoTokenizer.from_pretrained(\"microsoft/DialoGPT-small\")\n",
    "    print(\"✓ Hugging Face cache working - model downloaded successfully!\")\n",
    "    print(f\"✓ Cache directory contents: {list(hf_cache_dir.iterdir()) if hf_cache_dir.exists() else 'Empty'}\")\n",
    "except Exception as e:\n",
    "    print(f\"✗ Hugging Face cache error: {e}\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# CUDA performance test\n",
    "if torch.cuda.is_available():\n",
    "    print(\"--- CUDA Performance Test ---\")\n",
    "    device = torch.device('cuda')\n",
    "    \n",
    "    # Matrix multiplication test\n",
    "    size = 2048\n",
    "    x = torch.randn(size, size, device=device, dtype=torch.float16)\n",
    "    y = torch.randn(size, size, device=device, dtype=torch.float16)\n",
    "    \n",
    "    # Warmup\n",
    "    for _ in range(3):\n",
    "        _ = torch.mm(x, y)\n",
    "    torch.cuda.synchronize()\n",
    "    \n",
    "    # Benchmark\n",
    "    import time\n",
    "    start_time = time.time()\n",
    "    for _ in range(10):\n",
    "        z = torch.mm(x, y)\n",
    "    torch.cuda.synchronize()\n",
    "    end_time = time.time()\n",
    "    \n",
    "    print(f\"✓ Matrix multiplication ({size}x{size}) successful!\")\n",
    "    print(f\"✓ Average time: {(end_time - start_time) / 10 * 1000:.2f} ms\")\n",
    "    print(f\"✓ Result shape: {z.shape}\")\n",
    "    print(f\"✓ Result device: {z.device}\")\n",
    "    print(f\"✓ GPU memory used: {torch.cuda.memory_allocated() / 1024**3:.2f} GB\")\n",
    "else:\n",
    "    print(\"CUDA not available, skipping GPU test\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Test installed packages\n",
    "packages_to_test = [\n",
    "    'torch', 'transformers', 'datasets', 'accelerate', \n",
    "    'pandas', 'numpy', 'matplotlib', 'seaborn', 'plotly',\n",
    "    'scikit-learn', 'sentence_transformers', 'wandb'\n",
    "]\n",
    "\n",
    "print(\"--- Package Versions ---\")\n",
    "for package in packages_to_test:\n",
    "    try:\n",
    "        module = __import__(package)\n",
    "        version = getattr(module, '__version__', 'Unknown')\n",
    "        print(f\"✓ {package}: {version}\")\n",
    "    except ImportError:\n",
    "        print(f\"✗ {package}: Not installed\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.10.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

    # Create test Python file
    cat > workspace/test_script.py << 'EOF'
#!/usr/bin/env python3
"""
Test Python script for CUDA JupyterLab execution
Tests CUDA functionality, cache configuration, and package availability
"""

import torch
import numpy as np
import sys
from pathlib import Path

def test_cuda():
    """Test CUDA functionality"""
    print("=== CUDA Test ===")
    print(f"PyTorch version: {torch.__version__}")
    print(f"CUDA available: {torch.cuda.is_available()}")
    
    if torch.cuda.is_available():
        print(f"CUDA version: {torch.version.cuda}")
        print(f"GPU count: {torch.cuda.device_count()}")
        for i in range(torch.cuda.device_count()):
            print(f"GPU {i}: {torch.cuda.get_device_name(i)}")
        
        # Simple GPU computation
        x = torch.randn(1000, 1000, device='cuda')
        y = torch.randn(1000, 1000, device='cuda')
        result = torch.matmul(x, y)
        print(f"✓ GPU computation successful! Result shape: {result.shape}")
        return True
    else:
        print("✗ CUDA not available")
        return False

def test_cache():
    """Test cache configuration"""
    print("\n=== Cache Test ===")
    cache_dir = Path.home() / ".cache"
    print(f"Cache directory: {cache_dir}")
    print(f"Cache exists: {cache_dir.exists()}")
    print(f"Cache writable: {cache_dir.is_dir() and cache_dir.exists()}")
    
    try:
        from transformers import AutoTokenizer
        tokenizer = AutoTokenizer.from_pretrained("microsoft/DialoGPT-small")
        print("✓ Hugging Face cache working!")
        return True
    except Exception as e:
        print(f"✗ Cache error: {e}")
        return False

def test_flash_attention():
    """Test Flash Attention"""
    print("\n=== Flash Attention Test ===")
    try:
        import flash_attn
        print(f"✓ Flash Attention version: {flash_attn.__version__}")
        
        from flash_attn import flash_attn_func
        print("✓ Flash Attention functions available!")
        return True
    except ImportError as e:
        print(f"✗ Flash Attention not available: {e}")
        return False

def test_packages():
    """Test important packages"""
    print("\n=== Package Test ===")
    packages = {
        'torch': 'PyTorch',
        'transformers': 'Transformers',
        'datasets': 'Datasets', 
        'accelerate': 'Accelerate',
        'pandas': 'Pandas',
        'numpy': 'NumPy',
        'matplotlib': 'Matplotlib',
        'sklearn': 'Scikit-learn'
    }
    
    success_count = 0
    for package, name in packages.items():
        try:
            module = __import__(package)
            version = getattr(module, '__version__', 'Unknown')
            print(f"✓ {name}: {version}")
            success_count += 1
        except ImportError:
            print(f"✗ {name}: Not available")
    
    print(f"\nPackages available: {success_count}/{len(packages)}")
    return success_count == len(packages)

def main():
    """Main test function"""
    print("="*50)
    print("CUDA JupyterLab Environment Test")
    print("="*50)
    
    tests = [
        ("CUDA", test_cuda),
        ("Cache", test_cache), 
        ("Flash Attention", test_flash_attention),
        ("Packages", test_packages)
    ]
    
    results = []
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"✗ {test_name} test failed with error: {e}")
            results.append((test_name, False))
    
    print("\n" + "="*50)
    print("Test Summary")
    print("="*50)
    for test_name, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{test_name}: {status}")
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Environment is ready for CUDA development.")
    else:
        print("⚠️  Some tests failed. Check the output above for details.")

if __name__ == "__main__":
    main()
EOF

    echo -e "${GREEN}Test files created successfully${NC}"
}

# Function to generate control scripts
generate_control_scripts() {
    # Create start.sh script
    cat > start.sh << EOF
#!/bin/bash

echo -e "${CYAN}Starting CUDA JupyterLab container (NVIDIA Edition)...${NC}"

# Source environment variables
source .env

# Ensure cache directory has correct permissions
if [ -d "./cache" ]; then
    echo "Setting cache permissions..."
    chown -R \$UID:\$GID ./cache 2>/dev/null || chmod -R 777 ./cache
fi

# Ensure workspace directory exists
mkdir -p ./workspace

# Build and start the container
echo "Building and starting container..."
docker compose up --build -d

if [ \$? -eq 0 ]; then
    echo -e "\n${GREEN}Container started successfully!${NC}"
    echo -e "Access JupyterLab at: ${CYAN}http://localhost:\$JUPYTERLAB_PORT${NC}"
    echo -e "Password: ${CYAN}\$JUPYTER_PASSWORD${NC}"
    echo -e "\n${YELLOW}Features available:${NC}"
    echo -e "  ✓ Latest JupyterLab 4.x with Python file support"
    echo -e "  ✓ NVIDIA PyTorch container with CUDA support"
    echo -e "  ✓ Flash-attention pre-installed"
    echo -e "  ✓ Local Hugging Face cache control (./cache)"
    echo -e "  ✓ Code formatting and Python execution"
    echo -e "  ✓ ML/DL libraries: PyTorch, Transformers, Datasets, etc."
    echo -e "\n${YELLOW}Test your setup:${NC}"
    echo -e "  - Open test_cuda_setup.ipynb in JupyterLab"
    echo -e "  - Run test_script.py from the terminal"
    echo -e "\n${YELLOW}Commands:${NC}"
    echo -e "  View logs: ${CYAN}docker compose logs -f${NC}"
    echo -e "  Stop: ${CYAN}./stop.sh${NC} or ${CYAN}docker compose down${NC}"
    echo -e "  Rebuild: ${CYAN}docker compose up --build${NC}"
    echo -e "\n${YELLOW}Cache directory:${NC}"
    echo -e "  Models will be stored in ${CYAN}./cache${NC} for local control"
    echo -e "  This allows you to manage model downloads and storage"
else
    echo -e "\n${RED}Failed to start container. Check logs with:${NC}"
    echo -e "${CYAN}docker compose logs${NC}"
    exit 1
fi
EOF

    # Create stop.sh script
    cat > stop.sh << 'EOF'
#!/bin/bash

# Color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Stopping CUDA JupyterLab container...${NC}"

# Source environment variables to get container name
if [ -f .env ]; then
    source .env
    echo -e "Stopping container: ${CYAN}$CONTAINER_NAME${NC}"
else
    echo -e "${YELLOW}Warning: .env file not found, using docker compose down${NC}"
fi

docker compose down

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Container stopped successfully.${NC}"
    echo -e "Cache directory ${CYAN}./cache${NC} preserved with your models."
    echo -e "To start again, run: ${CYAN}./start.sh${NC}"
else
    echo -e "${RED}Error stopping container. You may need to stop it manually:${NC}"
    echo -e "${CYAN}docker stop $CONTAINER_NAME${NC}"
fi
EOF

    chmod +x start.sh
    chmod +x stop.sh
    
    echo -e "${GREEN}Control scripts created successfully${NC}"
}
