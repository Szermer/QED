# GlobTool: Find Files Fast

GlobTool finds files that match patterns. It works with any codebase size and sorts results by modification time so you see the most recently changed files first.

## Complete Prompt

```typescript
// Tool Prompt: GlobTool
export const DESCRIPTION = `- Fast file pattern matching tool that works with any codebase size
- Supports glob patterns like "**/*.js" or "src/**/*.ts"
- Returns matching file paths sorted by modification time
- Use this tool when you need to find files by name patterns
- When you are doing an open ended search that may require multiple rounds of globbing and grepping, use the Agent tool instead
`
```

> **Tool Prompt: GlobTool**
>
> - Fast file pattern matching tool that works with any codebase size
> - Supports glob patterns like "**/*.js" or "src/**/*.ts"
> - Returns matching file paths sorted by modification time
> - Use this tool when you need to find files by name patterns
> - When you are doing an open ended search that may require multiple rounds of globbing and grepping, use the Agent tool instead

## How It Works

GlobTool has two main parts:

1. **Front-end component** (`GlobTool.tsx`)
   - Handles the interface between Claude and the file system
   - Validates inputs and formats results
   - Manages permissions

2. **Glob function** (`file.ts`)
   - Does the actual file matching with Node's glob library
   - Sorts files by how recently they were changed
   - Limits results to avoid overwhelming Claude

Here's what the core function looks like:

```typescript
// From file.ts - the core file matching function
export async function glob(
  filePattern: string,
  cwd: string,
  { limit, offset }: { limit: number; offset: number },
  abortSignal: AbortSignal,
): Promise<{ files: string[]; truncated: boolean }> {
  // Uses Node's glob library
  const paths = await globLib([filePattern], {
    cwd,
    nocase: true,  // Case-insensitive matching
    nodir: true,   // Only return files, not directories
    signal: abortSignal,  // Support for cancellation
    stat: true,    // Get file stats for sorting
    withFileTypes: true,  // Return full file info objects
  })
  // Sort by modification time (newest last, reversed later)
  const sortedPaths = paths.sort((a, b) => (a.mtimeMs ?? 0) - (b.mtimeMs ?? 0))
  const truncated = sortedPaths.length > offset + limit
  return {
    files: sortedPaths
      .slice(offset, offset + limit)
      .map(path => path.fullpath()),
    truncated,  // Let Claude know if results were limited
  }
}
```

The results get formatted nicely for Claude:

```typescript
// Formats results in a clean, readable format
renderResultForAssistant(output) {
  let result = output.filenames.join('\n')
  if (output.filenames.length === 0) {
    result = 'No files found'
  }
  else if (output.truncated) {
    result +=
      '\n(Results are truncated. Consider using a more specific path or pattern.)'
  }
  return result
}
```

## What Makes It Special

GlobTool has some nice features:

1. **Speed and scale**
   - Works with codebases of any size
   - Shows newest files first
   - Stops at 100 results to keep things manageable
   - Can be canceled if it takes too long

2. **Pattern support**
   - Uses familiar glob patterns like `**/*.js`
   - Doesn't care about case by default
   - Only returns files (not directories)

3. **Safety**
   - Tells you when results get cut off
   - Suggests using Agent for complex searches
   - Checks permissions before accessing paths

## How It's Built

GlobTool is pretty straightforward:

```
GlobTool.tsx (Interface)
  ↓
glob() in file.ts (Main function)
  ↓
Node's glob library (Does the heavy lifting)
```

Since it's read-only, it:
- Can run at the same time as other tools
- Has simple permissions
- Can't accidentally modify files

## Permissions

GlobTool just needs to check if it can read the directory:

```typescript
needsPermissions({ path }) {
  return !hasReadPermission(path || getCwd())
}
```

The system also has these safety measures:

- Normalizes paths to prevent directory traversal
- Rejects paths with null bytes or other weird stuff
- Makes sure operations stay within allowed directories

## Examples

Here's how to use it:

1. **Find JavaScript files**
   ```
   GlobTool(pattern: "**/*.js")
   ```

2. **Look in a specific folder**
   ```
   GlobTool(pattern: "*.ts", path: "/path/to/src")
   ```

3. **Find config files**
   ```
   GlobTool(pattern: "**/config.{json,yaml,yml}")
   ```

GlobTool pairs well with GrepTool - first find the files, then search their contents.

