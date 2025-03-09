# Replace: Creating and Updating Files

Replace writes or overwrites entire files on the filesystem, handling complete file creation or replacement rather than targeted edits.

## Complete Prompt

```typescript
export const PROMPT = `Write a file to the local filesystem. Overwrites the existing file if there is one.

Before using this tool:

1. Use the ReadFile tool to understand the file's contents and context

2. Directory Verification (only applicable when creating new files):
   - Use the LS tool to verify the parent directory exists and is the correct location`

export const DESCRIPTION = 'Write a file to the local filesystem.'
```

> **Tool Prompt: Replace**
>
> Write a file to the local filesystem. Overwrites the existing file if there is one.
> 
> Before using this tool:
> 
> 1. Use the ReadFile tool to understand the file's contents and context
> 
> 2. Directory Verification (only applicable when creating new files):
>    - Use the LS tool to verify the parent directory exists and is the correct location

## How It Works

Replace takes two required parameters and handles file operations with contextual awareness:

```typescript
const inputSchema = z.strictObject({
  file_path: z
    .string()
    .describe(
      'The absolute path to the file to write (must be absolute, not relative)',
    ),
  content: z.string().describe('The content to write to the file'),
})
```

The implementation handles both creating new files and updating existing ones with appropriate safety checks:

```typescript
async *call({ file_path, content }, { readFileTimestamps }) {
  const fullFilePath = isAbsolute(file_path)
    ? file_path
    : resolve(getCwd(), file_path)
  const dir = dirname(fullFilePath)
  const oldFileExists = existsSync(fullFilePath)
  const enc = oldFileExists ? detectFileEncoding(fullFilePath) : 'utf-8'
  const oldContent = oldFileExists ? readFileSync(fullFilePath, enc) : null

  const endings = oldFileExists
    ? detectLineEndings(fullFilePath)
    : await detectRepoLineEndings(getCwd())

  mkdirSync(dir, { recursive: true })
  writeTextContent(fullFilePath, content, enc, endings!)

  // Update read timestamp, to invalidate stale writes
  readFileTimestamps[fullFilePath] = statSync(fullFilePath).mtimeMs

  if (oldContent) {
    const patch = getPatch({
      filePath: file_path,
      fileContents: oldContent,
      oldStr: oldContent,
      newStr: content,
    })

    // Return update result with diff information
    const data = {
      type: 'update' as const,
      filePath: file_path,
      content,
      structuredPatch: patch,
    }
    yield {
      type: 'result',
      data,
      resultForAssistant: this.renderResultForAssistant(data),
    }
    return
  }

  // Return create result
  const data = {
    type: 'create' as const,
    filePath: file_path,
    content,
    structuredPatch: [],
  }
  yield {
    type: 'result',
    data,
    resultForAssistant: this.renderResultForAssistant(data),
  }
}
```

## Key Features

Replace includes these important capabilities:

1. **Input Validation**
   - Validates file paths
   - Prevents timestamp conflicts
   - Creates directories for new files

2. **Content Management**
   - Detects encoding for existing files (UTF-8, UTF-16LE, ASCII)
   - Preserves line endings (CRLF/LF)
   - Maintains consistent formatting

3. **Change Visualization**
   - Shows diffs for file updates
   - Provides previews for new files
   - Truncates large files for display

4. **Conflict Prevention**
   - Tracks read timestamps
   - Detects external modifications
   - Prevents overwriting recently modified files

## Architecture

The Replace tool follows a structured flow:

```
FileWriteTool.tsx (React component)
  ↓
validateInput() → Checks if file can be safely written
  ↓
call() → Writes content with appropriate encoding and line endings
  ↓
renderToolResultMessage() → Shows changes to user
  ↓
renderResultForAssistant() → Returns formatted result for Claude
```

The tool handles two main operations with different display approaches:
- **Create**: Shows complete file content with syntax highlighting
- **Update**: Shows diff between old and new versions

## Permissions

Replace enforces a strict permission model:

```typescript
needsPermissions({ file_path }) {
  return !hasWritePermission(file_path)
}
```

This requires explicit user approval before writing to any location. The permission UI shows:
- Content preview for new files
- Structured diff for file updates
- The exact file path being modified

Additional validation safeguards include:

```typescript
async validateInput({ file_path }, { readFileTimestamps }) {
  // Allow creating new files without read check
  if (!existsSync(fullFilePath)) {
    return { result: true }
  }

  // Require existing files to be read first
  const readTimestamp = readFileTimestamps[fullFilePath]
  if (!readTimestamp) {
    return {
      result: false,
      message: 'File has not been read yet. Read it first before writing to it.',
    }
  }

  // Prevent race conditions with external changes
  const stats = statSync(fullFilePath)
  const lastWriteTime = stats.mtimeMs
  if (lastWriteTime > readTimestamp) {
    return {
      result: false,
      message: 'File has been modified since read... Read it again before attempting to write it.',
    }
  }

  return { result: true }
}
```

## Usage Examples

Common usage patterns:

1. **Creating a new file**
   ```
   Replace(file_path: "/path/to/new-file.txt", content: "New file content here")
   ```

2. **Overwriting an existing file**
   ```
   Replace(file_path: "/path/to/existing-file.js", content: "Updated content here")
   ```

FileWriteTool complements FileEditTool by handling complete file creation or replacement rather than targeted edits, making it the preferred choice when:
- Creating entirely new files
- Completely rewriting an existing file's contents
- Avoiding multiple sequential edits to the same file

