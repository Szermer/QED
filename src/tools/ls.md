### LSTool: Directory Listing

LSTool provides directory listing functionality, displaying files and directories at a specified path.

#### Implementation

- Uses Node.js readdirSync for directory traversal
- Implements breadth-first directory traversal with recursion
- Creates a hierarchical tree representation of file structure
- Filters hidden files and specified patterns like '**pycache**'

#### Parameters and Optimization

- Takes a single parameter: `path` (absolute directory path)
- Limits output to 1000 files to prevent excessive results
- Implements verbose mode for full path display
- Supports truncation for large directories with counts of additional items

LSTool provides a filesystem exploration capability, giving Claude a way to understand directory structures and locate files before performing operations on them.

