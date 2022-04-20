#!/bin/bash
#SBATCH --job-name=MAGUS
#SBATCH --time=12:00:00
#SBATCH --partition=batch
#SBATCH --cpus=24
#SBATCH --mem=100G

module load Python/3.8.6-GCCcore-10.2.0

# Cwd
cd ~/MAGUS_project

# Make unaligned data
mkdir data/unaligned
python data/unalign.py data/aligned/RV100_BBA0039_true.fasta > data/unaligned/RV100_BBA0039_scrambled.fasta

#-
# Default tracemethod runs (tracemethod)
#-

python MAGUS_CP/magus.py --numprocs 24 -i data/unaligned/RV100_BBA0039_scrambled.fasta -d results/RV100_BBA0039 -o results/RV100_BBA0039/magus_result_minclusters.txt

#-
# Other tracemethod runs (fm, mwtgreedy, rg, mwtsearch)
#-

python MAGUS_CP/magus.py --numprocs 24 -d results/RV100_BBA0039 -o results/RV100_BBA0039/magus_result_fm.txt --graphtracemethod fm
python MAGUS_CP/magus.py --numprocs 24 -d results/RV100_BBA0039 -o results/RV100_BBA0039/magus_result_fm.txt --graphtracemethod mwtgreedy
python MAGUS_CP/magus.py --numprocs 24 -d results/RV100_BBA0039 -o results/RV100_BBA0039/magus_result_fm.txt --graphtracemethod rg 
python MAGUS_CP/magus.py --numprocs 24 -d results/RV100_BBA0039 -o results/RV100_BBA0039/magus_result_fm.txt --graphtracemethod mwtsearch 
