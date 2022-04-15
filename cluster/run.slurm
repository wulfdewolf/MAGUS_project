#!/bin/bash
#SBATCH --job-name=MAGUS
#SBATCH --ntasks=4
#SBTACH --cpus-per-task=16

module load Python/3.9.5-GCCcore-10.3.0
module load parallel/20210622-GCCcore-10.3.0

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Define srun arguments
srun = "srun -N1 -n16 --exclusive"

# Define parallel arguments
parallel="parallel -N 1 -j $SLURM_NTASKS --joblog runtask.log --resume"

# Make unaligned data
if [ ! -d data/unaligned ]; then
    $parallel "$srun awk '{ if ($0 !~ /^>/) { gsub(/-/, "", $0); } print $0; }' data/aligned/{} > data/unaligned/{}" ::: $(ls -1 data/aligned) 

#-
# Default tracemethod runs (tracemethod)
#-

$parallel "$srun python3 MAGUS_CP/magus.py -i data/unaligned/{} -d results/{.} -o magus_result_minclusters.txt" ::: $(ls -1 data/unaligned) 


#-
# Other tracemethod runs (fm, mwtgreedy, rg, mwtsearch)
#-

$parallel "$srun python3 MAGUS_CP/magus.py -d results/{1.} -o magus_result_{2}.txt  --graphtracemethod {2}" ::: $(ls -1 data/unaligned) ::: "fm" "mwtgreedy" "rg" "mwtsearch"