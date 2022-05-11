#!/bin/bash

# Loop over results
for msa in $(ls -1 results); do

    # Extract trace methods
    trace_methods=$(cat results/$msa/log.txt | grep '\-\-graphtracemethod' | sed 's/^.*method //' | sed ':a;N;$!ba;s/\n/,/g')
    IFS=','
    read -a trace_methods_arr <<< "$trace_methods"

    # Extract trace running times
    trace_times=$(cat results/$msa/log.txt | grep 'alignment graph trace in' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' | grep '\.' | sed ':a;N;$!ba;s/\n/,/g')
    IFS=','
    read -a trace_times_arr <<< "$trace_times"

    ## Extract total running times
    run_times=$(cat results/$msa/log.txt | grep 'MAGUS finished in' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?' | grep '\.' | sed ':a;N;$!ba;s/\n/,/g')
    IFS=','
    read -a run_times_arr <<< "$run_times"

    ## Save results
    rm results/$msa/times_and_results.csv
    for index in "${!trace_methods_arr[@]}"; do

        # Calculate scores
        fastsp_output=$(java -jar tools/FastSP.jar -r data/aligned/${msa}_true.fasta -e results/${msa}/magus_result_${trace_methods_arr[$index]}.txt)
        SPFN=$(echo "$fastsp_output" | grep 'SPFN' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
        SPFP=$(echo "$fastsp_output" | grep 'SPFP' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')

        # Extract memory used
        used_memory = $(cat results/${msa}/${trace_methods_arr[$index]}_runlim.txt | grep 'space:' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?');  

        # Write results
        # msa name, method, trace running time, total running time, used memory, SPFN, SPFP
        printf "${msa},${trace_methods_arr[$index]},${trace_times_arr[$index]},${run_times_arr[$index]},${used_memory}, ${SPFN},${SPFP}\n" >> results.csv
    done
done