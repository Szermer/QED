### FileEditTool: Precision File Modifications

FileEditTool performs targeted edits to files with strict validation to prevent unintended modifications.

#### Implementation

- Single-instance replacement logic requiring unique match in file
- Change visualization through structured diff
- Preservation of file encoding and line endings
- Timestamp checking to prevent race conditions

#### Parameters

- `file_path`: Absolute path to the file
- `old_string`: Text to replace (must be unique in file)
- `new_string`: Replacement text

#### Safety and Validation

The tool implements multiple safety layers:

- Validates uniqueness of old_string within the file
- Confirms file hasn't been modified since last read
- Verifies write permissions for the file path
- Creates parent directories when needed (for new files)

FileEditTool's design emphasizes safety through uniqueness requirements—users must include sufficient context in `old_string` to ensure only one match is found, preventing accidental modifications.

