# JupyterLab Docker Setup

> A modular, secure solution for deploying JupyterLab environments in Docker containers with proper security considerations.

![JupyterLab Logo](https://jupyter.org/assets/homepage/main-logo.svg)

## 📋 Overview

This project provides an automated setup for JupyterLab environments in Docker with a focus on security, customization, and ease of use. Perfect for data scientists, researchers, and developers who need isolated Python environments.

## ✨ Key Features

- **🐍 Python 3.11** - Based on Debian 12 (Bookworm) with Python 3.11
- **📦 Modular Architecture** - Well-organized script components for easy maintenance
- **🔒 Security First** - Strong password enforcement and proper container isolation
- **📂 Flexible Storage** - Mount any number of workspace volumes with correct permissions
- **🔄 Conflict Prevention** - Automatic port availability checking
- **👤 User Permissions** - Proper UID/GID mapping for seamless file access
- **🐳 Docker Compose** - Simple management of container services

## 🗂️ Directory Structure

```
simple-jupyterlab/
├── setup.sh              # Main installation script
├── scripts/
│   ├── utils.sh          # Utility functions
│   ├── validation.sh     # Input validation functions
│   ├── config.sh         # Configuration functions
│   └── file-generators.sh # Template generation functions
├── requirements.txt      # Python package requirements
├── image/
│   └── Dockerfile        # Generated container definition
├── workspace/            # Default workspace directory
├── docker-compose.yml    # Generated service configuration
└── .env                  # Generated environment variables
```

## 🚀 Quick Start

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd simple-jupyterlab
   ```

2. Make the setup script executable and run it:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. Follow the interactive prompts to configure your environment

4. Access JupyterLab at `http://localhost:<configured-port>` using your password

## ⚙️ Configuration Options

The setup script will guide you through these configuration steps:

### 1. Project Configuration
- **Project Name:** Used for Docker Compose project naming
- **Container Name:** Identifier for your JupyterLab container

### 2. User Configuration
- **Username:** User inside the container (default: jupyter)
- **UID/GID:** User and group IDs for proper file permissions

### 3. Security Configuration
- **JupyterLab Port:** Web interface port (range: 8800-8899)
- **Password:** Secure access with strength requirements

### 4. Volume Configuration
- **Workspace Directory:** Primary work folder
- **Additional Volumes:** Extra directories to mount into the container

## 🔧 Advanced Customization

### Modifying Docker Configuration

To customize your deployment beyond the setup prompts:

1. **Edit Template Files** in `scripts/file-generators.sh`
2. **Change Python Version:** Modify the base image in the `scripts/file-generators.sh` to use a different Python version
3. **Be Careful with Variables** - Both environment variables (`$VARIABLE_NAME`) and bash variables
4. **Rebuild After Changes:**
   ```bash
   ./setup.sh
   ```

### Adding Python Packages

Customize your Python environment by adding packages in the requirements.txt file.


### Customizing JupyterLab Extensions

Add JupyterLab extensions by modifying the Dockerfile template:

```bash
# Install JupyterLab extensions
RUN pip install --no-cache-dir jupyterlab-git jupyterlab-drawio
```

## 🛡️ Security Considerations

- **Password Protection:** Strong password requirements enforced
- **Network Isolation:** Port conflict detection and container isolation
- **File Security:** Proper permission handling with UID/GID mapping
- **Update Regularly:** Security patches for base images

## 📋 Requirements

- Docker Engine (version 19.03+)
- Docker Compose (version 1.27+)
- Bash 4+ shell environment
- Internet connection for pulling images

## 🔍 Troubleshooting

### Common Issues

- **Permission Errors:** Verify UID/GID settings match your user
- **Port Conflicts:** Ensure no other services use your configured port
- **Container Not Starting:** Check logs with `docker logs <container_name>`

### Container Management

```bash
# Start the container
docker-compose up -d

# Stop the container
docker-compose down

# View logs
docker logs <container_name>

# Restart the container
docker restart <container_name>
```

## 📝 License

This project is released under the MIT License.

## 🛑 Disclaimer

This script is provided for educational and development purposes. Please test thoroughly before using in production environments.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
