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
DATADIR="/home/wdewolf/MAGUS_project/data/set1"

# Results directory
# EXPECTS THIS FOLDER TO NOT EXISTS -> rename previous result folders
RESULTSDIR="${DATADIR}/results"
mkdir $RESULTSDIR

# Group directories
mkdir $RESULTSDIR/original
mkdir $RESULTSDIR/reimplemented

# Runlims
mkdir $RESULTSDIR/original/runlims
mkdir $RESULTSDIR/reimplemented/runlims

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

	#-
	# Reimplemented minclusters
	#-

	scripts/cluster/runlim -o ${RESULTSDIR}/reimplemented/runlims/${filename}.txt python MAGUS_CP/magus.py --numprocs 16 
																										   -d ${RESULTSDIR}/reimplemented/${filename} 
																										   -o ${RESULTSDIR}/reimplemented/${filename}/result.txt 
																										   --graphtracemethod minclusters_reimplemented

done
