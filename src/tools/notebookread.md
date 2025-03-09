# NotebookReadTool (ReadNotebook): Jupyter Notebook Inspection

NotebookReadTool specializes in reading Jupyter notebook (.ipynb) files and extracting their contents with outputs, enabling Claude to analyze data science workflows in their native format.

## Complete Prompt

```typescript
export const DESCRIPTION =
  'Extract and read source code from all code cells in a Jupyter notebook.'
export const PROMPT = `Reads a Jupyter notebook (.ipynb file) and returns all of the cells with their outputs. Jupyter notebooks are interactive documents that combine code, text, and visualizations, commonly used for data analysis and scientific computing. The notebook_path parameter must be an absolute path, not a relative path.`
```

> **Tool Prompt: ReadNotebook**
>
> Reads a Jupyter notebook (.ipynb file) and returns all of the cells with their outputs. Jupyter notebooks are interactive documents that combine code, text, and visualizations, commonly used for data analysis and scientific computing. The notebook_path parameter must be an absolute path, not a relative path.

## Implementation Details

NotebookReadTool takes a single parameter and handles notebook parsing with specialized formatting:

```typescript
const inputSchema = z.strictObject({
  notebook_path: z
    .string()
    .describe(
      'The absolute path to the Jupyter notebook file to read (must be absolute, not relative)',
    ),
})
```

The core implementation parses notebook JSON and processes each cell:

```typescript
async *call({ notebook_path }) {
  const fullPath = isAbsolute(notebook_path)
    ? notebook_path
    : resolve(getCwd(), notebook_path)

  const content = readFileSync(fullPath, 'utf-8')
  const notebook = JSON.parse(content) as NotebookContent
  const language = notebook.metadata.language_info?.name ?? 'python'
  const cells = notebook.cells.map((cell, index) =>
    processCell(cell, index, language),
  )

  yield {
    type: 'result',
    resultForAssistant: renderResultForAssistant(cells),
    data: cells,
  }
}
```

Individual cells and their outputs are processed with specialized functions:

```typescript
function processCell(
  cell: NotebookCell,
  index: number,
  language: string,
): NotebookCellSource {
  const cellData: NotebookCellSource = {
    cell: index,
    cellType: cell.cell_type,
    source: Array.isArray(cell.source) ? cell.source.join('') : cell.source,
    language,
    execution_count: cell.execution_count,
  }

  if (cell.outputs?.length) {
    cellData.outputs = cell.outputs.map(processOutput)
  }

  return cellData
}

function processOutput(output: NotebookCellOutput) {
  switch (output.output_type) {
    case 'stream':
      return {
        output_type: output.output_type,
        text: processOutputText(output.text),
      }
    case 'execute_result':
    case 'display_data':
      return {
        output_type: output.output_type,
        text: processOutputText(output.data?.['text/plain']),
        image: output.data && extractImage(output.data),
      }
    case 'error':
      return {
        output_type: output.output_type,
        text: processOutputText(
          `${output.ename}: ${output.evalue}\n${output.traceback.join('\n')}`,
        ),
      }
  }
}
```

## Key Components

NotebookReadTool has several critical features:

1. **Complete Notebook Parsing**
   - Parses the notebook's JSON structure
   - Processes both code and markdown cells
   - Handles cell ordering and indexing

2. **Cell Content Extraction**
   - Combines multi-line source content
   - Preserves cell execution counts
   - Maintains language information
   - Detects cell types (code vs. markdown)

3. **Output Type Processing**
   - Handles stream outputs (stdout/stderr)
   - Processes execution results
   - Extracts display data
   - Formats error information with tracebacks

4. **Image Handling**
   - Extracts base64-encoded PNG and JPEG images
   - Preserves media type information
   - Formats images for Claude's display capabilities

## Architecture

The NotebookReadTool follows a sequential processing flow:

```
NotebookReadTool
  ↓
Validation → Checks file exists and has .ipynb extension
  ↓
Notebook Loading → Reads and parses JSON structure
  ↓
Cell Processing → Maps each cell through processCell()
  ↓
Output Processing → Handles different output types
  ↓
Result Formatting → Structures content for Claude
```

The architecture prioritizes:
- **Complete Data Capture**: Extracts all notebook components
- **Output Type Support**: Handles the variety of Jupyter outputs
- **Structured Presentation**: Formats cells with clear tags
- **Visual Content**: Preserves images and visualization outputs

## Permission Handling

NotebookReadTool integrates with the permission system:

```typescript
needsPermissions({ notebook_path }) {
  return !hasReadPermission(notebook_path)
}
```

This requires explicit read permission for notebook files, following the same permission model as other file reading tools.

## Usage Examples

Common usage patterns:

1. **Reading a data analysis notebook**
   ```
   ReadNotebook(notebook_path: "/path/to/analysis.ipynb")
   ```

2. **Examining notebook with visualizations**
   ```
   ReadNotebook(notebook_path: "/path/to/visualization.ipynb")
   ```

NotebookReadTool enables Claude to understand and analyze Jupyter notebooks, which are commonly used for:
- Data analysis workflows
- Machine learning model development
- Scientific research and experimentation
- Educational content with executable code

The tool's ability to extract both code and outputs makes it valuable for understanding complete computational narratives, not just the code itself.

