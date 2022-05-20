#!/bin/bash
#SBATCH --job-name=MAGUS
#SBATCH --time=5-00:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G

module load Python/3.8.6-GCCcore-10.2.0

# Cwd
cd ~/MAGUS_project

# Data directory
DATADIR="/home/wdewolf/MAGUS_project/data"

# Results directory
RESULTSDIR="${DATADIR}/results"
mkdir $RESULTSDIR
mkdir $RESULTSDIR/runlims

for file in $(ls -1 $DATADIR/unaligned); do

	# Filename without extension
	filename="${file%_unaligned.fasta*}"

	#-
	# Original minclusters
	#-

	scripts/cluster/runlim -o ${RESULTSDIR}/runlims/${filename}_minclusters_runlim.txt python MAGUS_CP/magus.py --numprocs 16 -i ${DATADIR}/unaligned/${file} -d ${RESULTSDIR}/${filename} -o ${RESULTSDIR}/${filename}/magus_result_minclusters.txt --graphtracemethod minclusters
	mv ${RESULTSDIR}/${filename}/graph/trace.txt  ${RESULTSDIR}/${filename}/graph/trace_minclusters.txt

	#-
	# Reimplemented minclusters
	#-

	scripts/cluster/runlim -o ${RESULTSDIR}/runlims/${filename}_minclusters_reimplemented_runlim.txt python MAGUS_CP/magus.py --numprocs 16 -d ${RESULTSDIR}/${filename} -o ${RESULTSDIR}/${filename}/magus_result_minclusters_reimplemented.txt --graphtracemethod minclusters_reimplemented
	mv ${RESULTSDIR}/${filename}/graph/trace.txt  ${RESULTSDIR}/${filename}/graph/trace_minclusters_reimplemented.txt

done

