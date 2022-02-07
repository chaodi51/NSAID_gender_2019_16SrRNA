rule fastqc:
  input:    
    "raw_fq/{sample}_{num}" + SUF
  output:
    html = "../results/fastqc/{sample}_{num}_fastqc.html",
    zip = "../results/fastqc/{sample}_{num}_fastqc.zip"
  params: 
    jobName = "fastqc.{sample}"
  threads: 1
  log:
    "logs/fastqc/{sample}_{num}.log"
  shell:
    "fastqc --quiet -t {threads} --outdir ../results/fastqc {input} &> {log}"

rule trimmomatic_pe:
  input:
    r1 = "raw_fq/{sample}_" + R1_SUF + SUF,
    r2 = "raw_fq/{sample}_" + R2_SUF + SUF
  output:
    r1 = "../results/trimmed/{sample}_" + R1_SUF + "_trim.fastq.gz",
    r2 = "../results/trimmed/{sample}_" + R2_SUF + "_trim.fastq.gz",
    # reads where trimming entirely removed the mate
    r1_unpaired = "../results/trimmed/{sample}_1.unpaired.fastq.gz",
    r2_unpaired = "../results/trimmed/{sample}_2.unpaired.fastq.gz"
  log:
    "logs/trimmomatic/{sample}.log"
  params:
    jobName = "trimmomatic_pe.{sample}",
    trimmer = ["LEADING:2", "TRAILING:2", "SLIDINGWINDOW:4:15", "MINLEN:36"],
    extra = ""
  shell:
      '''  
        trimmomatic PE -threads {threads} -phred33 -quiet {input.r1} {input.r2} \
        {output.r1} {output.r1_unpaired} {output.r2} {output.r2_unpaired} {params.trimmer}
      '''
      
rule fastqc_trim:
  input:
    "../results/trimmed/{sample}_{num}_trim.fastq.gz"
  output:
    html = "../results/fastqc_trim/{sample}_{num}_trim_fastqc.html",
    zip = "../results/fastqc_trim/{sample}_{num}_trim_fastqc.zip"
  params:
    jobName = "fastqc_trim.{sample}"
  threads: 1
  log:
    "logs/fastqc_trim/{sample}_{num}_trimmed.log"
  shell:
    "fastqc --quiet -t {threads} --outdir ../results/fastqc_trim {input} &> {log}"

rule multiqc:
  input:
    raw_qc = expand("../results/fastqc/{sample}_{num}_fastqc.zip", sample=SAMPLE_SET, num=SET_NUMS),
    trim_qc = expand("../results/fastqc_trim/{sample}_{num}_trim_fastqc.zip", sample=SAMPLE_SET, num=SET_NUMS)
  output:
    raw_multi_html = "../results/raw_multi_fastqc/multiqc.html", 
    trim_multi_html = "../results/trim_multi_fastqc/multiqc.html"
  threads: 1
  log:
    "logs/multiqc.log"
  params:
    jobName = "multiqc"
  shell: 
    """
    multiqc --force --quiet --filename multiqc.html --outdir ../results/raw_multi_fastqc {input.raw_qc} &> {log} #run multiqc
    # repeat for trimmed data
    multiqc --force --quiet --filename multiqc.html --outdir ../results/trim_multi_fastqc {input.trim_qc} &>> {log} #run multiqc
    """ 