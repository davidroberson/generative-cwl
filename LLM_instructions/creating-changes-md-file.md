Please generate a changes.md file that documents the new and modified files in our repository. The file should follow this format:

Directory Structure Section:
Start with a section that shows the repository tree, listing only the new or modified files.
For each new file or directory, include a comment (e.g., # *New file* or # *Modified file*).
Example:
bash
Copy
## Directory structure (new/modified files only):
└── davidroberson-generative-cwl/
    ├── cwl-tool-library/
    │   └── m-regle-tools.cwl  # *New file: consolidated tool collection*
    └── gwas-m-regle/
        ├── M-REGLE-workflow-overview.md  # *Modified file: updated to reference the standalone workflow*
        └── packed_workflow.cwl           # *New file: standalone packed workflow file*
User Requested Changes Section:
Add a section titled User Requested Changes: that lists, in bullet form, the changes to be applied.
For example:
sql
Copy
=================================================
User Requested Changes:
=================================================
- Create new file: `cwl-tool-library/m-regle-tools.cwl` (consolidated tool collection with multiple CWL tool definitions).
- Create new file: `gwas-m-regle/packed_workflow.cwl` (standalone packed workflow referencing the consolidated tools using fragment identifiers).
- Modify file: `gwas-m-regle/M-REGLE-workflow-overview.md` to update references to the new standalone workflow.
File Sections:
For each new or modified file, include a section that starts with a clearly delimited header indicating the file path. For example:
markdown
Copy
=================================================
File: cwl-tool-library/m-regle-tools.cwl
=================================================
Immediately after the header, include a fenced code block containing the full content of the file. Use the appropriate language specifier (e.g., yaml for CWL files, markdown for Markdown files).
Content Requirements:
The cwl-tool-library/m-regle-tools.cwl file should contain the consolidated CWL tool definitions (multiple CWL documents separated by document markers as needed).
The gwas-m-regle/packed_workflow.cwl file should contain the complete packed workflow that references the tools from the consolidated file via fragment identifiers (e.g., #tool-1).
The gwas-m-regle/M-REGLE-workflow-overview.md file should provide an overview and reference the standalone workflow file.
Please output the complete changes.md file using the format above. Do not include any additional parser instructions or details beyond documenting the new or modified files and listing the user-requested changes.

