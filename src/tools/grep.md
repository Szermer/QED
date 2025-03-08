### GrepTool: Content Searching

GrepTool provides high-performance content searching across files using regular expressions.

#### Implementation

- Leverages `ripgrep` (a Rust-based search tool) for exceptional performance
- Platform-specific optimizations handle Windows, macOS, and Linux differences
- Uses the `-li` flag with ripgrep for case-insensitive file listing
- Intelligently falls back to bundled ripgrep if not installed on system

#### Parameters and Return Format

- **Input**:
  - `pattern`: Required regex pattern to search for
  - `path`: Optional directory to search in
  - `include`: Optional file pattern filter (e.g., "\*.tsx")
- **Output**:
  - Object with matching filenames, execution time, and count
  - Results are sorted by modification time

#### Technical Distinctions

GrepTool's use of ripgrep makes it orders of magnitude faster than traditional grep implementations. The tool implements platform-specific optimizations, especially for macOS with code signing functionality to ensure ripgrep can run without security issues. It sets reasonable timeouts (10 seconds) and buffer sizes (1,000,000 bytes) for the ripgrep process.

