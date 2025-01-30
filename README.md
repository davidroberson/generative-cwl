# Generative CWL Repository

This repository offers a range of bioinformatics workflows and tools using the Common Workflow Language (CWL), particularly for cancer, multi-omics, and population genomics research.  Leveraging the power of large language models (LLMs), these resources are designed to be comprehensive, well-documented, and easily reusable, enabling efficient and reproducible genomics analysis.

## Repository Structure

```
generative-cwl/
├── cwl-tool-library/           # Reusable CWL tool definitions
│   ├── alignment_tools.cwl     # Tools for sequence alignment
│   ├── expression_analysis_tools.cwl  # RNA-seq and expression analysis tools
│   ├── qc_tools.cwl           # Quality control and reporting tools
│   └── variant_analysis_tools.cwl    # Variant calling and annotation tools
└── tumor-multiomics/          # Complete workflow documentation and analysis plans
    ├── Workflow_01_Tumor_Exome_Analysis_Workflow.md
    ├── Workflow_02_RNA-Seq_Analysis_Workflow.md
    ├── Workflow_03_Whole_Genome_Sequencing_Analysis_Workflow.md
    ├── Workflow_5_Downstream_Analysis_and_Visualization.md
    └── Complete_Tools_and_Containers_Reference_for_Multi-omics_Analysis.md
```

## Tools vs Workflows

### Tools (CWL Tool Definitions)
- Individual, atomic operations (e.g., BWA alignment, GATK variant calling)
- Defined in CWL with specific Docker container requirements
- Grouped by function in the `cwl-tool-library` directory
- Reusable components that can be integrated into different workflows
- Include resource specifications and error handling

### Workflows (Markdown Documentation)
- Complete analysis pipelines combining multiple tools
- Documented in Markdown for better readability and maintenance
- Include Mermaid diagrams for visual representation
- Provide comprehensive documentation of:
  - Input/output specifications
  - Resource requirements
  - Quality control steps
  - Best practices
  - Error handling
  - Integration points

## Tool Collections

The `cwl-tool-library` contains tools grouped by function.  Why? Less files.
   - SnpEff for variant annotation

## Workflows

Detailed workflow documentation is provided in Markdown format.  Why not CWL..Less files.

## Testing

### Tool Testing
Each CWL tool includes test cases:
```yaml
tests:
  - job: test/tool_test_job.yml
    output:
      output_file:
        location: expected/output.txt
```

### Workflow Testing
- Test datasets provided for each workflow
- Integration tests for multi-step processes
- Resource requirement validation
- Docker container verification

## Future Development

### Planned Additions
1. Additional analysis workflows for:
   - Single-cell RNA sequencing
   - ATAC-seq analysis
   - Proteomics integration
   - Metabolomics analysis

2. Enhanced documentation:
   - Interactive workflow visualizations
   - Performance optimization guides
   - Troubleshooting documentation

3. Extended tool collections:
   - Machine learning tools
   - Data visualization components
   - Report generation utilities

## LLM Generation

This repository leverages LLM technology for:
- Documentation generation
- Workflow design
- Best practices compilation
- Error handling strategies

The prompts used for generation are included in:
- `tumor-multiomics/llm_generative_prompt.md`

## Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with:
   - Clear description of changes
   - Updated documentation
   - Additional test cases
   - Resource specifications

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Citation

If you use these workflows in your research, please cite:
[Citation information to be added]

## Contact

For questions or suggestions, please open an issue in the repository.
