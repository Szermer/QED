# Edit: Precise File Modifications

Edit performs targeted changes to files with strict validation to prevent unintended modifications. It requires unique text matches to ensure changes are precise and intentional.

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

The Edit tool supports three main operations:

1. **Operation Types**
   - **Update**: Replace specific text in an existing file
   - **Create**: Generate a new file by using empty `old_string`
   - **Delete**: Remove text by using empty `new_string`

2. **Diff Generation**
   - Shows visual representation of changes
   - Highlights additions and deletions
   - Includes line numbers for context

3. **Validation Process**
   - Checks parameters (file_path, old_string, new_string)
   - Verifies file existence
   - Confirms uniqueness of old_string
   - Validates timestamps to prevent race conditions

4. **File Handling**
   - Detects and preserves file encoding
   - Maintains line endings (CRLF/LF)
   - Creates backups before modifications
   - Creates parent directories for new files

5. **Error Handling**
   - Provides specific error messages with suggestions
   - Uses custom error types for different validation issues
   - Includes context in error reports

## Workflow

Edit follows a validation-first approach:

```
Parameter Validation
        ↓
File Access Validation
        ↓
Uniqueness Validation
        ↓
Edit Application
        ↓
Result Formatting
```

The process follows these steps:

1. **Parameter Check**
   - Validates all required parameters
   - Ensures file_path is absolute
   - Normalizes paths for consistency

2. **File Validation**
   - Checks if target file exists
   - For new files, verifies parent directory
   - Redirects Jupyter notebooks to appropriate tool

3. **Content Analysis**
   - Reads file with encoding detection
   - Counts occurrences of old_string
   - Verifies uniqueness to prevent unintended edits

4. **Edit Application**
   - Applies the replacement once
   - Creates parent directories as needed
   - Preserves file encoding and line endings

5. **Result Generation**
   - Creates visual diff of changes
   - Returns edited file snippet with line numbers
   - Reports status and changes made

## Permissions

Edit uses the standard file permission system with special handling for directory creation:

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

Key permission features:

1. **Permission Requirements**
   - Always requires permission for existing files
   - For new files, checks parent directory permissions
   - Uses per-directory permission tracking

2. **Permission Interface**
   - Displays file path and change preview
   - Shows diff visualization of proposed changes
   - Provides context for permission requests

3. **Permission Optimization**
   - Caches directory write permissions
   - Reduces permission prompts for the same directory
   - Balances security with user experience

## Implementation

The core implementation consists of these components:

1. **FileEditTool React component**
   - TypeScript interface with parameter validation
   - Schema validation for required fields
   - Permission checking for file access
   - Result formatting for display

2. **Edit utility functions**
   - Core file manipulation with encoding preservation
   - String replacement with uniqueness checks
   - Error handling for various cases
   - Diff generation for visual feedback

Core implementation:

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

