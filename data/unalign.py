import sys
import os
from Bio import SeqIO

if __name__ == "__main__":

    # Verify if aligned folder exists
    if not os.path.isdir("data/aligned"):
        print("data/aligned folder does not exist, run data/download.sh first!")
        quit()

    # Make unaligned folder
    os.mkdir("data/unaligned")

    # Unalign
    for instance in os.listdir("data/aligned"): 
        name = instance.split("_true")[0]

        with open("data/unaligned/" + name + "_unaligned.fasta", "w") as f:
            for record in SeqIO.parse("data/aligned/" + instance, "fasta"):
                f.write(str(">" + record.id + "\n" + record.seq.ungap("-")))
