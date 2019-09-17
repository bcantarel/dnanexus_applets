#!/bin/bash
# platypus 0.0.1
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

    echo "Value of bamfiles: '${bamfiles[@]}'"
    echo "Value of reference: '$reference'"

    export LD_LIBRARY_PATH=/samtools_1.2/bcftools/htslib-1.2.1:$LD_LIBRARY_PATH
    export PYTHONPATH=/Platypus_0.8.1/build/lib.linux-x86_64-2.7/:$PYTHONPATH

    dx download "$reference" -o reference.fa.gz
    for i in ${!bamfiles[@]}
    do
        dx download "${bamfiles[$i]}" -o file-$i.bam
	/samtools_1.2/samtools index file-$i.bam
    done
    
    gunzip reference.fa.gz
    /samtools_1.2/samtools faidx reference.fa
    
    infile=$(printf "%s," file-*.bam)
    echo " python /usr/bin/Platypus.py callVariants --bamFiles="${infile%,}" --refFile=reference.fa --output=vcffile"
    
    python /Platypus_0.8.1/Platypus.py callVariants --bamFiles="${infile%,}" --refFile=reference.fa --output=vcf
    gzip vcf
    
    vcffile=$(dx upload vcf.gz --destination platypus.vcf.gz --brief)

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    dx-jobutil-add-output vcffile "$vcffile" --class=file
}