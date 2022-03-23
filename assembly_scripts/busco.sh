#!/bin/bash
REF=$1

source busco-5.0.0
busco -i $REF -c 32 -o out -m genome --offline -l actinopterygii_odb10
