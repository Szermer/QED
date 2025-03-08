### NotebookEditTool: Jupyter Notebook Modification

NotebookEditTool provides the ability to modify Jupyter notebooks by editing specific cells.

#### Implementation

- Supports three edit modes:
  - `replace`: Update existing cell content (default)
  - `insert`: Add a new cell at specified index
  - `delete`: Remove a cell at specified index
- Preserves notebook metadata and structure
- Clears execution counts on modified cells

#### Parameters

- `notebook_path`: Path to notebook file
- `cell_number`: 0-based index of cell to edit
- `new_source`: New content for the cell
- `cell_type`: 'code' or 'markdown' (optional for replace, required for insert)
- `edit_mode`: Operation to perform (replace/insert/delete)

NotebookEditTool complements NotebookReadTool by providing write capabilities for notebooks, enabling Claude to not just analyze but also modify data science workflows.

