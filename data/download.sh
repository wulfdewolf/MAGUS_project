#!/bin/bash

# Download
wget -P data https://databank.illinois.edu/datafiles/u373n/download

# Unzip
unzip data/download -d data

# Cleanup
rm -rf data/download

# Make aligned folder
mv data/Datasets data/aligned

# Flatten
cd data/aligned
for family in * ; do
   echo "$family"
   find ${family//$'\n'/} -type f -exec sh -c 'new=$(echo "{}" | tr "/" "-" | tr " " "_"); mv "{}" "$new"' \;
done
cd ../..
find data/aligned -type f ! -name "*.fasta" -exec rm {} \;
rm -rf data/aligned/*/