#!/bin/bash

# Exit on error
set -e

echo "Starting environment setup..."

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo "conda could not be found. Please install Anaconda or Miniconda first."
    exit 1
fi

# Source conda for proper activation in script
CONDA_BASE=$(conda info --base)
source "$CONDA_BASE/etc/profile.d/conda.sh"

# Function to check if a conda package is installed
package_installed() {
    conda list -n target | grep -q "^$1 "
}

# Check if environment exists
if conda env list | grep -q "^target "; then
    echo "Environment 'target' already exists. Activating..."
    conda activate target
else
    echo "Creating conda environment 'target' with Python 3.8..."
    conda create -n target python=3.8 -y
    conda activate target
fi

# Install PyTorch with CUDA support if not installed
if ! package_installed "pytorch"; then
    echo "Installing PyTorch with CUDA support..."
    conda install pytorch==2.0.1 pytorch-cuda=11.7 -c pytorch -c nvidia -y
else
    echo "PyTorch already installed."
fi

# Install PyG if not installed
if ! package_installed "pyg"; then
    echo "Installing PyG..."
    conda install pyg -c pyg -y
else
    echo "PyG already installed."
fi

# Function to check if a pip package is installed
pip_package_installed() {
    pip list | grep -q "^$1 "
}

# Install PyG libraries
echo "Installing PyG libraries..."
for package in pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv; do
    if ! pip_package_installed "$package"; then
        pip install "$package" -f https://data.pyg.org/whl/torch-2.0.0+cu117.html
    else
        echo "$package already installed."
    fi
done

# Install other dependencies
echo "Installing additional dependencies..."
for package in rdkit openbabel tensorboard pyyaml easydict python-lmdb; do
    if ! package_installed "$package"; then
        conda install "$package" -c conda-forge -y
    else
        echo "$package already installed."
    fi
done

# Install Vina Docking packages
echo "Installing Vina Docking packages..."
for package in meeko scipy pdb2pqr vina; do
    if ! pip_package_installed "$package"; then
        if [ "$package" = "meeko" ]; then
            pip install meeko==0.1.dev3
        elif [ "$package" = "vina" ]; then
            pip install vina==1.2.2
        else
            pip install "$package"
        fi
    else
        echo "$package already installed."
    fi
done

# Install AutoDockTools
if ! pip_package_installed "AutoDockTools"; then
    echo "Installing AutoDockTools..."
    python -m pip install git+https://github.com/Valdes-Tresanco-MS/AutoDockTools_py3
else
    echo "AutoDockTools already installed."
fi

# Verify CUDA installation
echo "Verifying CUDA installation..."
python - <<EOF
import torch
print("\nPyTorch version:", torch.__version__)
print("CUDA available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("CUDA version:", torch.version.cuda)
    print("CUDA device count:", torch.cuda.device_count())
    print("Current CUDA device:", torch.cuda.current_device())
    print("CUDA device name:", torch.cuda.get_device_name(0))
else:
    print("WARNING: CUDA is not available!")
EOF

echo -e "\nEnvironment setup completed!"
echo "To activate the environment, run: conda activate target" 