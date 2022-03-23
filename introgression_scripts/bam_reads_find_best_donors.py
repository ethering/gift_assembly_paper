import sys
import os
import pysam

#takes the output of bam_reads_from_bed.property
#takes each GIFT interval in turn and finds the highest number of reads in an interval from both UMD and mossambicus
gift_directory = sys.argv[1] #the directory for the GIFT intervals
umd_directory= sys.argv[2] #the directory for the UMD intervals
mossambicus_directory = sys.argv[3] #the directory for the mossambicus intervals
output_file = sys.argv[4]

print("gift dir is "+gift_directory, flush=True)
print("umd dir is "+umd_directory, flush=True )
print("mos dir is "+mossambicus_directory, flush=True )
print("Outfile is "+output_file, flush=True )


gift_dict={}
umd_dict={}
mossambicus_dict={}

#open each gift_file in turn
#gift_dir = os.fsencode(gift_directory)
print("Reading gift dir", flush=True)
gift_dir = os.path.abspath(gift_directory)

for file in os.listdir(os.path.abspath(gift_directory)):
	filename, file_extension = os.path.splitext(file)
	#file_ext = file_extension.decode('utf-8')
	if file_extension==".txt":
		#create a dict entry, with the interval name as the key and the set of reads in that interval as the value
		with open(gift_dir+"/"+file)as file_handle:
			temp_set=set()
			for line in file_handle:
				read = line.strip()
				temp_set.add(read)
		gift_dict[filename]=temp_set
		file_handle.close()

#do the same for UMD and mossambicus
print("Finished reading gift dir", flush=True)


print("Reading umd dir", flush=True)
umd_dir = os.path.abspath(umd_directory)

for file in os.listdir(os.path.abspath(umd_directory)):
	filename, file_extension = os.path.splitext(file)
	#file_ext = file_extension.decode('utf-8')
	if file_extension==".txt":
		#create a dict entry, with the interval name as the key and the set of reads in that interval as the value
		with open(umd_dir+"/"+file)as file_handle:
			temp_set=set()
			for line in file_handle:
				read = line.strip()
				temp_set.add(read)
		umd_dict[filename]=temp_set
		file_handle.close()

print("Finished reading umd  dir", flush=True)

print("Reading mossambicus dir", flush=True)
mossambicus_dir = os.path.abspath(mossambicus_directory)

for file in os.listdir(os.path.abspath(mossambicus_directory)):
	filename, file_extension = os.path.splitext(file)
	#file_ext = file_extension.decode('utf-8')
	if file_extension==".txt":
		#create a dict entry, with the interval name as the key and the set of reads in that interval as the value
		with open(mossambicus_dir+"/"+file)as file_handle:
			temp_set=set()
			for line in file_handle:
				read = line.strip()
				temp_set.add(read)
		mossambicus_dict[filename]=temp_set
		file_handle.close()
print("Finished reading mosambicus dir", flush=True)


print(len(gift_dict), flush=True)
print(len(umd_dict), flush=True)
print(len(mossambicus_dict), flush=True)

outfile = open(output_file, "w")
outfile.write("GIFT interval\tUMD interval\tmossambicus interval\tread_count\treads_per_kb\n")
os.fsync(outfile)
#Then go through the gift_dict and for each set

for gift_key, gift_value in gift_dict.items():
	best_umd_interval=""
	best_mos_interval=""
	best_num_reads=0
	print("At gift interval "+gift_key, flush=True)
	#start with the first set in umd_dict
	for umd_key, umd_value in umd_dict.items():
		#print(umd_key)
		#and then go through each set in the mossambicus_dict
		for moss_key, moss_value in mossambicus_dict.items():
			#and do an intersect, e.g.

			result = set.intersection(gift_value, umd_value, moss_value)
			#print(str(len(result)))
			if (len(result)) > best_num_reads:
				best_umd_interval=umd_key
				best_mos_interval=moss_key
				best_num_reads=len(result)
	#if there are hits...
	if (best_num_reads>0):
		print("Found a hit for "+gift_key, flush=True)
		#create proper UCSC intervals
		gift_split = gift_key.split('_')
		umd_split= best_umd_interval.split('_')
		moss_split= best_mos_interval.split('_')
		gift_interval=gift_split[0]+":"+gift_split[1]+"-"+gift_split[2]
		umd_interval=umd_split[0]+":"+umd_split[1]+"-"+umd_split[2]
		moss_scaffold_str = moss_split[:-2]
		moss_scaffold = "_".join(moss_scaffold_str)
		moss_interval=moss_scaffold+":"+moss_split[-2]+"-"+moss_split[-1]
		#write the data to file
		reads_per_1kb = (best_num_reads/(int(gift_split[2]) - int(gift_split[1])))* 1000
		outfile.write(gift_interval+"\t"+umd_interval+"\t"+moss_interval+"\t"+str(best_num_reads)+"\t"+str(reads_per_1kb)+"\n")
		outfile.flush()
	else:
		print("Nothing found for "+gift_key, flush=True)
outfile.close()
