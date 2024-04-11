#! /bin/bash

source /apps/profiles/modules_asax.sh.dyn
module load trimgalore/0.6.7

## Move to Raw Data Directory
cd ${DD}

### Make list of file names to Trim
        ## this line is a set of piped (|) commands
        ## ls means make a list, 
        ## grep means grab all the file names that end in ".fastq", 
        ## cut that name into elements every where you see "_" and keep the first element (-f 1)
        ## sort the list and keep only the unique names and put it into a file named "list"
ls | grep ".fastq" |cut -d "_" -f 1 | sort | uniq > list


while read i
do

        ### Run Trimmomatic in paired end (PE) mode with 6 threads using phred 33 quality score format. 
        ## STOP & DISCUSS: Check out the trimmomatic documentation to understand the parameters in line 77
	      
trim_galore --paired --q 30 --illumina --three_prime_clip_R2 10 --length 36 "$i"_1.fastq "$i"_2.fastq -o ${CD}/

fastqc ${CD}/"$i"_1_trimmed.fq --outdir=${OP}/${PCQ}
fastqc ${CD}/"$i"_2_trimmed.fq --outdir=${OP}/${PCQ}


done<list	

###Make sure to change to change the name of the paired data throught out your script
##this eliminates anything below phred scroe 30, read with a length of 36, and the first 10 bases of the read.
