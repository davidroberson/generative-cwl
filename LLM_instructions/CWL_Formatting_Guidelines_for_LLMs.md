# CWL Formatting Guidelines for Language Models

## Essential Structure Requirements

### 1. Top-Level Workflow Requirements
Always include the following elements at the workflow level:

```yaml
cwlVersion: v1.2
class: Workflow
id: unique_workflow_id
label: "Human-readable workflow name"
doc: |
  Detailed description of the workflow's purpose and functionality.

requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

$namespaces:
  sbg: https://sevenbridges.com
```

### 2. Tool Requirements Structure
For each CommandLineTool, always format requirements as:

```yaml
requirements:
  DockerRequirement:
    dockerPull: "organization/tool:version"
```

NOT as:
```yaml
requirements:
  - class: DockerRequirement
    dockerPull: "organization/tool:version"
```

### 3. Input/Output Format
Always include labels and clear type definitions:

```yaml
inputs:
  input_file:
    type: File
    label: "Human-readable input description"
    secondaryFiles:  # if needed
      - .index
      - ^.dict

outputs:
  output_file:
    type: File
    label: "Human-readable output description"
    outputSource: step_name/output_name
```

## Common Mistakes to Avoid

1. Never format requirements as a list at the tool level:
   ```yaml
   # WRONG
   requirements:
     - DockerRequirement:
         dockerPull: "image:tag"
   
   # CORRECT
   requirements:
     DockerRequirement:
       dockerPull: "image:tag"
   ```

2. Never omit the workflow-level requirements section

3. Never omit the $namespaces section when using sbg tags

4. Never skip labels for inputs and outputs

## Best Practices

### 1. Documentation
Always include:
- Workflow description in doc field
- Labels for all components
- Clear input/output descriptions

### 2. Resource Management
Include resource requirements when needed:
```yaml
requirements:
  DockerRequirement:
    dockerPull: "image:tag"
  ResourceRequirement:
    ramMin: 4096
    coresMin: 1
```

### 3. File Handling
Always specify secondary files clearly:
```yaml
secondaryFiles:
  - .bai  # for BAM index
  - .tbi  # for tabix index
  - ^.dict  # for reference dictionary
```

### 4. Step Definitions
Format step definitions consistently:
```yaml
steps:
  step_name:
    run:
      cwlVersion: v1.2
      class: CommandLineTool
      id: tool_id
      label: "Tool description"
      requirements:
        DockerRequirement:
          dockerPull: "image:tag"
      baseCommand: [command]
      inputs:
        input_name:
          type: File
          inputBinding:
            prefix: --input
      outputs:
        output_name:
          type: File
          outputBinding:
            glob: "*.ext"
```

## Validation Checklist

Before completing a CWL workflow, verify:

1. Workflow Level:
   - [x] cwlVersion specified
   - [x] class defined
   - [x] unique id assigned
   - [x] requirements section included
   - [x] $namespaces section included
   - [x] doc field populated

2. Tool Level:
   - [x] Requirements formatted as object, not list
   - [x] Docker requirements included
   - [x] Resource requirements specified if needed
   - [x] Labels provided
   - [x] Input/output bindings properly formatted

3. File Handling:
   - [x] Secondary files specified where needed
   - [x] File types properly defined
   - [x] Output glob patterns specified

4. Documentation:
   - [x] All components labeled
   - [x] Input/output descriptions included
   - [x] Tool purposes documented

## Example Template

```yaml
cwlVersion: v1.2
class: Workflow
id: example_workflow
label: "Example Workflow"
doc: |
  Detailed workflow description.

requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: SubworkflowFeatureRequirement

$namespaces:
  sbg: https://sevenbridges.com

inputs:
  input_file:
    type: File
    label: "Input description"

steps:
  process_data:
    run:
      cwlVersion: v1.2
      class: CommandLineTool
      id: process_tool
      label: "Processing step"
      requirements:
        DockerRequirement:
          dockerPull: "image:tag"
      baseCommand: [command]
      inputs:
        input_name:
          type: File
          inputBinding:
            prefix: --input
      outputs:
        output_name:
          type: File
          outputBinding:
            glob: "*.ext"

outputs:
  final_output:
    type: File
    outputSource: process_data/output_name
```

Remember: Consistency in formatting is key to avoiding validation errors. Always use this guide as a reference when generating CWL workflows.
