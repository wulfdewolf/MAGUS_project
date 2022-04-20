#!/bin/bash
#SBATCH --job-name=MAGUS
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=128G

# Cwd
cd ~/MAGUS_project

# Make unaligned data
python data/unalign.py data/aligned/RV100_BBA0039_true.fasta > data/unaligned/RV100_BBA0039_scrambled.fasta" 

#-
# Default tracemethod runs (tracemethod)
#-

python MAGUS_CP/magus.py --numprocs 24 -i data/unaligned/RV100_BBA0039_scrambled.fasta -d results/RV100_BBA0039 -o results/RV100_BBA0039/magus_result_minclusters.txt"

#-
# Other tracemethod runs (fm, mwtgreedy, rg, mwtsearch)
#-

python MAGUS_CP/magus.py --numprocs 24 -d results/RV100_BBA0039 -o results/RV100_BBA0039/magus_result_fm.txt" --graphtracemethod fm
