# Alignment Tools Collection
# File: alignment_tools.cwl

# BWA-MEM Tool
cwlVersion: v1.2
class: CommandLineTool
id: bwa_mem_tool
label: Burrows-Wheeler Aligner for short-read alignment
baseCommand: [bwa, mem]
requirements:
  DockerRequirement:
    dockerPull: biocontainers/bwa:0.7.17
  ResourceRequirement:
    ramMin: 16000
    coresMin: 8

inputs:
  reference:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
    inputBinding:
      position: 1
  reads1:
    type: File
    inputBinding:
      position: 2
  reads2:
    type: File?
    inputBinding:
      position: 3
  threads:
    type: int?
    default: 8
    inputBinding:
      prefix: -t
  read_group:
    type: string?
    inputBinding:
      prefix: -R

outputs:
  aligned_sam:
    type: stdout

stdout: $(inputs.reads1.nameroot).sam

---
# STAR Tool
cwlVersion: v1.2
class: CommandLineTool
id: star_aligner_tool
label: Spliced Transcripts Alignment to a Reference
baseCommand: STAR
requirements:
  DockerRequirement:
    dockerPull: biocontainers/star:2.7.9a
  ResourceRequirement:
    ramMin: 32000
    coresMin: 12

inputs:
  genome_dir:
    type: Directory
    inputBinding:
      prefix: --genomeDir
  fastq1:
    type: File
    inputBinding:
      prefix: --readFilesIn
      position: 1
  fastq2:
    type: File?
    inputBinding:
      position: 2
  threads:
    type: int?
    default: 12
    inputBinding:
      prefix: --runThreadN
  output_prefix:
    type: string
    inputBinding:
      prefix: --outFileNamePrefix

outputs:
  aligned_bam:
    type: File
    outputBinding:
      glob: "*Aligned.out.bam"
  log_file:
    type: File
    outputBinding:
      glob: "*Log.final.out"
