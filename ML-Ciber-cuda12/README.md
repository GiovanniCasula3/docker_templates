# ML-Ciber Docker Environment

This repository provides a Docker environment pre-configured for machine learning, cyber analysis, and reverse engineering. It leverages NVIDIA CUDA for GPU acceleration and includes tools like JupyterLab, TensorFlow, PyTorch, and various analysis utilities.

## Features
- **GPU Acceleration**: Built upon the NVIDIA CUDA 12.2.2 image.
- **JupyterLab**: Ready-to-use interactive notebooks.
- **Development Tools**: Includes Python, Java, and essential libraries (e.g., scikit-learn, transformers, tensorflow-addons).
- **Security and User Configuration**: Runs as a non-root user with sudo access configured.
- **Enhanced Shell**: Pre-installed Zsh with Oh-My-Zsh customization.
- **Cybersecurity Tools**: Comes with pre-installed cybersecurity utilities for vulnerability scanning, network analysis, and reverse engineering. Tools include Nmap for network exploration, Wireshark for packet analysis, and additional reverse engineering utilities to assist in cyber forensics.

## File Structure
- **Dockerfile**: Located at `alex_mlwml/Dockerfile`. Builds the custom environment.
- **docker-compose.yml**: Configures and runs the container with the desired settings.
- **example_dotenv**: Sample environment variable file for configuration.

## Getting Started

### Prerequisites
- Docker Engine installed.
- Docker Compose installed.
- NVIDIA drivers and Docker’s NVIDIA runtime if using GPU features.

### Setup Instructions
1. **Clone the Repository**  
    Clone or download the repository to your local machine.

2. **Configure Environment Variables**  
    Copy the `example_dotenv` file to a new file named `.env` and adjust the variables as needed:
    - `UID` and `GID`: Your user and group IDs.
    - `USER`: The username to be created inside the container.
    - `JUPYTERLAB_CONTAINER_NAME`: Desired container name.
    - `JUPYTER_PASSWORD`: Secure token for accessing JupyterLab.
    - `JUPYTERLAB_PORT`: Host port for JupyterLab.

3. **Build and Run the Container**
    From the root directory of the repository, run:
    ```
    docker-compose up --build
    ```
    This command builds the Docker image and starts the container. The JupyterLab server will be accessible on the port specified in the `.env` file.

4. **Access JupyterLab**  
    Open your web browser and navigate to:
    ```
    http://localhost:8888
    ```
    Enter the token specified in the `.env` file when prompted.

## Usage
- **Development Workspace**  
  The container maps your project directory (via volume) to `/home/<USER>/work` inside the container. This allows you to edit files on your host machine using your preferred editor.

- **Adding More Tools**  
  The Dockerfile is modular. To include additional tools or libraries, modify the Dockerfile and rebuild the container.
  
- **Stopping the Container**
  Use:
  ```
  docker-compose down
  ```
  to stop and remove the running container.

## Troubleshooting
- **GPU Issues**: Make sure your system has compatible NVIDIA drivers and Docker’s NVIDIA runtime installed.
- **Permission Errors**: Ensure that the UID and GID values in the `.env` file align with your host system to prevent permission issues with mounted volumes.

## License
This project is provided for educational and experimental purposes. Ensure you comply with the licenses of all included tools and libraries.

Happy coding!