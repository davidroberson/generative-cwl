# Variant Analysis Tools Collection
# File: variant_tools.cwl

# GATK MarkDuplicates Tool
cwlVersion: v1.2
class: CommandLineTool
id: gatk_markduplicates_tool
label: Mark duplicate reads in BAM files
baseCommand: [gatk, MarkDuplicates]
requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.3.0.0
  ResourceRequirement:
    ramMin: 32000
    coresMin: 1

inputs:
  input_bam:
    type: File
    inputBinding:
      prefix: -I
  output_name:
    type: string
    inputBinding:
      prefix: -O
  metrics_file:
    type: string
    inputBinding:
      prefix: -M

outputs:
  dedup_bam:
    type: File
    outputBinding:
      glob: $(inputs.output_name)
  metrics:
    type: File
    outputBinding:
      glob: $(inputs.metrics_file)

---
# GATK BaseRecalibrator Tool
cwlVersion: v1.2
class: CommandLineTool
id: gatk_baserecalibrator_tool
label: Detect systematic errors in base quality scores
baseCommand: [gatk, BaseRecalibrator]
requirements:
  DockerRequirement:
    dockerPull: broadinstitute/gatk:4.3.0.0
  ResourceRequirement:
    ramMin: 32000
    coresMin: 1

inputs:
  input_bam:
    type: File
    inputBinding:
      prefix: -I
  reference:
    type: File
    secondaryFiles:
      - .fai
      - ^.dict
    inputBinding:
      prefix: -R
  known_sites:
    type: File[]
    inputBinding:
      prefix: --known-sites
  output_name:
    type: string
    inputBinding:
      prefix: -O

outputs:
  recal_table:
    type: File
    outputBinding:
      glob: $(inputs.output_name)

---
# SnpEff Tool
cwlVersion: v1.2
class: CommandLineTool
id: snpeff_tool
label: Genetic variant annotation and effect prediction
baseCommand: snpEff
requirements:
  DockerRequirement:
    dockerPull: biocontainers/snpeff:5.0
  ResourceRequirement:
    ramMin: 16000
    coresMin: 4

inputs:
  input_vcf:
    type: File
    inputBinding:
      position: 2
  genome_version:
    type: string
    inputBinding:
      position: 1
  config:
    type: File?
    inputBinding:
      prefix: -config

outputs:
  annotated_vcf:
    type: File
    outputBinding:
      glob: "snpEff_*.vcf"
  stats:
    type: File
    outputBinding:
      glob: "snpEff_summary.html"
