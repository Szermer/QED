### GlobTool: File Pattern Matching

GlobTool is a fast file-finding tool that searches for files matching glob patterns like "**/\*.js" or "src/**/\*.ts".

#### Implementation

- Uses Node's glob library wrapped in a performance-optimized utility function
- Results are sorted by modification time (most recent first)
- Limited to 100 results to prevent overwhelming the UI
- Marked as read-only, enabling parallel execution

#### Parameters and Return Format

- **Input**:
  - `pattern`: Required glob pattern string (e.g., "\*_/_.js")
  - `path`: Optional directory to search in (defaults to CWD)
- **Output**:
  - JSON object with matching filenames, duration, count, and truncation flag
  - For Claude, results are formatted as a simple list of files

#### Integration Points

GlobTool connects to the file system via Node's glob library while respecting the permission system by checking if it has read permission on the target directory. Its read-only status makes it eligible for parallel execution, making it highly efficient for codebases of any size.

