### NotebookReadTool: Jupyter Notebook Inspection

NotebookReadTool specializes in reading Jupyter notebook (.ipynb) files and extracting their contents with outputs.

#### Implementation

- Parses the notebook's JSON structure
- Processes both code and markdown cells
- Handles multiple output types (text, images, execution results, errors)
- Preserves cell execution counts and language information

#### Cell Content Processing

- Detects cell types (code vs. markdown)
- Processes specialized output types:
  - Stream outputs (stdout/stderr)
  - Execution results
  - Display data (including images)
  - Error information with tracebacks
- Extracts base64-encoded images from outputs

NotebookReadTool enables Claude to understand and analyze Jupyter notebooks, a common format for data science and research code.

