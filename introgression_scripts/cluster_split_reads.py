#takes two split-read files and looks for reads for which one part of the read maps to one genome
#and another part of the read maps to the other genome, with no or very little overlap
import csv
import sys

umd_file = sys.argv[1]
mos_file = sys.argv[2]
out_file = sys.argv[3]

splits={}

def checkForOverlaps(listOfElems):
    ''' Check if given list contains any duplicates '''
    if len(listOfElems) == len(set(listOfElems)):
        return True
    else:
        return False

with open(umd_file, 'r') as f:
	umd_reader=csv.reader(f, delimiter='\t')
	for row in umd_reader:
		readname=row[0]
        print(row[4])
        read_start=int(row[4])
        read_end=(int(read_start+int(row[6])))
        r=range(read_start, read_end+1)

        if not readname in splits:
            splits[readname]=(r)
        else:
            splits[readname]+=(r)

with open(mos_file, 'r') as f:
	mos_reader=csv.reader(f, delimiter='\t')
	for row in mos_reader:
		readname=row[0]
		read_start=int(row[4])
		read_end=(int(read_start+int(row[6])))
		r=range(read_start, read_end+1)

		if not readname in splits:
			splits[readname]=(r)
		else:
			splits[readname]+=(r)
out = open(out_file,"w")

for key in splits.keys():
	same=checkForOverlaps(splits[key])
	if same == True:
		out.write(key+ "\n")
