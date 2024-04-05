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
	      
trim_galore --paired --q 20 --illumina "$i"_1.fastq "$i"_2.fastq -o ${CD}/

fastqc ${CD}/"$i"_1_val_1.fq --outdir=${OP}/${PCQ}
fastqc ${CD}/"$i"_2_val_2.fq --outdir=${OP}/${PCQ}


done<list	

###Make sure to change to change the name of the paired data throught out your script

