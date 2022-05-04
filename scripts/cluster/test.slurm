#!/bin/bash
#SBATCH --job-name=MAGUS_test
#SBATCH --time=12:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100G

module load Python/3.9.5-GCCcore-10.3.0
module load CPMpy/0.9.5-foss-2021a

# Cwd
cd ~/MAGUS_project

python MAGUS_CP/magus.py -d RV100_BBA0039 -o res.txt --graphtracemethod cp
