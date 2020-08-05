#!/bin/bash
# align_markdups 0.5.40
# Generated by dx-app-wizard.

main() {

    dx download "$fq1" -o ${pair_id}.R1.fastq.gz
    dx download "$fq2" -o ${pair_id}.R2.fastq.gz
    dx download "$humanref" -o humanref.tar.gz

    mkdir humanref
    docker run -v ${PWD}:/data docker.io/goalconsortium/alignment:0.5.40 tar -I pigz -xvf humanref.tar.gz --strip-components=1 -C humanref
    
    alignopt=''
    if [[ -n ${umi} ]]
    then
	alignopt=" -u"
    fi
    
    docker run -v ${PWD}:/data docker.io/goalconsortium/alignment:0.5.40 bash /seqprg/school/process_scripts/alignment/dnaseqalign.sh -r humanref -p ${pair_id} -x ${pair_id}.R1.fastq.gz -y ${pair_id}.R2.fastq.gz $alignopt
    rawbam=$(dx upload ${pair_id}.bam --brief)
    rawbai=$(dx upload ${pair_id}.bam.bai --brief)
    dx-jobutil-add-output rawbam "$rawbam" --class=file
    dx-jobutil-add-output rawbai "$rawbai" --class=file
    
    if [[ -n $virusref ]]
    then
	dx download "$virusref" -o virusref.tar.gz
	mkdir virusref
	tar xvfz virusref.tar.gz --strip-components=1 -C virusref

	docker run -v ${PWD}:/data docker.io/goalconsortium/alignment:0.5.40 bash /seqprg/school/process_scripts/alignment/virusalign.sh -b ${pair_id}.bam -p ${pair_id} -r virusref -f
	vseqstat=$(dx upload ${pair_id}.viral.seqstats.txt --brief)
	dx-jobutil-add-output vseqstat "$vseqstat" --class=file
    fi

}
