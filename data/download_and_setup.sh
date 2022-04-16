#!/bin/bash

# Download
wget -P data https://databank.illinois.edu/datafiles/u373n/download

# Unzip
unzip data/download 

# Cleanup
rm -rf data/download

# Copy to aligned
for file in $(ls data/Datasets/balibase); do
    cp data/Datasets/balibase/$file/model/true.fasta data/aligned/${file}_true.fasta
done