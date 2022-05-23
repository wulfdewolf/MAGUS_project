#!/bin/bash

EXPERIMENT="l100_m10_n10"

CSV_INPUT="../data/data/$EXPERIMENT/instances.csv"
CSV_OUTPUT="$EXPERIMENT/results.csv"
ALIGNEDFOLDER="../data/data/$EXPERIMENT/clipped"
UNALIGNEDFOLDER="../data/data/$EXPERIMENT/unaligned"

OLDIFS=$IFS
IFS=','

MAXNUMSUBSETS=4
[ ! -f $INPUT_CSV ] && { echo "$INPUT_CSV file not found"; exit 99; }

exec < $CSV_INPUT
#TODO: bijhouden aantal clusters gevonden door MCL
read -r header

mkdir "$EXPERIMENT"
mkdir "$EXPERIMENT/alignments"
mkdir "$EXPERIMENT/outputs"
mkdir "$EXPERIMENT/workingdirs"

while read instance nr_seqs mean_seq_length 
do
  echo "$instance"
  if [[ "$instance" != "instance" ]] 
  then
    echo "instance = $instance, MAXNUMSUBSETS = $MAXNUMSUBSETS, nr_seqs = $nr_seqs"
    echo "Starting with minclusters.."
    # Execute magus with minclusters
    echo "RUNNING: python ../MAGUS_CP/magus.py --recurse false --graphtracemethod minclusters --maxnumsubsets $MAXNUMSUBSETS --maxsubsetsize 0  -o alignments/$instance -d workingdirs/minclusters_$instance -i $UNALIGNEDFOLDER/$instance > outputs/minclusters_$instance.txt"
    python ../MAGUS_CP/magus.py --recurse false --graphtracemethod minclusters --maxnumsubsets $MAXNUMSUBSETS --maxsubsetsize 0  -o $EXPERIMENT/alignments/minclusters_$instance -d $EXPERIMENT/workingdirs/$instance -i $UNALIGNEDFOLDER/$instance > $EXPERIMENT/outputs/minclusters_$instance.txt
    
    mv $EXPERIMENT/workingdirs/$instance/graph/trace.txt $EXPERIMENT/workingdirs/$instance/graph/trace_minclusters.txt

    echo "Starting with CP.."
    # Execute magus with CP
    echo "RUNNING: python ../MAGUS_CP/magus.py --recurse false --graphtracemethod cp --maxnumsubsets $MAXNUMSUBSETS --maxsubsetsize 0 -o alignments/cp_$instance -d workingdirs/$instance -i $UNALIGNEDFOLDER/$instance > outputs/cp_$instance.txt"
    python ../MAGUS_CP/magus.py --recurse false --graphtracemethod cp --maxnumsubsets $MAXNUMSUBSETS --maxsubsetsize 0  -o $EXPERIMENT/alignments/cp_$instance -d $EXPERIMENT/workingdirs/$instance -i $UNALIGNEDFOLDER/$instance > $EXPERIMENT/outputs/cp_$instance.txt
    
    mv $EXPERIMENT/workingdirs/$instance/graph/trace.txt $EXPERIMENT/workingdirs/$instance/graph/trace_cp.txt

  fi
done 

IFS=$OLDIFS
