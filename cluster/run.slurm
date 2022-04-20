#!/bin/bash
#SBATCH --job-name=MAGUS
#SBATCH --ntasks=10
#SBTACH --cpus-per-task=16
#SBATCH --mem-per-cpu=2G

module load Python/3.8.6-GCCcore-10.2.0

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# Cwd
cd ~/MAGUS_project

# Env
virtualenv --system-site-packages /tmp/env
source /tmp/env/bin/activate
python -m pip install --upgrade pip

# Reqs
python -m pip install -r data/requirements.txt

# Make unaligned data
if [ ! -d data/unaligned ]; then
    mkdir data/unaligned
    ./parallel --delay 0.2 -N 1 -j $SLURM_NTASKS --joblog runtask.log --resume "srun -N1 -n1 -c16 python data/unalign.py data/aligned/{} > data/unaligned/{.}_scrambled.fasta" ::: $(ls -1 data/aligned) 
    wait
fi

#-
# Default tracemethod runs (tracemethod)
#-

./parallel --delay 0.2 -N 1 -j $SLURM_NTASKS --joblog runtask.log --resume "srun -N1 -n1 -c16 python3 MAGUS_CP/magus.py -i data/unaligned/{} -d results/{.} -o results/{.}/magus_result_minclusters.txt" ::: $(ls -1 data/unaligned) 
wait

#-
# Other tracemethod runs (fm, mwtgreedy, rg, mwtsearch)
#-

./parallel --delay 0.2 -N 1 -j $SLURM_NTASKS --joblog runtask.log --resume "srun -N1 -n1 -c16 python3 MAGUS_CP/magus.py -d results/{1.} -o results/{1.}/magus_result_{2}.txt  --graphtracemethod {2}" ::: $(ls -1 data/unaligned) ::: "fm" "mwtgreedy" "rg" "mwtsearch"
wait
