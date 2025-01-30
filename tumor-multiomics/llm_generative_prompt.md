# Prompt for Multi-omics Analysis Pipeline Documentation

Please help me create comprehensive documentation for a multi-omics analysis pipeline with the following specifications:

## Study Design
Create documentation for a cancer multi-omics study with:
- 1000 tumor samples with paired WES and RNA-seq data
- Subset of samples with matched blood normal WGS
- Optical Genome Mapping (OGM) data available
- Focus on integrating multiple data types for comprehensive analysis

## Required Documentation Components

### 1. Overview Document
Create a markdown document that includes:
- Study design description
- Sample overview and specifications
- Data generation details for each assay type
- Integrated workflow diagram using Mermaid
- Computational requirements
- Quality control strategy
- Data management plan
- Timeline estimates

### 2. Workflow Documentation
Create detailed specifications for each of these workflows:

#### Workflow 1: Tumor Exome Analysis
- Quality control
- Alignment
- Variant calling
- Copy number analysis
- Include CWL implementation
- Include Mermaid diagram
- Include resource requirements
- Include best practices

#### Workflow 2: RNA-Seq Analysis
- Quality control
- Alignment
- Expression quantification
- Differential expression
- Include CWL implementation
- Include Mermaid diagram
- Include resource requirements
- Include best practices

#### Workflow 3: WGS Analysis
- Quality control
- Alignment
- Variant calling
- Structural variant analysis
- Include CWL implementation
- Include Mermaid diagram
- Include resource requirements
- Include best practices

#### Workflow 4: Integration Analysis
- Data preparation steps
- Integration methods
- Network analysis
- Clinical correlation
- Include analysis components
- Include resource requirements
- Include visualization approaches

#### Workflow 5: Downstream Analysis
- Figure generation
- Statistical analysis
- Report generation
- Data sharing
- Include automation features
- Include quality control measures
- Include best practices

### 3. Tool Documentation
For each workflow, provide:
- List of required tools
- Container information
- Resource requirements
- CWL tool descriptions including:
  * Docker requirements
  * Resource specifications
  * Input/output definitions
  * Command line configurations
  * Error handling
  * Best practices

## Specific Requirements

### For Each Workflow
1. **CWL Specifications**
   - Complete workflow in CWL
   - Individual tool descriptions
   - Resource requirements
   - Input/output definitions

2. **Visual Documentation**
   - Mermaid diagram showing workflow
   - Clear indication of inputs/outputs
   - Data flow representation
   - Integration points

3. **Technical Details**
   - Memory requirements
   - CPU requirements
   - Storage needs
   - Network requirements

4. **Container Information**
   - Docker container versions
   - BioContainer specifications
   - Resource allocations
   - Storage requirements

### For Integration Points
1. **Data Formats**
   - File specifications
   - Format conversions
   - Validation steps

2. **Quality Control**
   - QC metrics
   - Validation steps
   - Error checking
   - Best practices

3. **Resource Management**
   - Storage requirements
   - Compute requirements
   - Memory management
   - Network needs

## Additional Considerations

### Performance Optimization
- Parallel processing strategies
- Resource allocation
- Storage optimization
- Network efficiency

### Error Handling
- Common failure points
- Recovery procedures
- Validation steps
- Quality checks

### Documentation Standards
- Consistent formatting
- Clear structure
- Version control
- Update procedures

### Best Practices
- Tool selection criteria
- Resource allocation
- Quality control
- Data management

## Desired Output Format

### For Each Document
1. **Format**
   - Markdown for documentation
   - YAML for CWL
   - Mermaid for diagrams
   - Tables for tool listings

2. **Structure**
   - Clear headers
   - Logical organization
   - Consistent formatting
   - Appropriate depth

3. **Content Requirements**
   - Technical accuracy
   - Completeness
   - Clarity
   - Practicality

4. **Special Requirements**
   - Container specifications
   - Resource requirements
   - Integration points
   - Error handling

## Note for Implementation
Please ensure:
- Complete CWL implementations
- Detailed resource specifications
- Clear documentation
- Practical considerations
- Best practices included
- Error handling
- Quality control measures
- Integration guidance

Focus on creating documentation that is:
- Comprehensive
- Practical
- Maintainable
- Clear
- Accurate
- Usable

## Expected Deliverables
1. Overview document
2. Five workflow documents
3. Tool documentation
4. Integration guide
5. Best practices document

For each document, include:
- Technical specifications
- Resource requirements
- Container information
- Implementation details
