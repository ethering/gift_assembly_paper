import sys
import os
import pysam

#ouputs a BED file from an input gff file and a list of gene_ids, found in the attributes
bedfile = sys.argv[1] #the gene-ids in the next gff file to create a bed file from
bamfile = sys.argv[2] #the sorted gff file that intersects busco and ferret genes


samfile = pysam.AlignmentFile(bamfile, "rb")


with open(bedfile)as bed_handle:
	for line in bed_handle:
		bed = line.strip().split()
		fname=bed[0] + "_"+bed[1]+"_"+bed[2]+".txt"

		outfile = open(fname, "w")
		loci = samfile.fetch(bed[0], int(bed[1]), int(bed[2]))
		reads=set()
		for x in loci:
			reads.add(str(x.query_name))
		for read in reads:
			outfile.write(str(read)+ "\n")
		outfile.close()
