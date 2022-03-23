#!/usr/bin/perl
use strict;
use warnings;


my $project=$ARGV[0];
#CREATE_LOG(\@ARGV);

#inputs:
# $align: minimap2 alignments in sam format;
# $max_overlap: maximum amount of nucleotides overlapping between red fragments;
# $outpath: path to the out directory;
# $output: name of output file;

my ($align, $max_overlap, $outpath, $output)=@ARGV[1 .. $#ARGV];
#exit;

my %read_positions;


PARSE_SAM($align);
print "DONE SAM\n";

open(OUT, ">$outpath/$output");
foreach my $frag (keys %read_positions){
	if(scalar keys @{$read_positions{$frag}}>1){
		@{$read_positions{$frag}}=sort{$a->[3]<=>$b->[3]||$a->[4]<=>$b->[4]}@{$read_positions{$frag}};
		my %sel_reads;
		for my $i (0 .. $#{$read_positions{$frag}}-1){
			my $s1=$read_positions{$frag}[$i][3];
			my $e1=$read_positions{$frag}[$i][4];
			for (my $j=$i+1; $j<=$#{$read_positions{$frag}}; $j++){
				my $s2=$read_positions{$frag}[$j][3];
				my $e2=$read_positions{$frag}[$j][4];
				if($s2>$e1 || ($s2+$max_overlap)> $e1){
					if($read_positions{$frag}[$i][0]!~/$read_positions{$frag}[$j][0]\b/){
						$sel_reads{$i}=1;
						$sel_reads{$j}=1;
					}
					else{
						if($read_positions{$frag}[$j][1] > $read_positions{$frag}[$i][1]){
							if($read_positions{$frag}[$j][1]+$max_overlap >= $read_positions{$frag}[$i][2]){
								$sel_reads{$i}=1;
								$sel_reads{$j}=1;
							}
							else{
								last;
							}
						}
						elsif($read_positions{$frag}[$j][1] < $read_positions{$frag}[$i][1]){
							if($read_positions{$frag}[$i][1]+$max_overlap >= $read_positions{$frag}[$j][2]){
								$sel_reads{$i}=1;
								$sel_reads{$j}=1;
							}
							else{
								last;
							}
								
						}
					}
				}
				else{
					last;
				}
			}
		}
		if(scalar keys %sel_reads > 1){
			foreach my $temp_frag(sort{$a<=>$b} keys %sel_reads){
				print OUT join ("\t", $frag, @{$read_positions{$frag}[$temp_frag]}), "\n";
			}
		}
		%sel_reads=();
	}
}
#########################################################
#########################################################
sub CREATE_LOG{	
	my ($array)=(@_);
	my $date=localtime();
	if(-e "$project"){
		open ("IN", "$project")||die"IN $project\n";
		my @project_log=<IN>;
		close IN;
		open(LOG, ">$project");
		for my $n (0 .. $#project_log){
			print LOG $project_log[$n];
		}
	}
	else{
		open(LOG, ">$project");
	}
	print LOG "\n\n#########################################################\n#########################################################\n
$date\n
#########################################################\n#########################################################\n
\n";
	print LOG "## Script written to parse a minimap2 alignment output in sam format from long read data, to identify secondary alignments that could support structureal reaarangements. The script compares the genomic positions of the different read fragments, and check for non overlap between the fragments \n";
	print LOG "$0\n";
	for my $n (1 .. $#{$array}){
		print LOG join ("\t", $array->[$n]),"\n";
	}
	close LOG;
}

########################################################
########################################################
sub PARSE_SAM{
	my ($file)=(@_);
	open(SEQ, "$file")||die"SEQ $file\n";
	while(<SEQ>){
		if($_!~/^\@/){
			chomp;
			my @temp=split /\t/, $_;
			if($temp[5]!~/\*/ && $_=~/SA:Z:/){
				GET_POSITIONS($temp[0], $temp[3], $temp[5], $temp[2], length $temp[9], "1");
				my $temp_string=$temp[$#temp];
				my @temp_var=split /;/, $temp_string;
				if(scalar @temp_var == 1){
					$temp_string=~s/SA:Z://;
					my @var=split /,/, $temp_string;
					GET_POSITIONS($temp[0], $var[1], $var[3], $var[0], length $temp[9], "1");
				}
			}
		}
	}
	close SEQ;
}
########################################################
# Collect the genomic positions and the red positions associated with the mapping from the CIGAR string
########################################################
sub GET_POSITIONS{
	my ($head, $query, $cigar, $name, $read_size, $strand)=(@_);
	# adapted from https://davetang.org/muse/2011/01/28/perl-and-sam/
	my $position=$query;
	my $query_s=$query;
	my $query_e=0;
	my $read_s=0;
	my $read_e=0;
	my @query_positions;
	my $full_s=$query;
	my $full_e=0;
	my $temp_cigar=$cigar;
	my $counter1=0;
	while ($temp_cigar !~ /^$/){
		if ($temp_cigar =~ /^([0-9]+[MIDSNH=X])/){
			$counter1++;
			my $cigar_part=$1;
			$temp_cigar =~ s/$cigar_part//;
		}
	}
	my $counter2=0;
	my $temp_end=substr($cigar, -1);
	if($temp_end=~/H|S/){
		$cigar =~ s/.{1}$/Q/;
	}
	while ($cigar !~ /^$/){
		if ($cigar =~ /^([0-9]+[MIDSNHQX=])/){
			$counter2++;
			my $cigar_part = $1;
			if ($cigar_part =~ /(\d+)M/){
				$query_s=$query_e+1;
				$query_e=($query_s + $1)-1;
				$read_s=$read_e+1;
				$read_e=($read_s+$1)-1;
				push @query_positions, [$query_s, $query_e, $name, $read_s, $read_e, $1, $cigar_part];
				$full_e=$query_e;
			}
			elsif ($cigar_part =~ /(\d+)=/){
				$query_s=$query_e+1;
				$query_e=($query_s + $1)-1;
				$read_s=$read_e+1;
				$read_e=($read_s+$1)-1;
				push @query_positions, [$query_s, $query_e, $name, $read_s, $read_e, $1, $cigar_part];
				$full_e=$query_e;
			}
			elsif ($cigar_part =~ /(\d+)X/){
				$query_s=$query_e+1;
				$query_e=($query_s + $1)-1;
				$read_s=$read_e+1;
				$read_e=($read_s+$1)-1;
				push @query_positions, [$query_s, $query_e, $name, $read_s, $read_e, $1, $cigar_part];
				$full_e=$query_e;
			}
			elsif ($cigar_part =~ /(\d+)I/){
				$read_s=$read_e+1;
				$read_e=($read_s + $1) - 1;
				$query_s=$query_e;
				$query_e=$query_s;
			}
			elsif ($cigar_part =~ /(\d+)S/){
				$read_e=$read_s + $1;
				$query_e=$query_s-1;
			}
			elsif ($cigar_part =~ /(\d+)H/){
				$read_e=$read_s + $1;
				$query_e=$query_s-1;
			}
			elsif ($cigar_part =~ /(\d+)D/){
				$read_s=$read_e;
				$read_e=$read_s;
				$query_s=$query_e+1;
				$query_e=($query_s + $1)-1;
				$full_e=$query_e;
			}
			elsif ($cigar_part =~ /(\d+)N/){
				$read_s=$read_e;
				$read_e=$read_s;
				$query_s=$query_e+1;
				$query_e=($query_s + $1)-1;
				$full_e=$query_e;
			}
			elsif ($cigar_part =~ /(\d+)Q/){
			}
			$cigar =~ s/$cigar_part//;
		}
	}

	my @temp_pos1=sort{$a->[0]<=>$b->[1]}@query_positions;
	my @temp_pos2=sort{$a->[3]<=>$b->[4]}@query_positions;
	push @{$read_positions{$head}}, [$name, $temp_pos1[0][0], $temp_pos1[$#temp_pos1][1], $temp_pos2[0][3], $temp_pos2[$#temp_pos2][4], ($temp_pos2[$#temp_pos2][4]-$temp_pos2[0][3])+1];
	#positions of a read within a transcript use of a muti-dimentional array to take into account reads split in multiple entries of the sam file
	@query_positions=();
}
########################################################
########################################################
