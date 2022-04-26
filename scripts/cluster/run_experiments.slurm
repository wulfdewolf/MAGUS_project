#!/bin/bash
#SBATCH --job-name=MAGUS
#SBATCH --time=12:00:00
#SBATCH --partition=batch
#SBATCH --cpus=24
#SBATCH --mem=100G

module load Python/3.8.6-GCCcore-10.2.0

# Cwd
cd ~/MAGUS_project

# Make unaligned data
if [ ! -d data/unaligned ]; then
	mkdir data/unaligned
fi
for file in $(ls -1 data/aligned); do

	# Filename without extension
	filename="${file%_true.fasta}"

	if [ ! -f data/unaligned/${filename}_scrambled.fasta ]; then
		python data/unalign.py data/aligned/${file} > data/unaligned/${filename}_scrambled.fasta
	fi
done



for file in $(ls -1 data/unaligned); do

	# Filename without extension
	filename="${file%_scrambled.fasta*}"

	#-
	# Default tracemethod runs (tracemethod)
	#-

	python MAGUS_CP/magus.py --numprocs 24 -i data/unaligned/${file} -d results/${filename} -o results/${filename}/magus_result_minclusters.txt --graphtracemethod minclusters
	mv results/${filename}/graph/trace.txt results/${filename}/graph/trace_minclusters.txt

	#-
	# Other tracemethod runs (fm, mwtgreedy, rg, mwtsearch)
	#-

	python MAGUS_CP/magus.py --numprocs 24 -d results/${filename} -o results/${filename}/magus_result_fm.txt --graphtracemethod fm
	mv results/${filename}/graph/trace.txt results/${filename}/graph/trace_fm.txt

	python MAGUS_CP/magus.py --numprocs 24 -d results/${filename} -o results/${filename}/magus_result_mwtgreedy.txt --graphtracemethod mwtgreedy
	mv results/${filename}/graph/trace.txt results/${filename}/graph/trace_mwtgreedy.txt

	python MAGUS_CP/magus.py --numprocs 24 -d results/${filename} -o results/${filename}/magus_result_rg.txt --graphtracemethod rg 
	mv results/${filename}/graph/trace.txt results/${filename}/graph/trace_rg.txt
	
	python MAGUS_CP/magus.py --numprocs 24 -d results/${filename} -o results/${filename}/magus_result_mwtsearch.txt --graphtracemethod mwtsearch 
	mv results/${filename}/graph/trace.txt results/${filename}/graph/trace_mwtsearch.txt
done
