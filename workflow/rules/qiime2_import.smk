rule qiime2_import:
    input:
        raw_fq = raw_fq
    output:
        imported = "../results/qiime2/" + proj_name + "-PE-sequences.qza",
    log:
        "logs/" + proj_name + "_qiime2_import.log"
    params:
        mem = '5G',
        jobName = proj_name + "_qiime2_import" 
    threads: 4
    shell:
        '''
        # Imports paired end FASTQ files separately for males and females
        qiime tools import \
            --type EMPPairedEndSequences \
            --input-path {input.raw_fq} \
            --output-path {output.imported} &> {log}
        '''
