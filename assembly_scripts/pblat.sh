#!/bin/bash -e

source pblat-2.5
srun pblat Tilapia_hifiasm.10x_sm.fa Axiom_NTilapia_Probes.fasta probes_vs_gift.psl -t=dna -q=dna  -oneOff=1 -fastMap -threads=128
