# LS: Directory Listing

LS displays files and directories in a tree structure at a specified path. It helps explore the filesystem structure before performing operations.

## Complete Prompt

```typescript
// Tool Prompt: LS
export const DESCRIPTION = 'Lists files and directories in a given path. The path parameter must be an absolute path, not a relative path. You should generally prefer the Glob and Grep tools, if you know which directories to search.'
```

> **Tool Prompt: LS**
>
> Lists files and directories in a given path. The path parameter must be an absolute path, not a relative path. You should generally prefer the Glob and Grep tools, if you know which directories to search.

## How It Works

LS implements directory listing through a breadth-first traversal approach:

1. **Core Components**
   - Simple interface with a single path parameter
   - Tree-style rendering for clear visualization
   - Safety checks and permission verification

2. **Directory Traversal**
   - Breadth-first search for efficient directory processing
   - Tree structure generation for hierarchical display
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

## Key Features

LS provides these important capabilities:

1. **Directory Analysis**
   - Breadth-first search for efficient traversal
   - Filtering of hidden files and system directories
   - Type detection for files and directories
   - Tree formatting for hierarchical visualization

2. **Safety Measures**
   - 1000 file limit to manage output size
   - Truncation indicators for large directories
   - Error handling for permission issues
   - Security warnings for suspicious files (internal only)

3. **Display Options**
   - Compact mode for terminal display
   - Verbose mode for detailed listing
   - Tree structure for intuitive navigation

## Architecture

The LS tool has these main components:

```
LSTool.tsx (React component)
  ↓
listDirectory() (Breadth-first traversal)
  ↓
createFileTree() (Hierarchical structure creation)
  ↓
printTree() (ASCII tree rendering)
```

There's an interesting comment in the code: "TODO: Kill this tool and use bash instead" - suggesting that in a future refactoring, this functionality might be replaced by the Bash tool.

## Permissions

LS uses the standard read permission model:

```typescript
needsPermissions({ path }) {
  return !hasReadPermission(path)
}
```

This verifies read access to the specified directory before listing its contents. The permission system prevents access to sensitive system directories.

## Usage Examples

Typical use cases:

1. **Exploring project structure**
   ```
   LS(path: "/path/to/project")
   ```

2. **Checking available assets**
   ```
   LS(path: "/path/to/project/assets")
   ```

3. **Verifying directory existence**
   ```
   LS(path: "/path/to/project/src") // Before creating files or running commands
   ```

LS is useful for initial exploration of unfamiliar codebases and for verifying directory contents before performing operations. It's often one of the first tools used when working with a new project.

