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
if [ ! -d "$DATADIR/results" ]
then
	mkdir $RESULTSDIR
fi

# Group directories
if [ ! -d "$RESULTSDIR/original" ]
then
	mkdir $RESULTSDIR/original
fi
if [ ! -d "$RESULTSDIR/reimplemented" ]
then
	mkdir $RESULTSDIR/reimplemented
fi

# Runlims
if [ ! -d "$RESULTSDIR/original/runlims" ]
then
	mkdir $RESULTSDIR/original/runlims
fi
if [ ! -d "$RESULTSDIR/reimplemented/runlims" ]
then
	mkdir $RESULTSDIR/reimplemented/runlims
fi

for file in $(ls -1 $DATADIR/unaligned); do

	# Filename without extension
	if [[ "$file" == *".fasta"* ]]; then
       filename="${file%.fasta*}"
	fi
	if [[ "$file" == *".txt"* ]]; then
       filename="${file%.txt*}"
	fi


	#-
	# Original minclusters
	#-

	if [ ! -d "$RESULTSDIR/original/${filename}" ]
	then
		scripts/cluster/runlim -o ${RESULTSDIR}/original/runlims/${filename}.txt python MAGUS_CP/magus.py --numprocs 16 \
																										  -i ${DATADIR}/unaligned/${file} \
																										  -d ${RESULTSDIR}/original/${filename} \
																										  -o ${RESULTSDIR}/original/${filename}/result.txt \
																										  #--maxsubsetsize 0 --maxnumsubsets 50 \
																										  --graphtracemethod minclusters
	fi

	#-
	# Reimplemented minclusters
	#-

	if [ ! -d "$RESULTSDIR/reimplemented/${filename}" ]
	then
		scripts/cluster/runlim -o ${RESULTSDIR}/reimplemented/runlims/${filename}.txt python MAGUS_CP/magus.py --numprocs 16 \
																											   -i ${DATADIR}/unaligned/${file} \
																											   -d ${RESULTSDIR}/reimplemented/${filename} \
																											   -o ${RESULTSDIR}/reimplemented/${filename}/result.txt \
																										  	   #--maxsubsetsize 0 --maxnumsubsets 50 \
																											   --graphtracemethod minclusters_reimplemented
	fi
done
