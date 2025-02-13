To align unaligned BAM files from nanopore long-read sequencing to the human hg38 reference genome and perform methylation base calling, you can utilize the following tools:

1. **Dorado**: Developed by Oxford Nanopore Technologies, Dorado is a high-performance, open-source basecaller that supports modified basecalling. It processes raw nanopore reads, performs basecalling, and can output aligned reads in SAM/BAM format. Dorado also supports modified basecalling, enabling the detection of DNA methylation during the basecalling process. citeturn0search1

2. **Remora**: Remora is a tool designed to predict modified bases, such as methylation, from nanopore sequencing data. It works in conjunction with basecallers like Dorado to enhance modified base detection. Remora provides functionalities for data preparation, model training, and inference, allowing for accurate methylation calling. citeturn0search0

3. **Modkit**: After basecalling and alignment, Modkit can be used to process and analyze modified base data stored in BAM files. It converts modified base information into bedMethyl files, providing summary counts of modified and unmodified bases across the genome. This is useful for downstream analysis and visualization of methylation patterns.

**Workflow Summary**:

- **Basecalling and Alignment**: Use Dorado to perform basecalling on your raw nanopore reads and align them to the hg38 reference genome. Ensure that Dorado is configured to detect modified bases during this process.

- **Methylation Calling**: Utilize Remora to predict methylation sites from the basecalled data. Remora can work with the outputs from Dorado to enhance the detection of modified bases.

- **Post-Processing**: Apply Modkit to the aligned BAM files to generate bedMethyl files, summarizing the methylation data for further analysis.

These tools are available on GitHub and are well-suited for processing nanopore sequencing data with a focus on methylation analysis.

**Relevant Links**:

- [Dorado GitHub Repository](https://github.com/nanoporetech/dorado)
- [Remora GitHub Repository](https://github.com/nanoporetech/remora)
- [Modkit GitHub Repository](https://github.com/nanoporetech/modkit) 
