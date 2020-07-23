#!/bin/bash
# CNV_ITDSeek 0.5.25
# Generated by dx-app-wizard.

main() {

    dx download "$Raw_BAM" -o ${pair_id}.bam
    dx download "$Raw_BAI" -o ${pair_id}.bam.bai
    dx download "$panel" -o panel.tar.gz
    dx download "$reference" -o ref.tar.gz

    mkdir dnaref
    tar xvfz ref.tar.gz --strip-components=1 -C dnaref

    mkdir -p panel
    tar xvfz panel.tar.gz -C panel/
    docker run -v ${PWD}:/data docker.io/goalconsortium/vcfannot:0.5.25 bash /seqprg/genomeseer/process_scripts/variants/cnvkit.sh -r dnaref -b ${pair_id}.bam -p ${pair_id} -d panel
    
    tar -czvf ${pair_id}.cnvout.tar.gz ${pair_id}.answerplot* ${pair_id}.*txt ${pair_id}.call.cns ${pair_id}.cns ${pair_id}.cnr

    cnvout=$(dx upload ${pair_id}.cnvout.tar.gz --brief)
    dx-jobutil-add-output cnvout "$cnvout" --class=file

}