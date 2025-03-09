# FileEditTool: Precision File Modifications

FileEditTool performs targeted edits to files with strict validation to prevent unintended modifications. It requires unique matches within files to ensure changes are precise and intentional.

## Complete Prompt

```typescript
// Tool Prompt: FileEditTool
export const PROMPT = `This is a tool for editing files. For moving or renaming files, you should generally use the Bash tool with the 'mv' command instead. For larger edits, use the Write tool to overwrite files. For Jupyter notebooks (.ipynb files), use the NotebookEditCell instead.

Before using this tool:

1. Use the View tool to understand the file's contents and context

2. Verify the directory path is correct (only applicable when creating new files):
   - Use the LS tool to verify the parent directory exists and is the correct location

To make a file edit, provide the following:
1. file_path: The absolute path to the file to modify (must be absolute, not relative)
2. old_string: The text to replace (must be unique within the file, and must match the file contents exactly, including all whitespace and indentation)
3. new_string: The edited text to replace the old_string

The tool will replace ONE occurrence of old_string with new_string in the specified file.

CRITICAL REQUIREMENTS FOR USING THIS TOOL:

1. UNIQUENESS: The old_string MUST uniquely identify the specific instance you want to change. This means:
   - Include AT LEAST 3-5 lines of context BEFORE the change point
   - Include AT LEAST 3-5 lines of context AFTER the change point
   - Include all whitespace, indentation, and surrounding code exactly as it appears in the file

2. SINGLE INSTANCE: This tool can only change ONE instance at a time. If you need to change multiple instances:
   - Make separate calls to this tool for each instance
   - Each call must uniquely identify its specific instance using extensive context

3. VERIFICATION: Before using this tool:
   - Check how many instances of the target text exist in the file
   - If multiple instances exist, gather enough context to uniquely identify each one
   - Plan separate tool calls for each instance

WARNING: If you do not follow these requirements:
   - The tool will fail if old_string matches multiple locations
   - The tool will fail if old_string doesn't match exactly (including whitespace)
   - You may change the wrong instance if you don't include enough context

When making edits:
   - Ensure the edit results in idiomatic, correct code
   - Do not leave the code in a broken state
   - Always use absolute file paths (starting with /)

If you want to create a new file, use:
   - A new file path, including dir name if needed
   - An empty old_string
   - The new file's contents as new_string

Remember: when making multiple file edits in a row to the same file, you should prefer to send all edits in a single message with multiple calls to this tool, rather than multiple messages with a single call each.`
```

> This is a tool for editing files. For moving or renaming files, you should generally use the Bash tool with the 'mv' command instead. For larger edits, use the Write tool to overwrite files. For Jupyter notebooks (.ipynb files), use the NotebookEditCell instead.
>
> Before using this tool:
>
> 1. Use the View tool to understand the file's contents and context
>
> 2. Verify the directory path is correct (only applicable when creating new files):
>    - Use the LS tool to verify the parent directory exists and is the correct location
>
> To make a file edit, provide the following:
> 1. file_path: The absolute path to the file to modify (must be absolute, not relative)
> 2. old_string: The text to replace (must be unique within the file, and must match the file contents exactly, including all whitespace and indentation)
> 3. new_string: The edited text to replace the old_string
>
> The tool will replace ONE occurrence of old_string with new_string in the specified file.
>
> CRITICAL REQUIREMENTS FOR USING THIS TOOL:
>
> 1. UNIQUENESS: The old_string MUST uniquely identify the specific instance you want to change. This means:
>    - Include AT LEAST 3-5 lines of context BEFORE the change point
>    - Include AT LEAST 3-5 lines of context AFTER the change point
>    - Include all whitespace, indentation, and surrounding code exactly as it appears in the file
>
> 2. SINGLE INSTANCE: This tool can only change ONE instance at a time. If you need to change multiple instances:
>    - Make separate calls to this tool for each instance
>    - Each call must uniquely identify its specific instance using extensive context
>
> 3. VERIFICATION: Before using this tool:
>    - Check how many instances of the target text exist in the file
>    - If multiple instances exist, gather enough context to uniquely identify each one
>    - Plan separate tool calls for each instance
>
> WARNING: If you do not follow these requirements:
>    - The tool will fail if old_string matches multiple locations
>    - The tool will fail if old_string doesn't match exactly (including whitespace)
>    - You may change the wrong instance if you don't include enough context
>
> When making edits:
>    - Ensure the edit results in idiomatic, correct code
>    - Do not leave the code in a broken state
>    - Always use absolute file paths (starting with /)
>
> If you want to create a new file, use:
>    - A new file path, including dir name if needed
>    - An empty old_string
>    - The new file's contents as new_string
>
> Remember: when making multiple file edits in a row to the same file, you should prefer to send all edits in a single message with multiple calls to this tool, rather than multiple messages with a single call each.

## Key Components

The FileEditTool is structured around several critical components:

1. **Operation Modes**
   - **Update Mode**: Replace specific text while preserving the rest of the file
   - **Create Mode**: Generate a new file with empty `old_string`
   - **Delete Mode**: Remove text by providing empty `new_string`

2. **Diff Generation System**
   - Visual representation of changes for user feedback
   - Highlights additions and deletions
   - Line number tracking for context

3. **Validation Pipeline**
   - Parameter validation (file_path, old_string, new_string)
   - File existence checking
   - Uniqueness verification for old_string
   - Timestamp validation to prevent race conditions

4. **File Handling System**
   - Encoding detection and preservation
   - Line ending preservation (CRLF/LF)
   - Backup creation before modifications
   - Parent directory creation for new files

5. **Error Handling Framework**
   - Descriptive error messages with remediation suggestions
   - Custom error types for different validation failures
   - Context-aware error reporting

## Architecture

FileEditTool's architecture follows a validation-first approach:

```
+-----------------------+
| Parameter Validation  |
+-----------------------+
           ↓
+-----------------------+
| File Access Validation|
+-----------------------+
           ↓
+-----------------------+
| Uniqueness Validation |
+-----------------------+
           ↓
+-----------------------+
| Edit Application      |
+-----------------------+
           ↓
+-----------------------+
| Result Formatting     |
+-----------------------+
```

The implementation follows these execution steps:

1. **Parameter Preparation**
   - Validate all parameters are provided
   - Check that file_path is absolute
   - Normalize paths for consistent handling

2. **File Validation**
   - Check if target file exists
   - For new files, verify parent directory exists
   - For Jupyter notebooks, redirect to appropriate tool

3. **Content Analysis**
   - Read file with encoding detection
   - Count occurrences of old_string
   - Verify uniqueness to prevent unintended modifications

4. **Edit Application**
   - Apply the replacement once
   - Create parent directories if needed (for new files)
   - Preserve file encoding and line endings

5. **Result Reporting**
   - Generate a diff of the changes
   - Return snippet of edited file with line numbers
   - Report status and changes made

## Permission Handling

FileEditTool uses the standard file permission system with special handling for directory creation:

```typescript
needsPermission(params: Params): boolean {
  // Check if file exists
  const fileExists = existsSync(params.file_path);
  
  // Always require permission when modifying existing files
  if (fileExists) return true;
  
  // For new files, check if we have write permission for the parent directory
  const parentDir = dirname(params.file_path);
  return !hasDirectoryWritePermission(parentDir);
}
```

Key permission aspects:

1. **Explicit Permission Requirements**
   - Always requires permission for existing files
   - For new files, checks parent directory permissions
   - Uses per-directory permission tracking

2. **Permission UI**
   - Shows file path and change preview
   - Displays diff visualization of proposed changes
   - Provides context for the permission request

3. **Permission Caching**
   - Caches directory write permissions
   - Avoids repeated permission prompts for the same directory
   - Maintains security while improving user experience

## Implementation Details

Looking at the implementation, FileEditTool consists of several key components:

1. **The FileEditTool React component** (`FileEditTool.tsx`)
   - TypeScript interface with strict parameter validation
   - Schema validation to ensure required fields
   - Permission checking for file access
   - Result formatting for Claude

2. **The edit utility functions** (`file.ts`)
   - Core file manipulation with encoding preservation
   - String replacement with uniqueness validation
   - Error handling for various failure cases
   - Diff generation for visual feedback

Here's a look at the core implementation:

```typescript
// Simplified version of the core edit function
async function edit(params: Params): Promise<Result> {
  const { file_path, old_string, new_string } = params;
  
  // Validation
  if (!existsSync(file_path) && old_string !== "") {
    throw new Error(`File ${file_path} doesn't exist`);
  }
  
  // Read file content
  let content = "";
  if (existsSync(file_path)) {
    content = await readFile(file_path, "utf8");
  }
  
  // Check uniqueness
  const matches = content.split(old_string).length - 1;
  if (matches > 1) {
    throw new Error(`Found multiple (${matches}) matches of the provided text in ${file_path}`);
  }
  if (matches === 0 && old_string !== "") {
    throw new Error(`Could not find the provided text in ${file_path}`);
  }
  
  // Make the replacement
  const newContent = old_string === "" 
    ? new_string 
    : content.replace(old_string, new_string);
  
  // Create parent directories if needed
  const dir = dirname(file_path);
  if (!existsSync(dir)) {
    await mkdir(dir, { recursive: true });
  }
  
  // Write the new content
  await writeFile(file_path, newContent, "utf8");
  
  // Generate diff for reporting
  const diff = createPatch(file_path, content, newContent);
  
  return {
    success: true,
    diff,
    file_path
  };
}
```

## Usage Examples

The FileEditTool supports several common usage patterns:

1. **Targeted Code Modification**
```typescript
Edit({
  file_path: "/path/to/file.js",
  old_string: `function sum(a, b) {
  // Old implementation
  return a + b;
}`,
  new_string: `function sum(a, b) {
  // New implementation with validation
  if (typeof a !== 'number' || typeof b !== 'number') {
    throw new Error('Arguments must be numbers');
  }
  return a + b;
}`
})
```

2. **New File Creation**
```typescript
Edit({
  file_path: "/path/to/new/file.js",
  old_string: "",
  new_string: "console.log('Hello world!');"
})
```

3. **Content Removal**
```typescript
Edit({
  file_path: "/path/to/file.js",
  old_string: `  // Deprecated function
  function oldMethod() {
    console.log('This should be removed');
  }`,
  new_string: ""
})
```

4. **Multiple Sequential Edits**
```typescript
Edit({file_path: "/path/to/file.js", old_string: "const version = '1.0.0';", new_string: "const version = '1.0.1';"})
Edit({file_path: "/path/to/file.js", old_string: "const updated = false;", new_string: "const updated = true;"})
```

FileEditTool's design focus on safety through uniqueness requirements ensures precise modifications while preventing unintended changes, making it one of the most frequently used yet carefully designed tools in the system.

