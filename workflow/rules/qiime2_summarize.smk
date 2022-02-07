rule qiime2_summarize:
    input:
        q2_import = "../results/qiime2/" + proj_name + "-PE-demux.qza",
        q2_primerRM = "../results/qiime2/" + proj_name + "-PE-demux-noprimer.qza"
    output:
        raw = "../results/qiime2/" + proj_name + "-PE-demux.qzv",
        primer = "../results/qiime2/" + proj_name + "-PE-demux-noprimer.qzv"
    log:
        "logs/qiime2_summarize.log"
    params:
        mem = '30G',
        jobName = "qiime2_summarize" 
    threads: 4

    conda: "../envs/qiime2-2020.11.yaml"

    shell:
        '''
        # Creates a QIIME2 summary artifact on demultiplexed FASTQ sequences
        qiime demux summarize --i-data {input.q2_import} --o-visualization {output.raw} &> {log}
        qiime demux summarize --i-data {input.q2_primerRM} --o-visualization {output.primer} &>> {log}
        '''