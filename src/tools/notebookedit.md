# NotebookEditTool (NotebookEditCell): Jupyter Notebook Modification

NotebookEditTool enables precise modification of Jupyter notebooks by editing, inserting, or deleting individual cells while preserving the notebook's structure and metadata.

## Complete Prompt

```typescript
export const DESCRIPTION =
  'Replace the contents of a specific cell in a Jupyter notebook.'
export const PROMPT = `Completely replaces the contents of a specific cell in a Jupyter notebook (.ipynb file) with new source. Jupyter notebooks are interactive documents that combine code, text, and visualizations, commonly used for data analysis and scientific computing. The notebook_path parameter must be an absolute path, not a relative path. The cell_number is 0-indexed. Use edit_mode=insert to add a new cell at the index specified by cell_number. Use edit_mode=delete to delete the cell at the index specified by cell_number.`
```

> **Tool Prompt: NotebookEditCell**
>
> Completely replaces the contents of a specific cell in a Jupyter notebook (.ipynb file) with new source. Jupyter notebooks are interactive documents that combine code, text, and visualizations, commonly used for data analysis and scientific computing. The notebook_path parameter must be an absolute path, not a relative path. The cell_number is 0-indexed. Use edit_mode=insert to add a new cell at the index specified by cell_number. Use edit_mode=delete to delete the cell at the index specified by cell_number.

## Implementation Details

NotebookEditTool validates inputs and handles notebook modifications with careful preservation of structure:

```typescript
const inputSchema = z.strictObject({
  notebook_path: z
    .string()
    .describe(
      'The absolute path to the Jupyter notebook file to edit (must be absolute, not relative)',
    ),
  cell_number: z.number().describe('The index of the cell to edit (0-based)'),
  new_source: z.string().describe('The new source for the cell'),
  cell_type: z
    .enum(['code', 'markdown'])
    .optional()
    .describe(
      'The type of the cell (code or markdown). If not specified, it defaults to the current cell type. If using edit_mode=insert, this is required.',
    ),
  edit_mode: z
    .string()
    .optional()
    .describe(
      'The type of edit to make (replace, insert, delete). Defaults to replace.',
    ),
})
```

The core implementation handles the three editing modes and manages notebook structure:

```typescript
async *call({
  notebook_path,
  cell_number,
  new_source,
  cell_type,
  edit_mode,
}) {
  const fullPath = isAbsolute(notebook_path)
    ? notebook_path
    : resolve(getCwd(), notebook_path)

  try {
    const enc = detectFileEncoding(fullPath)
    const content = readFileSync(fullPath, enc)
    const notebook = JSON.parse(content) as NotebookContent
    const language = notebook.metadata.language_info?.name ?? 'python'

    if (edit_mode === 'delete') {
      // Delete the specified cell
      notebook.cells.splice(cell_number, 1)
    } else if (edit_mode === 'insert') {
      // Insert the new cell
      const new_cell = {
        cell_type: cell_type!, // validateInput ensures cell_type is not undefined
        source: new_source,
        metadata: {},
      }
      notebook.cells.splice(
        cell_number,
        0,
        cell_type == 'markdown' ? new_cell : { ...new_cell, outputs: [] },
      )
    } else {
      // Replace the specified cell's content
      const targetCell = notebook.cells[cell_number]! // validateInput ensures cell_number is in bounds
      targetCell.source = new_source
      // Reset execution count and clear outputs since cell was modified
      targetCell.execution_count = undefined
      targetCell.outputs = []
      if (cell_type && cell_type !== targetCell.cell_type) {
        targetCell.cell_type = cell_type
      }
    }
    
    // Write back to file
    const endings = detectLineEndings(fullPath)
    writeTextContent(
      fullPath,
      JSON.stringify(notebook, null, 1),
      enc,
      endings!,
    )
    
    // Return success result
    yield {
      type: 'result',
      data: { /* result data */ },
      resultForAssistant: this.renderResultForAssistant(data),
    }
  } catch (error) {
    // Handle and report errors
    // ...
  }
}
```

## Key Components

NotebookEditTool has several important features:

1. **Multiple Editing Modes**
   - `replace`: Updates existing cell content (default mode)
   - `insert`: Adds a new cell at a specified index
   - `delete`: Removes a cell at a specified index

2. **Comprehensive Validation**
   - Verifies file exists and has .ipynb extension
   - Checks cell_number is within bounds for the operation
   - Ensures required parameters like cell_type are provided when needed
   - Validates edit_mode is one of the supported operations

3. **Notebook Structure Preservation**
   - Maintains notebook metadata and overall structure
   - Handles different cell types appropriately
   - Clears execution counts and outputs on modified cells
   - Preserves file encoding and line endings

4. **Robust Error Handling**
   - Handles JSON parsing errors
   - Reports specific error messages for validation failures
   - Provides user-friendly error reporting

## Architecture

The NotebookEditTool follows a structured workflow:

```
NotebookEditTool
  ↓
Input Validation → Checks for valid operations and boundaries
  ↓
Notebook Loading → Reads and parses notebook JSON
  ↓
Cell Modification → Applies changes based on edit_mode
  ↓
Structure Cleanup → Resets execution counts and outputs
  ↓
File Writing → Preserves encoding and formatting
```

The architecture prioritizes:
- **Data integrity**: Preserves notebook format and metadata
- **Consistency**: Cleans execution state for modified cells
- **Flexibility**: Supports multiple editing operations
- **Safety**: Validates operations before modifying files

## Permission Handling

NotebookEditTool integrates with the permission system:

```typescript
needsPermissions({ notebook_path }) {
  return !hasWritePermission(notebook_path)
}
```

This requires explicit user permission before modifying any notebook file, ensuring users maintain control over their data science workflows and preventing accidental modifications.

## Usage Examples

Common usage patterns:

1. **Replacing a code cell's content**
   ```
   NotebookEditCell(
     notebook_path: "/path/to/notebook.ipynb",
     cell_number: 2,
     new_source: "import pandas as pd\npd.read_csv('data.csv')"
   )
   ```

2. **Inserting a new markdown cell**
   ```
   NotebookEditCell(
     notebook_path: "/path/to/notebook.ipynb",
     cell_number: 0,
     new_source: "# Data Analysis\nThis notebook explores dataset trends.",
     cell_type: "markdown",
     edit_mode: "insert"
   )
   ```

3. **Deleting an unwanted cell**
   ```
   NotebookEditCell(
     notebook_path: "/path/to/notebook.ipynb",
     cell_number: 5,
     new_source: "",
     edit_mode: "delete"
   )
   ```

NotebookEditTool complements NotebookReadTool to provide a complete suite for working with Jupyter notebooks, enabling Claude to help users maintain and modify their data science workflows while respecting notebook structure and conventions.

