### FileReadTool (View): Content Examination

FileReadTool (named "View" in the interface) reads files from the filesystem with support for both text and images.

#### Implementation

- Automatic encoding detection (UTF-8, UTF-16LE, ASCII)
- LRU cache for file encoding information
- Pagination support via offset/limit parameters
- Special handling for different file types

#### File Type Handling

- **Text Files**:
  - Line-ending preservation (CRLF/LF)
  - Size limits (0.25MB)
  - Line/character truncation
- **Images**:
  - Automatic resizing to fit maximum dimensions (2000x2000px)
  - Compression for large images
  - Conversion to JPEG if size exceeds limits

FileReadTool efficiently balances functionality with performance, implementing caching and compression strategies to handle large files and images without overwhelming the system resources.

