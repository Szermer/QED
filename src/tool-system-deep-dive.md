## Tool System Deep Dive

**Note**: This section is undergoing deep review. While these notes provide a useful overview, they are not yet as detailed or polished as other sections. Please [file a GitHub issue](https://github.com/gerred/building-an-agentic-system/issues) if you notice any errors or have suggestions for additional content.

The power of Claude Code comes from its extensive tool system that allows Claude to interact with your local environment. This section analyzes each key tool in detail, exploring their implementation, integration points, and technical nuances.

Below you'll find detailed descriptions of each tool, with individual pages for each tool implementation:

- [Agent](tools/agent.md): Delegated task execution
- [Architect](tools/architect.md): Software architecture planning
- [Bash](tools/bash.md): Command-line execution
- [FileEdit](tools/fileedit.md): Precise file modifications
- [FileRead](tools/fileread.md): Content examination
- [FileWrite](tools/filewrite.md): File creation and updates
- [Glob](tools/glob.md): Pattern-based file matching
- [Grep](tools/grep.md): Content search across files
- [LS](tools/ls.md): Directory listing
- [MCP](tools/mcp.md): External tool integration
- [MemoryRead](tools/memoryread.md): State persistence reading
- [MemoryWrite](tools/memorywrite.md): State persistence writing
- [NotebookEdit](tools/notebookedit.md): Notebook modification
- [NotebookRead](tools/notebookread.md): Jupyter notebook inspection
- [StickerRequest](tools/stickerrequest.md): User engagement
- [Think](tools/think.md): Structured reasoning

### Creating Your Own Tools

Before diving into specific tools, here's how you'd build your own tool in TypeScript:

```typescript
import { z } from "zod";
import { Tool } from "./Tool";

// Define a custom search tool that finds text in files
export const SearchTool: Tool = {
  // Name must be unique and descriptive
  name: "Search",

  // Description tells Claude what this tool does
  description: "Searches files for specific text patterns",

  // Define expected parameters using Zod schema
  inputSchema: z.object({
    query: z.string().describe("The text pattern to search for"),
    path: z.string().optional().describe("Optional directory to search in"),
    fileTypes: z
      .array(z.string())
      .optional()
      .describe("File extensions to include"),
  }),

  // Is this a read-only operation?
  isReadOnly: () => true, // Enables parallel execution

  // Does this require user permission?
  needsPermissions: (input) => {
    // Only need permission for certain paths
    return input.path && !input.path.startsWith("/safe/path");
  },

  // The actual implementation as an async generator
  async *call(input, context) {
    const { query, path = process.cwd(), fileTypes } = input;

    // Check for abort signal (enables cancellation)
    if (context.signal?.aborted) {
      throw new Error("Operation canceled");
    }

    try {
      // Yield initial status
      yield { status: "Searching for files..." };

      // Implementation logic here...
      const results = await performSearch(query, path, fileTypes);

      // Yield results progressively as they come in
      for (const result of results) {
        yield {
          file: result.path,
          line: result.lineNumber,
          content: result.matchedText,
        };

        // Check for abort between results
        if (context.signal?.aborted) {
          throw new Error("Operation canceled");
        }
      }

      // Yield final summary
      yield {
        status: "complete",
        totalMatches: results.length,
        searchTime: performance.now() - startTime,
      };
    } catch (error) {
      // Handle and report errors properly
      yield { error: error.message };
    }
  },
};
```
