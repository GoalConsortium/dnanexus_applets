#!/bin/bash
# trim_galore 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {
    echo "Value of fq1: '$fq1'"
    echo "Value of fq2: '$fq2'"
    echo "Value of pair_id: '$pair_id'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    dx download "$fq1" -o seq.R1.fastq.gz
    if [ -n "$fq2" ]
    then
        dx download "$fq2" -o seq.R2.fastq.gz
    fi
    if [ -z "$pair_id" ]
    then
	filename=$(dx describe --name "${fq1}")
	pair_id=${filename%.fastq.gz}
    fi

    r1base="seq.R1"
    r2base="seq.R2"
    
    if [ -n "$fq2" ]
    then
	docker run -v ${PWD}:/data docker.io/goalconsortium/trim_galore:v1 trim_galore --paired -q 25 --illumina --gzip --length 35 seq.R1.fastq.gz seq.R2.fastq.gz
	mv ${r1base}_val_1.fq.gz ${pair_id}.trim.R1.fastq.gz
	mv ${r2base}_val_2.fq.gz ${pair_id}.trim.R2.fastq.gz
    else
	docker run -v ${PWD}:/data docker.io/goalconsortium/trim_galore:v1 trim_galore -q 25 --illumina --gzip --length 35 ${fq1}
	mv ${r1base}_trimmed.fq.gz ${pair_id}.trim.R1.fastq.gz
	cp ${pair_id}.trim.R1.fastq.gz ${pair_id}.trim.R2.fastq.gz 
    fi
    perl /process_scripts/preproc_fastq/parse_trimreport.pl ${pair_id}.trimreport.txt *trimming_report.txt

    trim1=$(dx upload ${pair_id}.trim.R1.fastq.gz --brief)
    trimreport=$(dx upload ${pair_id}.trimreport.txt --brief)
    
    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    dx-jobutil-add-output trim1 "$trim1" --class=file
    dx-jobutil-add-output trimreport "$trimreport" --class=file

    if [ -n "$fq2" ]
    then
	trim2=$(dx upload ${pair_id}.trim.R2.fastq.gz --brief)
	dx-jobutil-add-output trim2 "$trim2" --class=file
    fi
}
