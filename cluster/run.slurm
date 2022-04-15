#!/bin/bash
#SBATCH --job-name=MAGUS
#SBATCH --ntasks=4
#SBTACH --cpus-per-task=16

module load Python/3.9.5-GCCcore-10.3.0
module load parallel/20210622-GCCcore-10.3.0

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Run first one
srun -N1 -n16 --exclusive --wait python3 MAGUS_CP/magus.py -d results/minclusters -i example/unaligned_sequences.txt -o magus_result.txt --graphtracemethod minclusters

# Define srun arguments
srun = "srun -N1 -n16 --exclusive"

# Define parallel arguments
parallel="parallel -N 1 -j $SLURM_NTASKS --joblog runtask.log --resume"

# Run others based on first
$parallel "$srun python3 MAGUS_CP/magus.py -d results/{1} -s results/minclusters/subalignments -b results/minclusters/backbones -o magus_result.txt --graphtracemethod {1}" ::: {"fm", "mwtgreedy", "rg", "mvg_search"}