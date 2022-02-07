rule download:
    # input:
    output:
        outdir = directory("raw_fq"),
        metadata = "raw_fq/Kelly_AdultCDI_2020_metadata.csv"
    threads: 1
    log: "logs/download.log"
    params:
        project = "PRJNA682076" 
    shell:
        '''
        grabseqs sra {params.project} -m {output.metadata} -o {output.outdir} -r 3

        '''