#!/bin/bash

# Set data directory to the SSD
DATA_DIR="/media/data/alidiff_data"
MODELS_DIR="/media/data/alidiff_models"

# Create directories
mkdir -p $DATA_DIR
mkdir -p $MODELS_DIR

# Create symlinks
ln -sf $DATA_DIR ./data
ln -sf $MODELS_DIR ./pretrained_models

# Install gdown for Google Drive downloads
pip install gdown

# Download preprocessed data files
echo "Downloading preprocessed data files..."
cd $DATA_DIR

# Download and extract the folder first
echo "Downloading data folder..."
gdown --folder "https://drive.google.com/drive/folders/1j21cc7-97TedKh_El5E34yI8o5ckI7eK"

# Move files to correct locations
mv crossdocked_v1.1_rmsd1.0_pocket10_processed_final.lmdb* ./
mv crossdocked_pocket10_pose_split.pt ./

# Download pretrained models folder
echo "Downloading pretrained model..."
cd $MODELS_DIR
gdown --folder "https://drive.google.com/drive/folders/1-ftaIrTXjWFhw3-0Twkrs5m0yX6CNarz"

# Move the pretrained model file
mv pretrained_ipdiff.pt ./

echo "Data download completed!" 