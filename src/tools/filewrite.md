### FileWriteTool (Replace): Complete File Creation and Updates

FileWriteTool (exposed as "Replace" in the interface) enables writing or overwriting entire files on the filesystem.

#### Implementation

- Validates parameters for file_path and content
- Handles different file encodings (utf8, utf16le, ascii)
- Preserves line endings (CRLF/LF) for consistency
- Creates parent directories automatically if they don't exist

#### Security and Permissions

- Requires explicit write permission for target directory
- Tracks file read timestamps to prevent race conditions
- Shows diffs when updating existing files
- Validates all paths to prevent directory traversal
- Preserves consistent encoding and line endings

FileWriteTool complements FileEditTool by handling complete file creation or replacement rather than targeted edits, making it suitable for creating new files or completely replacing existing ones.

