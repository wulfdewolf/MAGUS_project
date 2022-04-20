#!/bin/bash
#SBATCH --job-name=MAGUS
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --partition=broadwell
#SBATCH --exclusive
#SBATCH --cpus-per-node=28
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=7
#SBATCH --mem=256G

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Cwd
cd ~/MAGUS_project

# Make unaligned data
if [ ! -d data/unaligned ]; then
    mkdir data/unaligned
    parallel --delay 0.2 -N 1 -j $SLURM_NTASKS --joblog runtask.log --resume "srun -N1 -n1 -c7 python data/unalign.py data/aligned/{} > data/unaligned/{.}_scrambled.fasta" ::: $(ls -1 data/aligned)
    wait
fi

#-
# Default tracemethod runs (tracemethod)
#-

parallel --delay 0.2 -N 1 -j $SLURM_NTASKS --joblog runtask.log --resume "srun -N1 -n1 -c7 --mem=64G python3 MAGUS_CP/magus.py --numprocs 7 -i data/unaligned/{} -d results/{.} -o results/{.}/magus_result_minclusters.txt" ::: $(ls -1 data/unaligned)
wait

#-
# Other tracemethod runs (fm, mwtgreedy, rg, mwtsearch)
#-

parallel --delay 0.2 -N 1 -j $SLURM_NTASKS --joblog runtask.log --resume "srun -N1 -n1 -c7 --mem=64G python3 MAGUS_CP/magus.py --numprocs 7 -d results/{1.} -o results/{1.}/magus_result_{2}.txt  --graphtracemethod {2}" ::: $(ls -1 data/unaligned) ::: "fm" "mwtgreedy" "rg" "mwtsearch"
wait
