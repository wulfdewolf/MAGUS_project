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
# EXPECTS ONLY LARGE INSTANCES in DATADIR/unaligned
DATADIR="/home/wdewolf/MAGUS_project/data/set1"

# Results directory
# EXPECTS THESE FOLDERS TO EXIST:
# - RESULTSDIR
# - RESULTSDIR/original
# - RESULTSDIR/reimplemented
# - RESULTSDIR/original/runlims
# - RESULTSDIR/reimplemented/runlims
RESULTSDIR="${DATADIR}/results"

for file in $(ls -1 $DATADIR/unaligned); do

	# Filename without extension
	filename="${file%.fasta*}"

	#-
	# Original minclusters
	#-

	scripts/cluster/runlim -o ${RESULTSDIR}/original/runlims/${filename}.txt python MAGUS_CP/magus.py --numprocs 16 \
																										   -i ${DATADIR}/unaligned/${file} \
																										   -d ${RESULTSDIR}/original/${filename} \
																										   -o ${RESULTSDIR}/original/${filename}/result.txt \
																										   --graphtracemethod minclusters
																										   --maxsubsetsize 0 --maxnumsubsets 50

	#-
	# Reimplemented minclusters
	#-

	scripts/cluster/runlim -o ${RESULTSDIR}/reimplemented/runlims/${filename}.txt python MAGUS_CP/magus.py --numprocs 16 
																										   -i ${DATADIR}/unaligned/${file} \
																										   -d ${RESULTSDIR}/reimplemented/${filename} 
																										   -o ${RESULTSDIR}/reimplemented/${filename}/result.txt 
																										   --graphtracemethod minclusters_reimplemented
																										   --maxsubsetsize 0 --maxnumsubsets 50

done
