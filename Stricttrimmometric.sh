
##Strict trimmometric

########## Load Modules
module load fastqc/0.10.1
module load multiqc
module load trimmomatic/0.39

#  Set the stack size to unlimited
ulimit -s unlimited

# Turn echo on so all commands are echoed in the output log
set -x


##########  Define variables and make directories
## Replace the numbers in the brackets with Your specific information
  ## make variable for your ASC ID so the directories are automatically made in YOUR directory
MyID=aubtss          ## Example: MyID=aubtss

WD=/scratch/$MyID/Rat          ## Example:/scratch/$MyID/PracticeRNAseq  
DD=$WD/RawData
RDQ=RawDataQuality
adapters=AdaptersToTrim_All.fa  ## This is a fasta file that has a list of adapters commonly used in NGS sequencing. 
				## In the future, for your data, you will likely need to edit this for other projects based on how your libraries 
				## were made to search for the correct adapters for your project
CD=$WD/CleanData            				## Example:/scratch/$MyID/PracticeRNAseq/CleanData   #   *** This is where the cleaned paired files are located from the last script
PCQ=PostCleanQuality

##  make the directories in SCRATCH for holding the raw data 
## -p tells it to make any upper level directories that are not there.
mkdir -p ${WD}
mkdir -p ${DD}
## move to the Data Directory
cd ${DD}

#######
################****************** Step 2  Cleaning the data with Trimmomatic ###################################
#######


## make the directories to hold the Cleaned Data files, and the directory to hold the results for assessing quality of the cleaned data.
mkdir ${CD}
mkdir ${WD}/${PCQ}


## Move to Raw Data Directory
cd ${DD}

### Make list of file names to Trim
        ## this line is a set of piped (|) commands
        ## ls means make a list, 
        ## grep means grab all the file names that end in ".fastq", 
        ## cut that name into elements every where you see "_" and keep the first element (-f 1)
        ## sort the list and keep only the unique names and put it into a file named "list"
ls | grep ".fastq" |cut -d "_" -f 1 | sort | uniq > list

### Copy over the list of Sequencing Adapters that we want Trimmomatic to look for (along with its default adapters)
        ## CHECK: You may need to edit this path for the file that is in the class_shared directory from your account.
cp /home/${MyID}/class_shared/AdaptersToTrim_All.fa . 

### Run a while loop to process through the names in the list and Trim them with the Trimmomatic Code
while read i
do

        ### Run Trimmomatic in paired end (PE) mode with 6 threads using phred 33 quality score format. 
        ## STOP & DISCUSS: Check out the trimmomatic documentation to understand the parameters in line 77
	       java -jar /apps/x86-64/apps/spack_0.19.1/spack/opt/spack/linux-rocky8-zen3/gcc-11.3.0/trimmomatic-0.39-iu723m2xenra563gozbob6ansjnxmnfp/bin/trimmomatic-0.39.jar   \
					PE -threads 6 -phred33 \
        	"$i"_1.fastq "$i"_2.fastq  \
       	 ${CD}/"$i"_1_paired.fastq ${CD}/"$i"_1_unpaired.fastq  ${CD}/"$i"_2_paired.fastq ${CD}/"$i"_2_unpaired.fastq \
       	ILLUMINACLIP:AdaptersToTrim_All.fa:2:35:10 HEADCROP:20 LEADING:40 TRAILING:40 SLIDINGWINDOW:6:30 MINLEN: 46
        
                ## Trim read for quality when quality drops below Q30 and remove sequences shorter than 36 bp
                ## PE for paired end phred-score-type  R1-Infile   R2-Infile  R1-Paired-outfile R1-unpaired-outfile R-Paired-outfile R2-unpaired-outfile  Trimming paramenter
                ## MINLEN:<length> #length: Specifies the minimum length of reads to be kept.
                ## SLIDINGWINDOW:<windowSize>:<requiredQuality>  #windowSize: specifies the number of bases to average across  
                ## requiredQuality: specifies the average quality required.

	############## FASTQC to assess quality of the Cleaned sequence data
	## FastQC: run on each of the data files that have 'All' to check the quality of the data
	## The output from this analysis is a folder of results and a zipped file of results

fastqc ${CD}/"$i"_1_paired.fastq --outdir=${WD}/${PCQ}
fastqc ${CD}/"$i"_2_paired.fastq --outdir=${WD}/${PCQ}


done<list			# This is the end of the loop

################## Run MultiQC to summarize the fastqc results
### move to the directory with the cleaned data
cd ${WD}/${PCQ}
multiqc ${WD}/${PCQ}

########################  Now compress your results files from the Quality Assessment by FastQC 
#######  Tarball the directory containing the FASTQC results so we can easily bring it back to our computer to evaluate.
tar cvzf ${PCQ}.tar.gz ${WD}/${PCQ}/*

