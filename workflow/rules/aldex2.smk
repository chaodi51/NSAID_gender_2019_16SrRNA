rule aldex2:
  input:
    table_Celecoxib = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_Celecoxib.qza",
    table_Naproxen = "../results/qiime2/asv/dada2/" + proj_name + "-asv-table_Naproxen.qza",
    metadata_Celecoxib = config['metadata_Celecoxib'],
    metadata_Naproxen = config['metadata_Naproxen']
  output:
    differentials_Celecoxib = "../results/qiime2/asv/aldex2/Celecoxib_test/" + proj_name + "-differentials.qza",
    differentials_Celecoxib_viz = "../results/qiime2/asv/aldex2/Celecoxib_test/" + proj_name + "-differentials.qzv",
    differentials_Naproxen =  "../results/qiime2/asv/aldex2/Naproxen_test/" + proj_name + "-differentials.qza",
    differentials_Naproxen_viz =  "../results/qiime2/asv/aldex2/Naproxen_test/" + proj_name + "-differentials.qzv",
    differentials_Celecoxib_sig = "../results/qiime2/asv/aldex2/Celecoxib_test/" + proj_name + "-differentials-sig.qza",
    differentials_Naproxen_sig =  "../results/qiime2/asv/aldex2/Naproxen_test/" + proj_name + "-differentials-sig.qza"
  log:
    "logs/" + proj_name + "_aldex2.log"
  params:
    mem = '10G',
    jobName = proj_name + "_aldex2",
    outdir_Celecoxib = "../results/qiime2/asv/aldex2/Celecoxib_test/" + proj_name, 
    outdir_Naproxen = "../results/qiime2/asv/aldex2/Naproxen_test/" + proj_name 
  shell:
    '''
    conda activate qiime2-2019.7
    # for drug Celecoxib
    qiime aldex2 aldex2 \
        --i-table {input.table_Celecoxib} \
        --m-metadata-file {input.metadata_Celecoxib} \
        --m-metadata-column study_group \
        --o-differentials {output.differentials_Celecoxib} \
        --verbose &> {log}

 
    qiime aldex2 effect-plot \
        --i-table {output.differentials_Celecoxib} \
        --o-visualization {output.differentials_Celecoxib_viz} &>> {log}


    qiime aldex2 extract-differences \
        --i-table {output.differentials_Celecoxib} \
        --o-differentials {output.differentials_Celecoxib_sig} \
        --p-sig-threshold {config[p-sig-threshold_Celecoxib]} \
        --p-effect-threshold 0 \
        --p-difference-threshold 0 &>> {log}    

    # qiime tools export \
    #     --input-path {output.differentials_Celecoxib_sig} \
    #     --output-path {params.outdir_Celecoxib}/differentially-expressed-features &>> {log}

    # # for drug Naproxen   
    qiime aldex2 aldex2 \
        --i-table {input.table_Naproxen} \
        --m-metadata-file {input.metadata_Naproxen} \
        --m-metadata-column study_group \
        --o-differentials {output.differentials_Naproxen} \
        --verbose &>> {log}
 
    qiime aldex2 effect-plot \
        --i-table {output.differentials_Naproxen} \
        --o-visualization {output.differentials_Naproxen_viz} &>> {log}

    qiime aldex2 extract-differences \
        --i-table {output.differentials_Naproxen} \
        --o-differentials {output.differentials_Naproxen_sig} \
        --p-sig-threshold {config[p-sig-threshold_Naproxen]} \
        --p-effect-threshold 0 \
        --p-difference-threshold 0 &>> {log}    

    # qiime tools export \
    #     --input-path {output.differentials_Naproxen_sig} \
    #     --output-path {params.outdir_Naproxen}/differentially-expressed-features &>> {log}

    conda deactivate    
    '''