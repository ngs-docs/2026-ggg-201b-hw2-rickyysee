rule all:
    input:
        "SRR2584857_quast.4000000", # 4m lines, 1m reads, 66X
        "SRR2584857_annot.4000000",
        "SRR2584857_quast.2000000", # 2m lines, 0.5m reads, 33X
        "SRR2584857_annot.2000000",
        "SRR2584857_quast.1000000", # 1m lines, 0.25m reads, 16.6X
        "SRR2584857_annot.1000000",
        "SRR2584857_quast.500000", # 0.5m lines, 0.125m reads, 8.3X
        "SRR2584857_annot.500000",

rule subset_reads:
    input:
        "{sample}.fastq.gz",
    output:
        "{sample}.{subset}.fastq.gz"
    shell: """
        gunzip -c {input} | head -{wildcards.subset} | gzip -9c > {output} || true
    """

rule annotate:
    input:
        "SRR2584857-assembly.{subset}.fa"
    output:
        directory("SRR2584857_annot.{subset}")
    conda: "prokka"
    shell: """
       prokka --prefix {output} {input}                                       
    """

rule assemble:
    input:
        r1 = "SRR2584857_1.{subset}.fastq.gz",
        r2 = "SRR2584857_2.{subset}.fastq.gz"
    output:
        dir = directory("SRR2584857_assembly.{subset}"),
        assembly = "SRR2584857-assembly.{subset}.fa"
    conda: "megahit"
    shell: """
       megahit -1 {input.r1} -2 {input.r2} -f -m 5e9 -t 4 -o {output.dir}     
       cp {output.dir}/final.contigs.fa {output.assembly}                     
    """

rule quast:
    input:
        "SRR2584857-assembly.{subset}.fa"
    output:
        directory("SRR2584857_quast.{subset}")
    conda: "megahit"
    shell: """                                                                
       quast {input} -o {output}                                              
    """
