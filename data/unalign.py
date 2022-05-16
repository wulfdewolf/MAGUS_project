import sys
import os
from Bio import SeqIO

if __name__ == "__main__":

    # Verify if aligned folder exists
    if not os.path.isdir("data/aligned"):
        print("data/aligned folder does not exist, run data/download.sh first!")
        quit()

    sequence_length = sys.argv[1]

    # Make unaligned folder
    outputfolder = "data/unaligned-len-" + str(sequence_length) if sequence_length != None else "data/unaligned"
    os.mkdir(outputfolder)

    # Unalign
    
    smallest_sequence = None
    smallest_sequence_length = 6000
    
    for instance in os.listdir("data/aligned"): 
 
        with open(outputfolder + "/" + instance + "_unaligned.fasta", "w") as f:
            max_length = 0
            for record in SeqIO.parse("data/aligned/" + instance, "fasta"):
                max_length = len(record.seq) if len(record.seq) > max_length else max_length
                if sequence_length != None:
                    record.seq = record.seq[0:int(sequence_length)]
                f.write(str(">" + record.id + "\n" + record.seq.ungap("-")) + "\n")
            print(instance + " " + str(max_length))
            if max_length < smallest_sequence_length:
                smallest_sequence = instance
                smallest_sequence_length = max_length
                
    print("smallest sequence: " + smallest_sequence + " " + str(smallest_sequence_length))
