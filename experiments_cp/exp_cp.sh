#!/bin/bash

CSV_INPUT="../data/unalign_test.csv"
CSV_OUTPUT="results.csv"
ALIGNEDFOLDER="../data/data/clipped"
UNALIGNEDFOLDER="../data/data/unaligned"

OLDIFS=$IFS
IFS=','

MAXNUMSUBSETS=4
[ ! -f $INPUT_CSV ] && { echo "$INPUT_CSV file not found"; exit 99; }

exec < $CSV_INPUT
#TODO: bijhouden aantal clusters gevonden door MCL
echo "INSTANCE,NR_SEQUENCES,MEAN_SEQ_LENGTH,NR_CLUSTERS_BEFORE_MINCLUSTERS,NR_CLUSTERS_MINCLUSTERS,TIME_TRACING_MINCLUSTERS,NR_SHARED_HOMOLOGIES_MINCLUSTERS,NR_HOMOLOGIES_REF,NR_HOMOLOGIES_MINCLUSTERS,NR_ALIGNED_COLS_REF,NR_ALIGNED_COLS_MINCLUSTERS,SPFN_MINCLUSTERS,SPFP_MINCLUSTERS,NR_CLUSTERS_CP,TIME_TRACING_CP,NR_SHARED_HOMOLOGIES_CP,NR_HOMOLOGIES_CP,NR_ALIGNED_COLS_CP,SPFN_CP,SPFP_CP" > $CSV_OUTPUT
read -r header

while read instance nr_seqs mean_seq_length 
do
  echo "$instance"
  if [[ "$instance" != "instance" ]] 
  then
    echo "instance = $instance, MAXNUMSUBSETS = $MAXNUMSUBSETS, nr_seqs = $nr_seqs"
    #MAXSUBSETSIZE=`expr  $nr_seqs / $MAXNUMSUBSETS + 1`
    echo "Maxsubsetsize = $MAXSUBSETSIZE"
    echo "Starting with minclusters.."
    # Execute magus with minclusters
    echo "RUNNING: python ../MAGUS_CP/magus.py --recurse false --graphtracemethod minclusters --maxnumsubsets $MAXNUMSUBSETS --maxsubsetsize 0  -o alignments/$instance -d workingdirs/minclusters_$instance -i $UNALIGNEDFOLDER/$instance > outputs/minclusters_$instance.txt"
    python ../MAGUS_CP/magus.py --recurse false --graphtracemethod minclusters --maxnumsubsets $MAXNUMSUBSETS --maxsubsetsize 0  -o alignments/minclusters_$instance -d workingdirs/$instance -i $UNALIGNEDFOLDER/$instance > outputs/minclusters_$instance.txt
    
    # Get values for number of clusters found after trace made, time tracing
    NR_CLUSTERS_BEFORE_MINCLUSTERS=$(cat outputs/minclusters_$instance.txt | grep -Eo 'Found [+-]?[0-9]+([.][0-9]+)? clean clusters' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    NR_CLUSTERS_MINCLUSTERS=$(cat outputs/minclusters_$instance.txt | grep -Eo 'Found a trace with [+-]?[0-9]+([.][0-9]+)? clusters' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    TIME_TRACING_MINCLUSTERS=$(cat outputs/minclusters_$instance.txt | grep -Eo 'Found alignment graph trace in [+-]?[0-9]+([.][0-9]+)? ' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')


    echo "Calculating FastSP.."
    # Get values from FastSP
    echo "RUNNING: java -jar ../tools/FastSP.jar -r "$ALIGNEDFOLDER/$instance" -e alignments/minclusters_$instance > outputs/minclusters_FastSP_$instance.txt 2> outputs/minclusters_FastSP_$instance.txt"
    java -jar ../tools/FastSP.jar -r "$ALIGNEDFOLDER/$instance" -e alignments/minclusters_$instance > outputs/minclusters_FastSP_$instance.txt 2> outputs/minclusters_FastSP_$instance.txt
    NR_SHARED_HOMOLOGIES_MINCLUSTERS=$(cat outputs/minclusters_FastSP_$instance.txt | grep "Number of shared homologies:" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    NR_HOMOLOGIES_REF=$(cat outputs/minclusters_FastSP_$instance.txt | grep "Number of homologies in the reference alignment:" | grep -Eo '[+-]?[0-9]+([.][0-10]+)?')
    NR_HOMOLOGIES_MINCLUSTERS=$(cat outputs/minclusters_FastSP_$instance.txt | grep "Number of homologies in the estimated alignment:" | grep -Eo '[+-]?[0-9]+([.][1-9]+)?')
    NR_ALIGNED_COLS_REF=$(cat outputs/minclusters_FastSP_$instance.txt | grep "Number of aligned columns in ref. alignment:" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    NR_ALIGNED_COLS_MINCLUSTERS=$(cat outputs/minclusters_FastSP_$instance.txt | grep "Number of aligned columns in est. alignment:" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    SPFN_MINCLUSTERS=$(cat outputs/minclusters_FastSP_$instance.txt | grep "SPFN" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    SPFP_MINCLUSTERS=$(cat outputs/minclusters_FastSP_$instance.txt | grep "SPFP" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')

    mv workingdirs/$instance/graph/trace.txt workingdirs/$instance/graph/trace_minclusters.txt

    echo "Starting with CP.."
    # Execute magus with CP
    echo "RUNNING: python ../MAGUS_CP/magus.py --recurse false --graphtracemethod cp --maxnumsubsets $MAXNUMSUBSETS --maxsubsetsize $MAXSUBSETSIZE  -o alignments/cp_$instance -d workingdirs/$instance -i $UNALIGNEDFOLDER/$instance > outputs/cp_$instance.txt"
    python ../MAGUS_CP/magus.py --recurse false --graphtracemethod cp --maxnumsubsets $MAXNUMSUBSETS --maxsubsetsize 0  -o alignments/cp_$instance -d workingdirs/$instance -i $UNALIGNEDFOLDER/$instance > outputs/cp_$instance.txt
    
    # Get values for number of clusters found after trace made, time tracing
    NR_CLUSTERS_BEFORE_CP=$(cat outputs/cp_$instance.txt | grep -Eo 'Found [+-]?[0-9]+([.][0-9]+)? clean clusters' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    NR_CLUSTERS_CP=$(cat outputs/cp_$instance.txt | grep -Eo 'Found a trace with [+-]?[0-9]+([.][0-9]+)? clusters' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    TIME_TRACING_CP=$(cat outputs/cp_$instance.txt | grep -Eo 'Found alignment graph trace in [+-]?[0-9]+([.][0-9]+)? ' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    
    echo "Calculating FastSP.."
    # Get values from FastSP
    echo "RUNNING: java -jar ../tools/FastSP.jar -r "$ALIGNEDFOLDER/$instance" -e alignments/cp_$instance > outputs/minclusters_FastSP_$instance.txt 2> outputs/cp_FastSP_$instance.txt"
    java -jar ../tools/FastSP.jar -r "$ALIGNEDFOLDER/$instance" -e alignments/cp_$instance > outputs/cp_FastSP_$instance.txt 2> outputs/cp_FastSP_$instance.txt
    NR_SHARED_HOMOLOGIES_CP=$(cat outputs/cp_FastSP_$instance.txt | grep "Number of shared homologies:" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    NR_HOMOLOGIES_CP=$(cat outputs/cp_FastSP_$instance.txt | grep "Number of homologies in the estimated alignment:" | grep -Eo '[+-]?[0-9]+([.][1-9]+)?')
    NR_ALIGNED_COLS_CP=$(cat outputs/cp_FastSP_$instance.txt | grep "Number of aligned columns in est. alignment:" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    SPFN_CP=$(cat outputs/cp_FastSP_$instance.txt | grep "SPFN" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
    SPFP_CP=$(cat outputs/cp_FastSP_$instance.txt | grep "SPFP" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')

    mv workingdirs/$instance/graph/trace.txt workingdirs/$instance/graph/trace_cp.txt

    echo "Writing instance."
    # Write values to the output
    echo "$instance,$nr_seqs,$mean_seq_length,$NR_CLUSTERS_BEFORE_MINCLUSTERS,$NR_CLUSTERS_MINCLUSTERS,$TIME_TRACING_MINCLUSTERS,$NR_SHARED_HOMOLOGIES_MINCLUSTERS,$NR_HOMOLOGIES_REF,$NR_HOMOLOGIES_MINCLUSTERS,$NR_ALIGNED_COLS_REF,$NR_ALIGNED_COLS_MINCLUSTERS,$SPFN_MINCLUSTERS,$SPFP_MINCLUSTERS,$NR_CLUSTERS_BEFORE_CP,$NR_CLUSTERS_CP,$TIME_TRACING_CP,$NR_SHARED_HOMOLOGIES_CP,$NR_HOMOLOGIES_CP,$NR_ALIGNED_COLS_CP,$SPFN_CP,$SPFP_CP" >> $CSV_OUTPUT
  fi
done 

IFS=$OLDIFS