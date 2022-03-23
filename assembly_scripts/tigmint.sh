#!/bin/bash -e
#create a tmpdir
export TMPDIR=./tigmint/tmp

source ./python_miniconda_py38_4.8.3_tigmint/x86_64/bin/activate
source samtools-1.9
srun tigmint-make arcs draft=Tilapia_hifiasm.ctg.gapfilled reads=barcoded t=12 G=1065870084
