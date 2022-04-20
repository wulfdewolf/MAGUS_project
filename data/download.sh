#!/bin/bash

# Download
wget -P data https://databank.illinois.edu/datafiles/u373n/download

# Unzip
unzip data/download -d data

# Cleanup
rm -rf data/download

# Make aligned folder
mkdir data/aligned

# Copy to aligned
for file in $(ls data/Datasets/balibase); do
    cp data/Datasets/balibase/$file/model/true.fasta data/aligned/${file}_true.fasta
done