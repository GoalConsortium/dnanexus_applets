#!/bin/bash
# geneabund 0.5.19
# Generated by dx-app-wizard.

main() {

    dx download "$Aligned_BAM" -o ${pair_id}.bam
    dx download "$reference" -o rnaref.tar.gz

    tar xvfz reference.tar.gz

    docker run -v ${PWD}:/data docker.io/goalconsortium/geneabund:0.5.19 -s ${stranded} -g rnaref/gencode.gtf -p ${pair_id} -b ${pair_id}.bam -f $glist

    counts=$(dx upload ${pair_id}.cts --brief)
    strcts=$(dx upload ${pair_id}_stringtie --brief)
    fpkm=$(dx upload ${pair_id}.fpkm.txt --brief)

    dx-jobutil-add-output counts "$counts" --class=file
    dx-jobutil-add-output strcts "$strcts" --class=file
    dx-jobutil-add-output fpkm "$fpkm" --class=file
}
