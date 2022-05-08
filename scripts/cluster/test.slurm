#!/bin/bash
#SBATCH --job-name=MAGUS_test
#SBATCH --time=12:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=100G

module load Python/3.9.5-GCCcore-10.3.0
module load CPMpy/0.9.5-foss-2021a

# Cwd
cd ~/MAGUS_project

# Minizinc shared libraries
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/user/brussel/102/vsc10248/MAGUS_project/MAGUS_CP/magus_tools/minizinc/lib

#python MAGUS_CP/magus.py --numprocs 8 
#                         -i $VSC_SCRATCH/data/unaligned/RV100_BBA0039_unaligned.fasta 
#                         -d $VSC_SCRATCH/RV100_BBA0039
#                         -o $VSC_SCRATCH/RV100_BBA0039/magus_result_minclusters.txt 
#                         --graphtracemethod minclusters
#mv results/RV100_BBA0039/graph/trace.txt results/RV100_BBA0039/graph/trace_minclusters.txt

python MAGUS_CP/magus.py --numprocs 8 
                         -d $VSC_SCRATCH/RV100_BBA0039 
                         -o $VSC_SCRATCH/RV100_BBA0039/magus_result_cp.txt 
                         --graphtracemethod cp
