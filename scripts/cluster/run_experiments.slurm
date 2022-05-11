#!/bin/bash
#SBATCH --job-name=MAGUS
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=100G

module load Python/3.8.6-GCCcore-10.2.0

# Cwd
cd ~/MAGUS_project

# Data directory
data_dir = /scratch/brussel/102/vsc10248/data

# Results directory
results_dir =${results_dir}

for file in $(ls -1 ${data_dir}/unaligned); do

	# Filename without extension
	filename="${file%_unaligned.fasta*}"

	#-
	# Default tracemethod runs (minclusters)
	#-

	scripts/cluster/runlim -o ${results_dir}/${filename}/minclusters_runlim.txt python MAGUS_CP/magus.py --numprocs 24 -i ${data_dir}/unaligned/${file} -d  ${results_dir}/results/${filename} -o  ${results_dir}/results/${filename}/magus_result_minclusters.txt --graphtracemethod minclusters
	mv ${esults_dir}/${filename}/graph/trace.txt  ${results_dir}/${filename}/graph/trace_minclusters.txt

	#-
	# Other tracemethod runs (fm, mwtgreedy, rg, mwtsearch)
	#-

	scripts/cluster/runlim -o ${results_dir}/${filename}/fm_runlim.txt python MAGUS_CP/magus.py --numprocs 24 -d ${results_dir}/${filename} -o ${results_dir}/${filename}/magus_result_fm.txt --graphtracemethod fm
	mv ${results_dir}/${filename}/graph/trace.txt ${results_dir}/${filename}/graph/trace_fm.txt

	scripts/cluster/runlim -o ${results_dir}/${filename}/mwtgreedy_runlim.txt python MAGUS_CP/magus.py --numprocs 24 -d ${results_dir}/${filename} -o ${results_dir}/${filename}/magus_result_mwtgreedy.txt --graphtracemethod mwtgreedy
	mv ${results_dir}/${filename}/graph/trace.txt ${results_dir}/${filename}/graph/trace_mwtgreedy.txt

	scripts/cluster/runlim -o ${results_dir}/${filename}/rg_runlim.txt python MAGUS_CP/magus.py --numprocs 24 -d ${results_dir}/${filename} -o ${results_dir}/${filename}/magus_result_rg.txt --graphtracemethod rg 
	mv ${results_dir}/${filename}/graph/trace.txt ${results_dir}/${filename}/graph/trace_rg.txt
	
	scripts/cluster/runlim -o ${results_dir}/${filename}/mwtsearch_runlim.txt python MAGUS_CP/magus.py --numprocs 24 -d ${results_dir}/${filename} -o ${results_dir}/${filename}/magus_result_mwtsearch.txt --graphtracemethod mwtsearch 
	mv ${results_dir}/${filename}/graph/trace.txt ${results_dir}/${filename}/graph/trace_mwtsearch.txt

	#-
	# Our reimplemented method (minclusters_reimplemented)
	#-

	scripts/cluster/runlim -o ${results_dir}/${filename}/minclusters_reimplemented_runlim.txt python MAGUS_CP/magus.py --numprocs 24 -d ${results_dir}/${filename} -o ${results_dir}/${filename}/magus_result_minclusters_reimplemented.txt --graphtracemethod minclusters_reimplemented
	mv ${results_dir}/${filename}/graph/trace.txt ${results_dir}/${filename}/graph/trace_minclusters_reimplemented.txt

done