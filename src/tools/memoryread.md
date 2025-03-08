### MemoryReadTool and MemoryWriteTool: State Persistence

These tools provide a simple but effective file-based memory system, allowing Claude to store and retrieve information across conversations.

#### Implementation

- MemoryReadTool reads from a dedicated memory directory
- MemoryWriteTool writes content to specified files within the memory directory
- Both tools validate paths to prevent directory traversal
- MemoryWriteTool creates directories recursively as needed

#### Storage Mechanism

- Files are stored in MEMORY_DIR (~/.koding/memory by default)
- Reads and writes go directly to disk (no in-memory caching)
- Directory structure is maintained within the memory directory

The memory tools provide a persistent storage layer that enables Claude to maintain state across sessions, acting as a simple database for storing notes, settings, or other persistent information.

