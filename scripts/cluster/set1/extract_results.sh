#!/bin/bash

# Expects results dir to be passed as first argument, absolute path or relative to root of repo

# Print header
printf "name,method,trace_time,run_time,memory,SPFN,SPFP\n"

# Loop over results
for msa in $(ls -1 $1); do

    # Extract trace method
    trace_method=$(cat $1/$msa/log.txt | grep '\-\-graphtracemethod' | sed 's/^.*method //')

    # Extract trace running time
    trace_time=$(cat $1/$msa/log.txt | grep 'alignment graph trace in' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' | grep '\.')

    # Extract total running times
    run_time=$(cat $1/$msa/log.txt | grep 'MAGUS finished in' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' | grep '\.')

    # Calculate scores
	if [ -f "data/aligned/${msa}.fasta" ]; then
       aligned_name="${msa}.fasta"
	fi
	if [ -f "data/aligned/${msa}.txt" ]; then
       aligned_name="${msa}.txt"
	fi
    fastsp_output=$(java -jar tools/FastSP.jar -r data/aligned/${aligned_name} -e $1/${msa}/result.txt)
    SPFN=$(echo "$fastsp_output" | grep 'SPFN' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    SPFP=$(echo "$fastsp_output" | grep 'SPFP' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')

    # Extract memory used
    used_memory=$(cat $1/runlims/${msa}.txt | grep 'space:' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?');  

    # Write results
    printf "${msa},${trace_method},${trace_time},${run_time},${used_memory},${SPFN},${SPFP}\n"
done