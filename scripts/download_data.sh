#!/bin/bash

# Set data directory to the SSD
DATA_DIR="/media/data/alidiff_data"
MODELS_DIR="/media/data/alidiff_models"

# Create directories
mkdir -p $DATA_DIR/crossdocked_v1.1_rmsd1.0_pocket10
mkdir -p $MODELS_DIR

# Create symlinks
ln -sf $DATA_DIR ./data
ln -sf $MODELS_DIR ./pretrained_models

# Install gdown for Google Drive downloads
pip install gdown

# Function to download with retry
download_with_retry() {
    local file_id=$1
    local output_path=$2
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        echo "Downloading to $output_path (attempt $((retry + 1)))"
        if gdown "https://drive.google.com/uc?id=$file_id" -O "$output_path"; then
            return 0
        fi
        retry=$((retry + 1))
        echo "Download failed, waiting 30 seconds before retry..."
        sleep 30
    done
    return 1
}

cd $DATA_DIR/crossdocked_v1.1_rmsd1.0_pocket10

# Download required files one by one
echo "Downloading processed LMDB file..."
download_with_retry "1CUEh7HRaiagqDZ2ZyQxes49dQp9YUXaP" "crossdocked_v1.1_rmsd1.0_pocket10_processed_final.lmdb"

echo "Downloading pose split file..."
download_with_retry "1BoKFqffFBsdhfukI6sJ4AFEI9giAZy9n" "crossdocked_pocket10_pose_split.pt"

echo "Downloading split by name file..."
download_with_retry "1jzvUEzGDkC0WrsqrUsX6cYkl1P8rCFJJ" "split_by_name.pt"

# Download pretrained model
cd $MODELS_DIR
echo "Downloading pretrained model..."
download_with_retry "1DCbkVJ_Ib0tOD1QqNT1QYdzrVpZLeZQF" "pretrained_ipdiff.pt"

echo "Data download completed!" 