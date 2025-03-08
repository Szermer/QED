### ctx_viz Command

The `ctx_viz` command provides a detailed visualization of token usage across different components of the Claude conversation context, helping users understand how their context window is being utilized.

#### Implementation

The command is implemented in `commands/ctx_viz.ts` as a type: 'local' command that generates a formatted table of token usage:

```typescript
import type { Command } from "../commands";
import type { Tool } from "../Tool";
import Table from "cli-table3";
import { getSystemPrompt } from "../constants/prompts";
import { getContext } from "../context";
import { zodToJsonSchema } from "zod-to-json-schema";
import { getMessagesGetter } from "../messages";

// Quick and dirty estimate of bytes per token for rough token counts
const BYTES_PER_TOKEN = 4;

interface Section {
  title: string;
  content: string;
}

interface ToolSummary {
  name: string;
  description: string;
}

function getContextSections(text: string): Section[] {
  const sections: Section[] = [];

  // Find first <context> tag
  const firstContextIndex = text.indexOf("<context");

  // Everything before first tag is Core Sysprompt
  if (firstContextIndex > 0) {
    const coreSysprompt = text.slice(0, firstContextIndex).trim();
    if (coreSysprompt) {
      sections.push({
        title: "Core Sysprompt",
        content: coreSysprompt,
      });
    }
  }

  let currentPos = firstContextIndex;
  let nonContextContent = "";

  const regex = /<context\s+name="([^"]*)">([\s\S]*?)<\/context>/g;
  let match: RegExpExecArray | null;

  while ((match = regex.exec(text)) !== null) {
    // Collect text between context tags
    if (match.index > currentPos) {
      nonContextContent += text.slice(currentPos, match.index);
    }

    const [, name = "Unnamed Section", content = ""] = match;
    sections.push({
      title: name === "codeStyle" ? "CodeStyle + KODING.md's" : name,
      content: content.trim(),
    });

    currentPos = match.index + match[0].length;
  }

  // Collect remaining text after last tag
  if (currentPos < text.length) {
    nonContextContent += text.slice(currentPos);
  }

  // Add non-contextualized content if present
  const trimmedNonContext = nonContextContent.trim();
  if (trimmedNonContext) {
    sections.push({
      title: "Non-contextualized Content",
      content: trimmedNonContext,
    });
  }

  return sections;
}

function formatTokenCount(bytes: number): string {
  const tokens = bytes / BYTES_PER_TOKEN;
  const k = tokens / 1000;
  return `${Math.round(k * 10) / 10}k`;
}

function formatByteCount(bytes: number): string {
  const kb = bytes / 1024;
  return `${Math.round(kb * 10) / 10}kb`;
}

function createSummaryTable(
  systemText: string,
  systemSections: Section[],
  tools: ToolSummary[],
  messages: unknown
): string {
  const table = new Table({
    head: ["Component", "Tokens", "Size", "% Used"],
    style: { head: ["bold"] },
    chars: {
      mid: "─",
      "left-mid": "├",
      "mid-mid": "┼",
      "right-mid": "┤",
    },
  });

  const messagesStr = JSON.stringify(messages);
  const toolsStr = JSON.stringify(tools);

  // Calculate total for percentages
  const total = systemText.length + toolsStr.length + messagesStr.length;
  const getPercentage = (n: number) => `${Math.round((n / total) * 100)}%`;

  // System prompt and its sections
  table.push([
    "System prompt",
    formatTokenCount(systemText.length),
    formatByteCount(systemText.length),
    getPercentage(systemText.length),
  ]);
  for (const section of systemSections) {
    table.push([
      `  ${section.title}`,
      formatTokenCount(section.content.length),
      formatByteCount(section.content.length),
      getPercentage(section.content.length),
    ]);
  }

  // Tools
  table.push([
    "Tool definitions",
    formatTokenCount(toolsStr.length),
    formatByteCount(toolsStr.length),
    getPercentage(toolsStr.length),
  ]);
  for (const tool of tools) {
    table.push([
      `  ${tool.name}`,
      formatTokenCount(tool.description.length),
      formatByteCount(tool.description.length),
      getPercentage(tool.description.length),
    ]);
  }

  // Messages and total
  table.push(
    [
      "Messages",
      formatTokenCount(messagesStr.length),
      formatByteCount(messagesStr.length),
      getPercentage(messagesStr.length),
    ],
    ["Total", formatTokenCount(total), formatByteCount(total), "100%"]
  );

  return table.toString();
}

const command: Command = {
  name: "ctx-viz",
  description:
    "[ANT-ONLY] Show token usage breakdown for the current conversation context",
  isEnabled: true,
  isHidden: false,
  type: "local",

  userFacingName() {
    return this.name;
  },

  async call(_args: string, cmdContext: { options: { tools: Tool[] } }) {
    // Get tools and system prompt with injected context
    const [systemPromptRaw, sysContext] = await Promise.all([
      getSystemPrompt(),
      getContext(),
    ]);

    const rawTools = cmdContext.options.tools;

    // Full system prompt with context sections injected
    let systemPrompt = systemPromptRaw.join("\n");
    for (const [name, content] of Object.entries(sysContext)) {
      systemPrompt += `\n<context name="${name}">${content}</context>`;
    }

    // Get full tool definitions including prompts and schemas
    const tools = rawTools.map((t) => {
      // Get full prompt and schema
      const fullPrompt = t.prompt({ dangerouslySkipPermissions: false });
      const schema = JSON.stringify(
        "inputJSONSchema" in t && t.inputJSONSchema
          ? t.inputJSONSchema
          : zodToJsonSchema(t.inputSchema)
      );

      return {
        name: t.name,
        description: `${fullPrompt}\n\nSchema:\n${schema}`,
      };
    });

    // Get current messages from REPL
    const messages = getMessagesGetter()();

    const sections = getContextSections(systemPrompt);
    return createSummaryTable(systemPrompt, sections, tools, messages);
  },
};

export default command;
```

#### Functionality

The `ctx_viz` command provides a detailed breakdown of token usage across different components of the conversation context:

1. **System Prompt Analysis**:

   - Parses the system prompt to identify its separate sections
   - Extracts `<context>` tags and their contents for individual analysis
   - Identifies core system prompt sections vs. injected context

2. **Token Usage Calculation**:

   - Estimates token usage based on a bytes-per-token approximation
   - Presents data in kilobytes and estimated token counts
   - Calculates percentage usage for each component of the context

3. **Tool Definitions Analysis**:

   - Extracts complete tool definitions including prompts and JSON schemas
   - Calculates token usage per tool
   - Shows the total footprint of tool definitions in the context

4. **Conversation Message Analysis**:

   - Includes the current message history in the analysis
   - Shows what portion of the context window is used by the conversation

5. **Structured Presentation**:
   - Outputs a formatted ASCII table with columns for component, tokens, size, and percentage
   - Uses hierarchical indentation to show the structure of the context
   - Includes totals for complete context usage

#### Technical Implementation Notes

The `ctx_viz` command demonstrates several sophisticated implementation patterns:

1. **Regex-Based Context Parsing**: Uses regular expressions to parse the context sections from the system prompt, handling nested tags and multi-line content.

2. **Parallel Resource Loading**: Uses `Promise.all` to concurrently fetch system prompt and context data for efficiency.

3. **Tool Schema Introspection**: Extracts JSON schemas from tool definitions using either explicit schemas or by converting Zod schemas to JSON Schema format.

4. **Token Approximation**: Implements a simple but effective token estimation approach based on byte length, which provides a reasonable approximation without requiring a tokenizer.

5. **Table Formatting**: Uses the `cli-table3` library to create a formatted ASCII table with custom styling, making the output readable in a terminal environment.

6. **Context Section Management**: Special-cases certain context sections like "codeStyle" with custom labeling for clarity.

#### User Experience Benefits

The `ctx_viz` command addresses several important needs for developers using Claude Code:

1. **Context Window Transparency**: Gives users insight into how their limited context window is being utilized.

2. **Optimization Opportunities**: Helps identify large components that might be consuming excessive context, enabling targeted optimization.

3. **Debugging Aid**: Provides a debugging tool for situations where context limitations are affecting Claude's performance.

4. **System Prompt Visibility**: Makes the usually hidden system prompt and context visible to users for better understanding of Claude's behavior.

The command is particularly valuable for advanced users and developers who need to understand and optimize their context usage to get the most out of Claude's capabilities within token limitations.

