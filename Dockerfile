FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# Avoid timezone prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3.8 \
    python3.8-dev \
    python3-pip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic links for python
RUN ln -sf /usr/bin/python3.8 /usr/bin/python && \
    ln -sf /usr/bin/python3.8 /usr/bin/python3

# Install pip
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

# Install PyTorch and related packages
RUN pip install torch==2.0.1+cu117 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu117

# Install PyG and its dependencies
RUN pip install torch-geometric
RUN pip install pyg_lib torch_scatter torch_sparse torch_cluster torch_spline_conv -f https://data.pyg.org/whl/torch-2.0.0+cu117.html

# Install other dependencies
RUN pip install rdkit \
    openbabel-wheel \
    tensorboard \
    pyyaml \
    easydict \
    lmdb \
    scikit-learn \
    pandas \
    matplotlib \
    seaborn

# Install Vina Docking packages
RUN pip install meeko==0.1.dev3 scipy pdb2pqr==3.6.2 vina==1.2.2
RUN pip install git+https://github.com/Valdes-Tresanco-MS/AutoDockTools_py3

# Set working directory
WORKDIR /workspace

# Copy the current directory contents into the container
COPY . /workspace/

ENV PYTHONPATH=/workspace:$PYTHONPATH

# Verify CUDA installation
RUN python -c "import torch; print('PyTorch version:', torch.__version__); print('CUDA available:', torch.cuda.is_available())" 