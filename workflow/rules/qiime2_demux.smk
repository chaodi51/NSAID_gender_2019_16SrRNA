rule qiime2_demux:
    input:
        barcodes = barcodes,
        imported = "../results/qiime2/" + proj_name + "-PE-sequences.qza"
    output:
        per_sample_sequences = "../results/qiime2/" + proj_name + "-PE-demux/per_sample_sequences.qza",
        error_correction_details = "../results/qiime2/" + proj_name + "-PE-demux/error_correction_details.qza"
    log:
        "logs/" + proj_name + "_qiime2_demux.log"
    params:
        mem = '10G',
        jobName = proj_name + "_qiime2_demux",
        outdir = "../results/qiime2/" + proj_name + "-PE-demux" 
    threads: 1
    shell:
        '''
        qiime demux emp-paired \
            --m-barcodes-file {input.barcodes} \
            --m-barcodes-column BarcodeSequence \
            --i-seqs {input.imported} \
            --p-rev-comp-mapping-barcodes \
            --p-no-golay-error-correction \
            --o-per-sample-sequences {output.per_sample_sequences} \
            --o-error-correction-details {output.error_correction_details} &> {log}

        qiime demux summarize \
            --i-data {params.outdir}/per_sample_sequences.qza \
            --o-visualization {params.outdir}/per_sample_sequences.qzv &>> {log}

        qiime tools export \
            --input-path {params.outdir}/per_sample_sequences.qzv \
            --output-path {params.outdir}/demux &>> {log}
        '''
