#!/bin/bash
#SBATCH --job-name=MAGUS
#SBATCH --time=24:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G

module load Python/3.8.6-GCCcore-10.2.0
module load PyQt5/5.15.1-GCCcore-10.2.0

# Cwd
cd ~/MAGUS_dieter

instance=INSTANCE
DATADIR="/scratch/brussel/102/vsc10248/data"
RESULTSDIR="$DATADIR/results"
UNALIGNEDFOLDER="$DATADIR/unaligned"
MAXNUMSUBSETS=5

mkdir "$RESULTSDIR"
mkdir "$RESULTSDIR/alignments"
mkdir "$RESULTSDIR/outputs"
mkdir "$RESULTSDIR/workingdirs"

# Execute magus with minclusters
python MAGUS_CP/magus.py --numprocs 1 --recurse false --graphtracemethod minclusters --maxnumsubsets $MAXNUMSUBSETS --maxsubsetsize 0 -o $RESULTSDIR/alignments/minclusters_$instance -d $RESULTSDIR/workingdirs/$instance -i $UNALIGNEDFOLDER/$instance > $RESULTSDIR/outputs/minclusters_$instance.txt
mv $RESULTSDIR/workingdirs/$instance/graph/trace.txt $RESULTSDIR/workingdirs/$instance/graph/trace_minclusters.txt

# Execute magus with CP
python MAGUS_CP/magus.py --numprocs 1 --recurse false --graphtracemethod cp --maxnumsubsets $MAXNUMSUBSETS --maxsubsetsize 0  -o $RESULTSDIR/alignments/cp_$instance -d $RESULTSDIR/workingdirs/$instance -i $UNALIGNEDFOLDER/$instance > $RESULTSDIR/outputs/cp_$instance.txt
mv $RESULTSDIR/workingdirs/$instance/graph/trace.txt $RESULTSDIR/workingdirs/$instance/graph/trace_cp.txt