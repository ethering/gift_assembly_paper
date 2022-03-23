#!/bin/bash -e
SAM=$1

# $align: minimap2 alignments in sam format;
# $max_overlap: maximum amount of nucleotides overlapping between red fragments;
# $outpath: path to the out directory;
# $output: name of output file;

perl get_split_reads_03.pl $SAM\_log.txt $SAM 30 ./chimeric_alignments/sams $SAM\_chimeric.txt
