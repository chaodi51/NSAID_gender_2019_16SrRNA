rule rm_primers:
    input:
        per_sample_sequences = "../results/qiime2/" + proj_name + "-PE-demux/per_sample_sequences.qza"
    output:
        primerRM = "../results/qiime2/" + proj_name + "-PE-demux-noprimer.qza",
        primerRM_viz = "../results/qiime2/" + proj_name + "-PE-demux-noprimer.qzv"
    log:
        "logs/" + proj_name + "_qiime2_rm_primers.log"
    params:
        mem = '20G',
        jobName = proj_name + "_qiime2_rm_primers"
    threads: 8
    # conda:
    #     "../envs/qiime2.yaml"
    shell:
        '''
        qiime cutadapt trim-paired \
            --p-cores {threads} \
            --i-demultiplexed-sequences {input.per_sample_sequences} \
            --p-front-f {config[primerF]} \
            --p-front-r {config[primerR]} \
            --p-error-rate {config[primer_err]} \
            --p-overlap {config[primer_overlap]} \
            --p-match-read-wildcards \
            --p-match-adapter-wildcards \
            --o-trimmed-sequences {output.primerRM} &> {log}


        qiime demux summarize \
            --i-data {output.primerRM} \
            --o-visualization {output.primerRM_viz} &>> {log}
        '''
