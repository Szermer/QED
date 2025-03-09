# LSTool: Directory Listing

LSTool provides directory listing functionality, displaying files and directories in a tree structure at a specified path. It helps Claude understand the filesystem before performing operations.

## Complete Prompt

```typescript
// Tool Prompt: LS
export const DESCRIPTION = 'Lists files and directories in a given path. The path parameter must be an absolute path, not a relative path. You should generally prefer the Glob and Grep tools, if you know which directories to search.'
```

> **Tool Prompt: LS**
>
> Lists files and directories in a given path. The path parameter must be an absolute path, not a relative path. You should generally prefer the Glob and Grep tools, if you know which directories to search.

## Implementation Details

LSTool implements directory listing through a breadth-first traversal approach with several key features:

1. **The LSTool React component** (`lsTool.tsx`)
   - Simple interface with just one parameter (path)
   - Custom tree rendering for user and assistant
   - Safety checks and permission handling

2. **The directory traversal functions**
   - Breadth-first traversal to handle large directories efficiently
   - Tree structure creation for hierarchical display
   - Filtering of hidden files and system directories

Let's look at the core implementation:

```typescript
// Core BFS directory traversal function
function listDirectory(
  initialPath: string,
  cwd: string,
  abortSignal: AbortSignal,
): string[] {
  const results: string[] = []
  const queue = [initialPath]
  
  while (queue.length > 0) {
    // Stop if we hit limits or abort
    if (results.length > MAX_FILES || abortSignal.aborted) {
      return results
    }

    const path = queue.shift()!
    if (skip(path)) {  // Skip hidden files and specific directories
      continue
    }

    if (path !== initialPath) {
      results.push(relative(cwd, path) + sep)
    }

    // Read directory contents
    let children
    try {
      children = readdirSync(path, { withFileTypes: true })
    } catch (e) {
      // Handle permission errors and other exceptions
      logError(e)
      continue
    }

    // Process each child entry
    for (const child of children) {
      if (child.isDirectory()) {
        queue.push(join(path, child.name) + sep)
      } else {
        const fileName = join(path, child.name)
        if (skip(fileName)) {
          continue
        }
        results.push(relative(cwd, fileName))
        if (results.length > MAX_FILES) {
          return results
        }
      }
    }
  }

  return results
}
```

The file tree creation and rendering logic is particularly interesting:

```typescript
// Creates a hierarchical tree structure from flat paths
function createFileTree(sortedPaths: string[]): TreeNode[] {
  const root: TreeNode[] = []

  for (const path of sortedPaths) {
    const parts = path.split(sep)
    let currentLevel = root
    let currentPath = ''

    // Build tree nodes for each path component
    for (let i = 0; i < parts.length; i++) {
      const part = parts[i]!
      if (!part) continue // Skip empty parts (trailing slashes)
      
      currentPath = currentPath ? `${currentPath}${sep}${part}` : part
      const isLastPart = i === parts.length - 1

      // Find existing node or create new one
      const existingNode = currentLevel.find(node => node.name === part)
      if (existingNode) {
        currentLevel = existingNode.children || []
      } else {
        const newNode: TreeNode = {
          name: part,
          path: currentPath,
          type: isLastPart ? 'file' : 'directory',
        }

        if (!isLastPart) {
          newNode.children = []
        }

        currentLevel.push(newNode)
        currentLevel = newNode.children || []
      }
    }
  }

  return root
}
```

## Key Components

LSTool has several critical features:

1. **Directory traversal**
   - Breadth-first search algorithm for efficient listing
   - Automatic filtering of hidden files and system directories
   - Directory/file type detection with proper representation
   - Tree formatting for hierarchical display

2. **Safety and optimization**
   - 1000 file limit to prevent excessive output
   - Truncation notification for large directories
   - Error handling for access issues and edge cases
   - Special warning for potentially malicious files (only shown to Claude)

3. **UI considerations**
   - Compact output mode for user interface (4 lines max)
   - Verbose mode for fuller display when needed
   - Tree-like format for intuitive directory structure visualization

## Architecture

The LSTool architecture has these main components:

```
LSTool.tsx (React component)
  ↓
listDirectory() (Breadth-first traversal)
  ↓
createFileTree() (Hierarchical structure creation)
  ↓
printTree() (ASCII tree rendering)
```

There's an interesting comment in the code: "TODO: Kill this tool and use bash instead" - suggesting that in a future refactoring, this functionality might be replaced by a more generic approach using the BashTool.

## Permission Handling

LSTool uses the standard read permission model:

```typescript
needsPermissions({ path }) {
  return !hasReadPermission(path)
}
```

This ensures Claude has read access to the specified directory before listing its contents. The permission system prevents access to sensitive system directories.

## Usage Examples

Common usage patterns:

1. **Exploring project structure**
   ```
   LS(path: "/path/to/project")
   ```

2. **Checking available assets**
   ```
   LS(path: "/path/to/project/assets")
   ```

3. **Verifying directory existence before operations**
   ```
   LS(path: "/path/to/project/src") // Before creating files or running commands
   ```

LSTool is particularly useful for initial exploration of unfamiliar codebases and for verifying directory contents before performing operations. It's often one of the first tools Claude uses when working with a new project.

