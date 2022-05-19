import sys
import os
from Bio import SeqIO
import argparse

if __name__ == "__main__":

    argparser = argparse.ArgumentParser(description="Preprocessing of the instances for MAGUS experiments.")
    
    argparser.add_argument('--outputfolder'       , dest='outputfolder'      , default="data/unaligned"  , metavar=''   , type=str  , help="The output folder where the instances will be saved.")
    argparser.add_argument('--inputfolder'        , dest='inputfolder'       , default="data/aligned"    , metavar=''   , type=str  , help="The input folder where the aligned instances are located.")
    argparser.add_argument('--clippedfolder'      , dest='clippedfolder'     , default=None              , metavar=''   , type=str  , help="The folder where the clipped aligned instances are located.")
    argparser.add_argument('--sequence_length'    , dest='sequence_length'   , default=None              , metavar=''   , type=int  , help="If not None, the aligned sequence will be reduced to this number of columns.")
    argparser.add_argument('--min_mean_length'    , dest='min_mean_length'   , default=None              , metavar=''   , type=int  , help="If not None, the instance will only be kept when the mean sequence length is at least this parameter.")
    argparser.add_argument('--max_mean_length'    , dest='max_mean_length'   , default=None              , metavar=''   , type=int  , help="If not None, the instance will only be kept when the mean sequence length is at most this parameter.")
    argparser.add_argument('--min_nr_sequences'   , dest='min_nr_sequences'  , default=None              , metavar=''   , type=int  , help="If not None, the instance will only be kept when the number of sequences is at least this parameter.")
    argparser.add_argument('--max_nr_sequences'   , dest='max_nr_sequences'  , default=None              , metavar=''   , type=int  , help="If not None, the instance will only be kept when the number of sequences is at most this parameter.")

    args = argparser.parse_args()

    # Verify if aligned folder exists
    if not os.path.isdir(args.inputfolder):
        print("ERROR: " +args.inputfolder + " folder does not exist, run data/download.sh first!")
        quit()
    
    # Make unaligned folder
    if os.path.exists(args.outputfolder):
        print("ERROR: " +args.outputfolder + " already exists!")
        quit()
           
    os.mkdir(args.outputfolder)

    # Make clipped folder
    if args.clippedfolder != None and os.path.exists(args.clippedfolder):
        print("ERROR: " +args.clippedfolder + " already exists!")
        quit()
        
    os.mkdir(args.clippedfolder)
    
    # Unalign
    print("instance,nr_sequences,mean_sequence_length")
    for instance in os.listdir("data/aligned"):
        outputfile = args.outputfolder + "/" + instance 
        
        max_length = 0
        mean_length = 0
        nr_sequences = 0
        
        with open(outputfile, "w") as f:
            for record in SeqIO.parse("data/aligned/" + instance, "fasta"):
                max_length = len(record.seq) if len(record.seq) > max_length else max_length
                if args.sequence_length != None:
                    record_to_print = record.seq[0:int(args.sequence_length)]
                    
                    if args.clippedfolder != None:
                        with open(args.clippedfolder + "/" + instance, "a") as fc:
                            fc.write(">" + record.id + "\n" + str(record_to_print) + "\n")
                    
                    record_to_print = record_to_print.ungap("-")
                else:
                    record_to_print = record.seq.ungap("-")
                    
                    
                if len(record_to_print) != 0:
                    mean_length += len(record_to_print)
                    nr_sequences += 1
                    f.write(">" + record.id + "\n" + str(record_to_print) + "\n")
                    
            mean_length = mean_length / nr_sequences
            
        if (args.min_mean_length != None and mean_length < args.min_mean_length) \
            or (args.max_mean_length != None and mean_length > args.max_mean_length) \
            or (args.min_nr_sequences != None and nr_sequences < args.min_nr_sequences) \
            or (args.max_nr_sequences != None and nr_sequences > args.max_nr_sequences):
                os.remove(outputfile)
        else:
            print(instance + "," + str(nr_sequences) + "," +  str(mean_length))

