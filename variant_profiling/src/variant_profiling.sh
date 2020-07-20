#!/bin/bash
# Structural_Variants 0.5.19
# Generated by dx-app-wizard.

main() {

    dx download "$Tumor_BAM" -o ${pair_id}.tumor.bam
    dx download "$reference" -o dnaref.tar.gz

    tar xvfz dnaref.tar.gz

    if [ -n "$panel" ]
    then
        dx download "$panel" -o panel.tar.gz
        tar xvfz panel.tar.gz
    fi

    if [ -n "$Normal_BAM" ]
    then
        dx download "$Normal_BAM" -o ${pair_id}.normal.bam
    fi

    docker run -v ${PWD}:/data docker.io/goalconsortium/variantcalling:0.5.19 bash /seqprg/genomeseer/process_scripts/alignment/indexbams.sh

    normopt=''
    if [[ -n "$Normal_BAM" ]]
    then
	normopt=" -n ${pair_id}.normal.bam"
    fi

    if [[ "${algo}" == "msisensor" ]]
    then
        docker run -v ${PWD}:/data docker.io/goalconsortium/vcfannot:0.5.19 bash /seqprg/genomeseer/process_scripts/variants/msisensor.sh -r dnaref -p ${pair_id} -b ${pair_id}.tumor.bam -c targetpanel.bed $normopt
	msiout=$(dx upload ${pair_id}.msi --brief)
	dx-jobutil-add-output msiout "$msiout" --class=file
	
    elif [[ "${algo}" == "checkmates" ]]
    then
        docker run -v ${PWD}:/data docker.io/goalconsortium/vcfannot:0.5.19 python /usr/local/bin/ncm.py -B -d ./ -bed dnaref/NGSCheckMate.bed -O ./ -N ${pair_id}
        docker run -v ${PWD}:/data docker.io/goalconsortium/vcfannot:0.5.19 perl /seqprg/genomeseer/scripts/sequenceqc_somatic.pl -r dnaref -i ${pair_id}_all.txt -o ${pair_id}.sequence.stats.txt
	
        matched=$(dx upload ${pair_id}_matched.txt --brief)
        all=$(dx upload ${pair_id}_all.txt --brief)
        seqstats=$(dx upload ${pair_id}.sequence.stats.txt --brief)
	
        dx-jobutil-add-output matched "$matched" --class=file
        dx-jobutil-add-output all "$all" --class=file
        dx-jobutil-add-output seqstats "$seqstats" --class=file
	
    else
        echo "Incorrect algorithm selection. Please select 1 of the following algorithms: msisensor, checkmates"
    fi
}
