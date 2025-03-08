## Command System Deep Dive

**Note**: This section is undergoing deep review. While these notes provide a useful overview, they are not yet as detailed or polished as other sections. Please [file a GitHub issue](https://github.com/gerred/building-an-agentic-system/issues) if you notice any errors or have suggestions for additional content.

The Claude Code command system provides a suite of slash commands that users can invoke during interactive sessions. These commands allow users to perform various actions such as managing configuration, viewing help, clearing the screen, or resuming past conversations.

Commands are integrated into the CLI through the Commander.js library and follow a consistent structure for both CLI arguments and interactive slash commands. The command system allows Claude Code to extend beyond simple conversational capabilities into a fully-featured developer tool.

### Command Categories

Claude Code's commands can be broadly categorized into several functional groups:

#### Environment Management

- [approvedtools](commands/approvedtools.md): Manage tool permissions
- [commands](commands/commands.md): List available commands
- [config](commands/config.md): Configure Claude Code settings
- [init](commands/init.md): Create KODING.md for project setup
- [terminalsetup](commands/terminalsetup.md): Configure terminal keybindings
- [doctor](commands/doctor.md): Check installation health

#### Authentication

- [login](commands/login.md): Authenticate with Anthropic
- [logout](commands/logout.md): Sign out and remove credentials
- [model](commands/model.md): Configure AI model settings

#### Context Management

- [clear](commands/clear.md): Reset conversation and free context space
- [compact](commands/compact.md): Summarize and condense conversation
- [ctx-viz](commands/ctx-viz.md): Visualize token usage
- [resume](commands/resume.md): Continue previous conversations

#### User Experience

- [help](commands/help.md): View available commands and usage
- [onboarding](commands/onboarding.md): Guided first-run experience
- [listen](commands/listen.md): Enable speech recognition
- [bug](commands/bug.md): Submit feedback and bug reports
- [release-notes](commands/release-notes.md): View version changes

#### GitHub Integration

- [pr-comments](commands/pr-comments.md): View GitHub pull request comments
- [review](commands/review.md): Review GitHub pull requests

#### Analytics

- [cost](commands/cost.md): Track API usage and expenses

### Command Implementation Structure

Each command follows a consistent structure and typically falls into one of these implementation types:

1. **Local Commands** (`type: 'local'`): Perform direct actions without rendering a UI
2. **JSX Commands** (`type: 'local-jsx'`): Render interactive React components
3. **Prompt Commands** (`type: 'prompt'`): Formulate specific requests to Claude

Click on any command above to view its detailed implementation and functionality.

#### Implementation

The command is implemented in `commands/bug.tsx` and leverages React components to create an interactive feedback form:

```typescript
import { Command } from "../commands";
import { Bug } from "../components/Bug";
import * as React from "react";
import { PRODUCT_NAME } from "../constants/product";

const bug = {
  type: "local-jsx",
  name: "bug",
  description: `Submit feedback about ${PRODUCT_NAME}`,
  isEnabled: true,
  isHidden: false,
  async call(onDone) {
    return <Bug onDone={onDone} />;
  },
  userFacingName() {
    return "bug";
  },
} satisfies Command;

export default bug;
```

Unlike pure command-line commands, this command uses the `type: 'local-jsx'` designation, which allows it to render a React component as its output. This enables a rich, interactive interface for gathering bug reports.

#### UI Component

The core functionality is housed in the `Bug` component in `components/Bug.tsx`. Key aspects of this component include:

1. **Multi-Step Form**: The UI guides users through a multi-step process:

   - User input (description of the bug)
   - Consent for information collection
   - Submission
   - Completion

2. **Information Collection**: The component collects:

   - User-provided bug description
   - Environment information (platform, terminal, version)
   - Git repository metadata (disabled in the current implementation)
   - Model settings (without API keys)

3. **GitHub Integration**: After submission, users can create a GitHub issue with pre-filled information including:

   - Bug description
   - Environment info
   - Model settings

4. **Privacy Considerations**: The component has been carefully designed to avoid collecting sensitive information:
   - No API keys are included
   - Personal identifiers have been removed
   - Direct submission to Anthropic's feedback endpoint has been commented out

#### Technical Features

Several technical aspects of the implementation are worth noting:

1. **Stateful Form Management**: Uses React's `useState` to manage the form state through multiple steps.

2. **Terminal Adaptation**: Adapts to terminal size using the `useTerminalSize` hook to ensure a good experience regardless of window size.

3. **Keyboard Navigation**: Implements customized keyboard handling with `useInput` from Ink to enable intuitive navigation.

4. **Error Handling**: Includes robust error handling for submission failures.

5. **Title Generation**: Originally included a capability to generate a concise title for the bug report using Claude's Haiku endpoint (currently commented out).

6. **Browser Integration**: Uses the `openBrowser` utility to open the user's default web browser to the GitHub issues page with pre-filled information.

#### Design Considerations

The bug command exemplifies several design principles of Claude Code's command system:

1. **Rich Terminal UI**: Unlike traditional CLI tools that might just accept arguments, the command provides a fully interactive experience with visual feedback.

2. **Progressive Disclosure**: Information about what will be collected is clearly shown before submission.

3. **Simple Escape Paths**: Users can easily cancel at any point using Escape or Ctrl+C/D.

4. **Clear Status Indicators**: The UI clearly shows the current step and available actions at all times.

This command demonstrates how Claude Code effectively leverages React and Ink to create sophisticated terminal user interfaces for commands that require complex interaction.

### clear Command

The `clear` command provides a way to reset the current conversation, clear the message history, and free up context space.

#### Implementation

The command is implemented in `commands/clear.ts` as a type: 'local' command, which means it doesn't render a UI component but rather performs an operation directly:

```typescript
import { Command } from "../commands";
import { getMessagesSetter } from "../messages";
import { getContext } from "../context";
import { getCodeStyle } from "../utils/style";
import { clearTerminal } from "../utils/terminal";
import { getOriginalCwd, setCwd } from "../utils/state";
import { Message } from "../query";

export async function clearConversation(context: {
  setForkConvoWithMessagesOnTheNextRender: (
    forkConvoWithMessages: Message[]
  ) => void;
}) {
  await clearTerminal();
  getMessagesSetter()([]);
  context.setForkConvoWithMessagesOnTheNextRender([]);
  getContext.cache.clear?.();
  getCodeStyle.cache.clear?.();
  await setCwd(getOriginalCwd());
}

const clear = {
  type: "local",
  name: "clear",
  description: "Clear conversation history and free up context",
  isEnabled: true,
  isHidden: false,
  async call(_, context) {
    clearConversation(context);
    return "";
  },
  userFacingName() {
    return "clear";
  },
} satisfies Command;

export default clear;
```

#### Functionality

The `clear` command performs several key operations:

1. **Terminal Cleaning**: Uses `clearTerminal()` to visually reset the terminal display.

2. **Message History Reset**: Sets the message array to empty using `getMessagesSetter()([])`.

3. **Context Clearing**: Clears the cached context information using `getContext.cache.clear()`.

4. **Style Cache Reset**: Clears the cached code style information with `getCodeStyle.cache.clear()`.

5. **Working Directory Reset**: Resets the current working directory to the original one using `setCwd(getOriginalCwd())`.

6. **Conversation Forking Reset**: Clears any pending conversation forks via the context parameter.

#### Technical Implementation Notes

The `clear` command makes use of several architectural patterns in Claude Code:

1. **Getter/Setter Pattern**: Uses message setter functions obtained through `getMessagesSetter()` rather than directly manipulating a message store, allowing for changes to be reactive across the UI.

2. **Cache Invalidation**: Explicitly clears caches for context and code style information to ensure fresh data when the user continues.

3. **State Management**: Demonstrates how state (like current working directory) is reset when clearing a conversation.

4. **Context Parameter**: Receives a context object from the command system that allows it to interact with the component rendering the REPL.

5. **Separate Function**: The core functionality is extracted into a separate `clearConversation` function, which allows it to be used by other parts of the system if needed.

#### User Experience Considerations

From a UX perspective, the `clear` command provides several benefits:

1. **Context Space Management**: Allows users to free up context space when they hit limitations with model context windows.

2. **Fresh Start**: Provides a clean slate for starting a new conversation without entirely restarting the CLI.

3. **Visual Reset**: The terminal clearing provides immediate visual feedback that the conversation has been reset.

The `clear` command is simple but vital for long-running CLI sessions, where context management becomes crucial for effective use of the LLM.

### compact Command

The `compact` command offers a sophisticated solution to context management by summarizing the conversation history before clearing it, thereby retaining essential context while freeing up token space.

#### Implementation

The command is implemented in `commands/compact.ts` as a type: 'local' command:

```typescript
import { Command } from "../commands";
import { getContext } from "../context";
import { getMessagesGetter, getMessagesSetter } from "../messages";
import { API_ERROR_MESSAGE_PREFIX, querySonnet } from "../services/claude";
import {
  createUserMessage,
  normalizeMessagesForAPI,
} from "../utils/messages.js";
import { getCodeStyle } from "../utils/style";
import { clearTerminal } from "../utils/terminal";

const compact = {
  type: "local",
  name: "compact",
  description: "Clear conversation history but keep a summary in context",
  isEnabled: true,
  isHidden: false,
  async call(
    _,
    {
      options: { tools, slowAndCapableModel },
      abortController,
      setForkConvoWithMessagesOnTheNextRender,
    }
  ) {
    // Get existing messages before clearing
    const messages = getMessagesGetter()();

    // Add summary request as a new message
    const summaryRequest = createUserMessage(
      "Provide a detailed but concise summary of our conversation above. Focus on information that would be helpful for continuing the conversation, including what we did, what we're doing, which files we're working on, and what we're going to do next."
    );

    const summaryResponse = await querySonnet(
      normalizeMessagesForAPI([...messages, summaryRequest]),
      ["You are a helpful AI assistant tasked with summarizing conversations."],
      0,
      tools,
      abortController.signal,
      {
        dangerouslySkipPermissions: false,
        model: slowAndCapableModel,
        prependCLISysprompt: true,
      }
    );

    // Extract summary from response, throw if we can't get it
    const content = summaryResponse.message.content;
    const summary =
      typeof content === "string"
        ? content
        : content.length > 0 && content[0]?.type === "text"
        ? content[0].text
        : null;

    if (!summary) {
      throw new Error(
        `Failed to generate conversation summary - response did not contain valid text content - ${summaryResponse}`
      );
    } else if (summary.startsWith(API_ERROR_MESSAGE_PREFIX)) {
      throw new Error(summary);
    }

    // Substitute low token usage info so that the context-size UI warning goes
    // away. The actual numbers don't matter too much: `countTokens` checks the
    // most recent assistant message for usage numbers, so this estimate will
    // be overridden quickly.
    summaryResponse.message.usage = {
      input_tokens: 0,
      output_tokens: summaryResponse.message.usage.output_tokens,
      cache_creation_input_tokens: 0,
      cache_read_input_tokens: 0,
    };

    // Clear screen and messages
    await clearTerminal();
    getMessagesSetter()([]);
    setForkConvoWithMessagesOnTheNextRender([
      createUserMessage(
        `Use the /compact command to clear the conversation history, and start a new conversation with the summary in context.`
      ),
      summaryResponse,
    ]);
    getContext.cache.clear?.();
    getCodeStyle.cache.clear?.();

    return ""; // not used, just for typesafety. TODO: avoid this hack
  },
  userFacingName() {
    return "compact";
  },
} satisfies Command;

export default compact;
```

#### Functionality

The `compact` command implements a sophisticated workflow:

1. **Conversation Summary Generation**:

   - Retrieves the current message history
   - Creates a user message requesting a conversation summary
   - Uses Claude API to generate a summary through the `querySonnet` function
   - Validates the summary to ensure it was successfully generated

2. **Token Usage Management**:

   - Manipulates the usage data to prevent context-size warnings
   - Sets input tokens to 0 to indicate the conversation has been compacted

3. **Context Reset with Summary**:
   - Clears the terminal display
   - Resets message history
   - Creates a new conversation "fork" containing only:
     - A user message indicating a compact operation occurred
     - The generated summary response
   - Clears context and code style caches

#### Technical Implementation Notes

The `compact` command demonstrates several advanced patterns:

1. **Meta-Conversation**: The command uses Claude to talk about the conversation itself, leveraging the model's summarization abilities.

2. **Model Selection**: Explicitly uses the `slowAndCapableModel` option to ensure high-quality summarization.

3. **Content Extraction Logic**: Implements robust parsing of the response content, handling different content formats (string vs. structured content).

4. **Error Handling**: Provides clear error messages for when summarization fails or when the API returns an error.

5. **Token Manipulation**: Intelligently manipulates token usage information to maintain a good user experience after compaction.

6. **Conversation Forking**: Uses the `setForkConvoWithMessagesOnTheNextRender` mechanism to create a new conversation branch with only the summary.

#### User Experience Benefits

The `compact` command addresses several key pain points in AI assistant interactions:

1. **Context Window Management**: Helps users stay within token limits while preserving the essence of the conversation.

2. **Conversation Continuity**: Unlike a complete clear, it maintains the thread of discussion through the summary.

3. **Work Session Persistence**: Preserves information about files being edited and tasks in progress.

4. **Smart Reset**: Performs a targeted reset that balances clearing space with maintaining context.

The command is particularly valuable for long development sessions where context limits become an issue but completely starting over would lose important progress information.

### config Command

The `config` command provides an interactive terminal interface for viewing and editing Claude Code's configuration settings, including model settings, UI preferences, and API keys.

#### Implementation

The command is implemented in `commands/config.tsx` as a type: 'local-jsx' command that renders a React component:

```typescript
import { Command } from "../commands";
import { Config } from "../components/Config";
import * as React from "react";

const config = {
  type: "local-jsx",
  name: "config",
  description: "Open config panel",
  isEnabled: true,
  isHidden: false,
  async call(onDone) {
    return <Config onClose={onDone} />;
  },
  userFacingName() {
    return "config";
  },
} satisfies Command;

export default config;
```

Like the `bug` command, this command uses JSX to render an interactive UI component. The actual functionality is implemented in the `Config` component located in `components/Config.tsx`.

#### UI Component

The `Config` component implements a rich terminal-based settings interface with the following features:

1. **Settings Management**: Displays a list of configurable settings with their current values.

2. **Multiple Setting Types**: Supports various setting types:

   - `boolean`: Toggle settings (true/false)
   - `enum`: Options from a predefined list
   - `string`: Text input values
   - `number`: Numeric values

3. **Interactive Editing**: Allows users to:

   - Navigate settings with arrow keys
   - Toggle boolean and enum settings with Enter/Space
   - Edit string and number settings with a text input mode
   - Exit configuration with Escape

4. **Configuration Persistence**: Saves settings to a configuration file using `saveGlobalConfig`.

#### Configuration Options

The component exposes numerous configuration options, including:

1. **Model Configuration**:

   - AI Provider selection (anthropic, openai, custom)
   - API keys for small and large models
   - Model names for both small and large models
   - Base URLs for API endpoints
   - Max token settings
   - Reasoning effort levels

2. **User Interface**:

   - Theme selection (light, dark, light-daltonized, dark-daltonized)
   - Verbose output toggle

3. **System Settings**:
   - Notification preferences
   - HTTP proxy configuration

#### Technical Implementation Notes

The `Config` component demonstrates several advanced patterns:

1. **State Management**: Uses React's `useState` to track:

   - Current configuration state
   - Selected setting index
   - Editing mode state
   - Current input text
   - Input validation errors

2. **Reference Comparison**: Maintains a reference to the initial configuration using `useRef` to track changes.

3. **Keyboard Input Handling**: Implements sophisticated keyboard handling for navigation and editing:

   - Arrow keys for selection
   - Enter/Space for toggling/editing
   - Escape for cancellation
   - Input handling with proper validation

4. **Input Sanitization**: Cleans input text to prevent control characters and other problematic input.

5. **Visual Feedback**: Provides clear visual indication of:

   - Currently selected item
   - Editing state
   - Input errors
   - Available actions

6. **Change Tracking**: Tracks and logs configuration changes when exiting.

#### User Experience Design

The config component showcases several UI/UX design principles for terminal applications:

1. **Modal Interface**: Creates a focused settings panel that temporarily takes over the terminal.

2. **Progressive Disclosure**: Shows relevant controls and options based on the current state.

3. **Clear Instructions**: Displays context-sensitive help text at the bottom of the interface.

4. **Visual Highlighting**: Uses color and indicators to show the current selection and editing state.

5. **Immediate Feedback**: Changes take effect immediately, with visual confirmation.

6. **Multiple Input Methods**: Supports keyboard navigation, toggling, and text input in a unified interface.

7. **Safe Editing**: Provides validation and escape routes for configuration editing.

The `config` command demonstrates how Claude Code effectively combines the simplicity of terminal interfaces with the rich interaction capabilities typically associated with graphical applications, creating a powerful yet accessible configuration experience.

### compact Command

The `compact` command offers a sophisticated solution to context management by summarizing the conversation history before clearing it, thereby retaining essential context while freeing up token space.

#### Implementation

The command is implemented in `commands/compact.ts` as a type: 'local' command:

```typescript
import { Command } from "../commands";
import { getContext } from "../context";
import { getMessagesGetter, getMessagesSetter } from "../messages";
import { API_ERROR_MESSAGE_PREFIX, querySonnet } from "../services/claude";
import {
  createUserMessage,
  normalizeMessagesForAPI,
} from "../utils/messages.js";
import { getCodeStyle } from "../utils/style";
import { clearTerminal } from "../utils/terminal";

const compact = {
  type: "local",
  name: "compact",
  description: "Clear conversation history but keep a summary in context",
  isEnabled: true,
  isHidden: false,
  async call(
    _,
    {
      options: { tools, slowAndCapableModel },
      abortController,
      setForkConvoWithMessagesOnTheNextRender,
    }
  ) {
    // Get existing messages before clearing
    const messages = getMessagesGetter()();

    // Add summary request as a new message
    const summaryRequest = createUserMessage(
      "Provide a detailed but concise summary of our conversation above. Focus on information that would be helpful for continuing the conversation, including what we did, what we're doing, which files we're working on, and what we're going to do next."
    );

    const summaryResponse = await querySonnet(
      normalizeMessagesForAPI([...messages, summaryRequest]),
      ["You are a helpful AI assistant tasked with summarizing conversations."],
      0,
      tools,
      abortController.signal,
      {
        dangerouslySkipPermissions: false,
        model: slowAndCapableModel,
        prependCLISysprompt: true,
      }
    );

    // Extract summary from response, throw if we can't get it
    const content = summaryResponse.message.content;
    const summary =
      typeof content === "string"
        ? content
        : content.length > 0 && content[0]?.type === "text"
        ? content[0].text
        : null;

    if (!summary) {
      throw new Error(
        `Failed to generate conversation summary - response did not contain valid text content - ${summaryResponse}`
      );
    } else if (summary.startsWith(API_ERROR_MESSAGE_PREFIX)) {
      throw new Error(summary);
    }

    // Substitute low token usage info so that the context-size UI warning goes
    // away. The actual numbers don't matter too much: `countTokens` checks the
    // most recent assistant message for usage numbers, so this estimate will
    // be overridden quickly.
    summaryResponse.message.usage = {
      input_tokens: 0,
      output_tokens: summaryResponse.message.usage.output_tokens,
      cache_creation_input_tokens: 0,
      cache_read_input_tokens: 0,
    };

    // Clear screen and messages
    await clearTerminal();
    getMessagesSetter()([]);
    setForkConvoWithMessagesOnTheNextRender([
      createUserMessage(
        `Use the /compact command to clear the conversation history, and start a new conversation with the summary in context.`
      ),
      summaryResponse,
    ]);
    getContext.cache.clear?.();
    getCodeStyle.cache.clear?.();

    return ""; // not used, just for typesafety. TODO: avoid this hack
  },
  userFacingName() {
    return "compact";
  },
} satisfies Command;

export default compact;
```

#### Functionality

The `compact` command implements a sophisticated workflow:

1. **Conversation Summary Generation**:

   - Retrieves the current message history
   - Creates a user message requesting a conversation summary
   - Uses Claude API to generate a summary through the `querySonnet` function
   - Validates the summary to ensure it was successfully generated

2. **Token Usage Management**:

   - Manipulates the usage data to prevent context-size warnings
   - Sets input tokens to 0 to indicate the conversation has been compacted

3. **Context Reset with Summary**:
   - Clears the terminal display
   - Resets message history
   - Creates a new conversation "fork" containing only:
     - A user message indicating a compact operation occurred
     - The generated summary response
   - Clears context and code style caches

#### Technical Implementation Notes

The `compact` command demonstrates several advanced patterns:

1. **Meta-Conversation**: The command uses Claude to talk about the conversation itself, leveraging the model's summarization abilities.

2. **Model Selection**: Explicitly uses the `slowAndCapableModel` option to ensure high-quality summarization.

3. **Content Extraction Logic**: Implements robust parsing of the response content, handling different content formats (string vs. structured content).

4. **Error Handling**: Provides clear error messages for when summarization fails or when the API returns an error.

5. **Token Manipulation**: Intelligently manipulates token usage information to maintain a good user experience after compaction.

6. **Conversation Forking**: Uses the `setForkConvoWithMessagesOnTheNextRender` mechanism to create a new conversation branch with only the summary.

#### User Experience Benefits

The `compact` command addresses several key pain points in AI assistant interactions:

1. **Context Window Management**: Helps users stay within token limits while preserving the essence of the conversation.

2. **Conversation Continuity**: Unlike a complete clear, it maintains the thread of discussion through the summary.

3. **Work Session Persistence**: Preserves information about files being edited and tasks in progress.

4. **Smart Reset**: Performs a targeted reset that balances clearing space with maintaining context.

The command is particularly valuable for long development sessions where context limits become an issue but completely starting over would lose important progress information.

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

### doctor Command

The `doctor` command provides a diagnostic tool for checking the health of the Claude Code installation, with a focus on npm permissions required for proper auto-updating functionality.

#### Implementation

The command is implemented in `commands/doctor.ts` as a type: 'local-jsx' command that renders a React component:

```typescript
import React from "react";
import type { Command } from "../commands";
import { Doctor } from "../screens/Doctor";

const doctor: Command = {
  name: "doctor",
  description: "Checks the health of your Claude Code installation",
  isEnabled: true,
  isHidden: false,
  userFacingName() {
    return "doctor";
  },
  type: "local-jsx",
  call(onDone) {
    const element = React.createElement(Doctor, {
      onDone,
      doctorMode: true,
    });
    return Promise.resolve(element);
  },
};

export default doctor;
```

The command uses the `Doctor` screen component defined in `screens/Doctor.tsx`, passing the special `doctorMode` flag to indicate it's being used as a diagnostic tool rather than during initialization.

#### Functionality

The `doctor` command implements a comprehensive installation health check focused on npm permissions:

1. **Permissions Verification**:

   - Checks if the npm global installation directory has correct write permissions
   - Determines the current npm prefix path
   - Validates if auto-updates can function correctly

2. **Status Reporting**:

   - Provides clear success or failure messages about installation health
   - Shows a green checkmark and confirmation message for healthy installations
   - Presents an interactive dialog for resolving permission issues

3. **Problem Resolution**:

   - Offers three remediation options when permission problems are detected:
     1. **Manual Fix**: Provides a sudo/icacls command to fix permissions on the current npm prefix
     2. **New Prefix**: Guides the user through creating a new npm prefix in their home directory
     3. **Skip**: Allows deferring the fix until later

4. **Installation Repair**:
   - For the "new prefix" option, provides a guided, step-by-step process to:
     - Create a new directory for npm global packages
     - Configure npm to use the new location
     - Update shell PATH configurations
     - Reinstall Claude Code globally

#### Technical Implementation Notes

The command demonstrates several sophisticated implementation patterns:

1. **Component-Based Architecture**: Uses React components for the UI, allowing for a rich interactive experience.

2. **Platform-Aware Logic**: Implements different permission-fixing approaches for Windows vs. Unix-like systems:

   - Windows: Uses `icacls` for permission management and `setx` for PATH updates
   - Unix: Uses `sudo chown/chmod` for permission fixes and shell config file updates

3. **Shell Detection**: For Unix platforms, identifies and updates multiple possible shell configuration files:

   - .bashrc and .bash_profile for Bash
   - .zshrc for Zsh
   - config.fish for Fish shell

4. **Status Management**: Uses React state to track:

   - Permission check status
   - Selected remediation option
   - Custom prefix path (if chosen)
   - Step-by-step installation progress

5. **Lock-Based Concurrency Control**: Implements a file-based locking mechanism to prevent multiple processes from attempting auto-updates simultaneously.

6. **Error Handling**: Provides detailed error reporting and recovery options:
   - Shows precisely which operation failed
   - Offers alternative approaches when errors occur
   - Logs error details for debugging

#### User Experience Benefits

The `doctor` command addresses several important pain points for CLI tool users:

1. **Installation Troubleshooting**: Provides clear diagnostics and fixes for common problems:

   - Permission issues that prevent updates
   - Global npm configuration problems
   - PATH configuration issues

2. **Security-Conscious Design**: Offers both privileged (sudo) and non-privileged (new prefix) solutions, allowing users to choose based on their security preferences.

3. **Multi-Platform Support**: Works identically across Windows, macOS, and Linux with platform-appropriate solutions.

4. **Shell Environment Enhancement**: Automatically updates shell configuration files to ensure the installation works correctly across terminal sessions.

5. **Visual Progress Feedback**: Uses spinners and checkmarks to keep users informed about long-running operations.

The command provides a comprehensive diagnostics and repair tool that helps maintain a healthy Claude Code installation, particularly focusing on the auto-update capability which is crucial for keeping the tool current with new features and improvements.

### help Command

The `help` command provides users with information about Claude Code's usage, available commands, and general guidance for effective interaction with the tool.

#### Implementation

The command is implemented in `commands/help.tsx` as a type: 'local-jsx' command that renders a React component:

```typescript
import { Command } from "../commands";
import { Help } from "../components/Help";
import * as React from "react";

const help = {
  type: "local-jsx",
  name: "help",
  description: "Show help and available commands",
  isEnabled: true,
  isHidden: false,
  async call(onDone, { options: { commands } }) {
    return <Help commands={commands} onClose={onDone} />;
  },
  userFacingName() {
    return "help";
  },
} satisfies Command;

export default help;
```

The command delegates to the `Help` component in `components/Help.tsx`, passing the list of available commands and an `onClose` callback to handle when the help screen should be dismissed.

#### Functionality

The `Help` component implements a progressive disclosure pattern for displaying information:

1. **Basic Information**:

   - Shows the product name and version
   - Displays a brief description of Claude Code's capabilities and limitations
   - Presents a disclaimer about the beta nature of the product

2. **Usage Modes** (shown after a brief delay):

   - Explains the two primary ways to use Claude Code:
     - REPL (interactive session)
     - Non-interactive mode with the `-p` flag for one-off questions
   - Mentions that users can run `claude -h` for additional command-line options

3. **Common Tasks** (shown after a longer delay):

   - Lists examples of typical use cases:
     - Asking questions about the codebase
     - Editing files
     - Fixing errors
     - Running commands
     - Running bash commands

4. **Available Commands** (shown after the longest delay):

   - Displays a comprehensive list of all enabled slash commands
   - Shows command names and descriptions
   - Filters out hidden commands

5. **Additional Resources**:
   - Provides links for getting more help
   - Shows different resources based on user type (internal vs. external)

#### Technical Implementation Notes

The `help` command demonstrates several effective patterns:

1. **Progressive Disclosure**: Uses a time-based mechanism to gradually reveal information:

   ```typescript
   const [count, setCount] = React.useState(0);

   React.useEffect(() => {
     const timer = setTimeout(() => {
       if (count < 3) {
         setCount(count + 1);
       }
     }, 250);

     return () => clearTimeout(timer);
   }, [count]);
   ```

   This approach avoids overwhelming users with too much information at once, showing more details as they spend time on the help screen.

2. **Filtering System**: Uses `filter` to show only non-hidden commands:

   ```typescript
   const filteredCommands = commands.filter((cmd) => !cmd.isHidden);
   ```

   This keeps the help screen focused on commands relevant to users.

3. **Dynamic Resource Links**: Changes help resources based on user type:

   ```typescript
   const isInternal = process.env.USER_TYPE === "ant";
   const moreHelp = isInternal
     ? "[ANT-ONLY] For more help: go/claude-cli or #claude-cli-feedback"
     : `Learn more at: ${MACRO.README_URL}`;
   ```

   This customizes the experience for different user populations.

4. **Input Handling**: Uses Ink's `useInput` hook to detect when the user presses Enter:

   ```typescript
   useInput((_, key) => {
     if (key.return) onClose();
   });
   ```

   This allows for clean dismissal of the help screen.

5. **Conditional Rendering**: Uses the `count` state to progressively show different sections:
   ```typescript
   {
     count >= 1 && (
       <Box flexDirection="column" marginTop={1}>
         <Text bold>Usage Modes:</Text>
         {/* Usage content */}
       </Box>
     );
   }
   ```
   This creates the staggered reveal effect for information groups.

#### User Experience Benefits

The `help` command addresses several important needs for CLI tool users:

1. **Onboarding Assistance**: Provides new users with immediate guidance on how to use the tool effectively.

2. **Command Discovery**: Makes it easy to see what slash commands are available without having to memorize them.

3. **Progressive Learning**: The staggered reveal of information allows users to absorb basics first before seeing more advanced options.

4. **Usage Examples**: Shows concrete examples of common use cases, helping users understand practical applications.

5. **Quick Reference**: Serves as a compact reference for command options during regular use.

The help command exemplifies Claude Code's approach to user experience: it's focused on being informative while remaining concise and unobtrusive, with multiple levels of detail available as users need them.

### init Command

The `init` command helps users initialize a new project for use with Claude Code by creating a KODING.md file that contains key information about the codebase and project.

#### Implementation

The command is implemented in `commands/init.ts` as a type: 'prompt' command that passes a specific request to Claude:

```typescript
import type { Command } from "../commands";
import { markProjectOnboardingComplete } from "../ProjectOnboarding";

const command = {
  type: "prompt",
  name: "init",
  description: "Initialize a new KODING.md file with codebase documentation",
  isEnabled: true,
  isHidden: false,
  progressMessage: "analyzing your codebase",
  userFacingName() {
    return "init";
  },
  async getPromptForCommand(_args: string) {
    // Mark onboarding as complete when init command is run
    markProjectOnboardingComplete();
    return [
      {
        role: "user",
        content: [
          {
            type: "text",
            text: `Please analyze this codebase and create a KODING.md file containing:
1. Build/lint/test commands - especially for running a single test
2. Code style guidelines including imports, formatting, types, naming conventions, error handling, etc.

The file you create will be given to agentic coding agents (such as yourself) that operate in this repository. Make it about 20 lines long.
If there's already a KODING.md, improve it.
If there are Cursor rules (in .cursor/rules/ or .cursorrules) or Copilot rules (in .github/copilot-instructions.md), make sure to include them.`,
          },
        ],
      },
    ];
  },
} satisfies Command;

export default command;
```

Unlike many other commands that directly perform actions, the `init` command is implemented as a 'prompt' type command that simply formulates a specific request to Claude to analyze the codebase and generate a KODING.md file.

#### Functionality

The `init` command serves several important functions:

1. **Project Configuration Generation**:

   - Instructs Claude to analyze the codebase structure, conventions, and patterns
   - Generates a KODING.md file with essential project information
   - Focuses on capturing build/lint/test commands and code style guidelines

2. **Existing File Enhancement**:

   - Checks if a KODING.md file already exists
   - Improves the existing file with additional information if present
   - Preserves existing content while enhancing where needed

3. **Integration with Other Tools**:

   - Looks for Cursor rules (in .cursor/rules/ or .cursorrules)
   - Looks for Copilot instructions (in .github/copilot-instructions.md)
   - Incorporates these rules into the KODING.md file for a unified guidance document

4. **Onboarding Status Tracking**:
   - Calls `markProjectOnboardingComplete()` to update the project configuration
   - This flags the project as having completed onboarding steps
   - Prevents repeated onboarding prompts in future sessions

#### Technical Implementation Notes

The `init` command demonstrates several interesting technical aspects:

1. **Command Type**: Uses the 'prompt' type rather than 'local' or 'local-jsx', which means it sets up a specific request to Claude rather than executing custom logic or rendering a UI component.

2. **Progress Message**: Includes a `progressMessage` property ("analyzing your codebase") that's displayed to users while Claude processes the request, providing feedback during what could be a longer operation.

3. **Project Onboarding Integration**: The command is part of the project onboarding workflow, tracking completion state in the project configuration:

   ```typescript
   export function markProjectOnboardingComplete(): void {
     const projectConfig = getCurrentProjectConfig();
     if (!projectConfig.hasCompletedProjectOnboarding) {
       saveCurrentProjectConfig({
         ...projectConfig,
         hasCompletedProjectOnboarding: true,
       });
     }
   }
   ```

4. **External Tool Recognition**: Explicitly looks for configuration files from other AI coding tools (Cursor, Copilot) to create a unified guidance document, showing awareness of the broader AI coding tool ecosystem.

5. **Conciseness Guidance**: Explicitly requests a document of around 20 lines, balancing comprehensive information with brevity for practical usage.

#### User Experience Benefits

The `init` command provides several important benefits for Claude Code users:

1. **Simplified Project Setup**: Makes it easy to prepare a codebase for effective use with Claude Code with a single command.

2. **Consistent Memory**: Creates a standardized document that Claude Code will access in future sessions, providing consistent context.

3. **Command Discovery**: By capturing build/test/lint commands, it helps Claude remember the correct commands for the project, reducing the need for users to repeatedly provide them.

4. **Code Style Guidance**: Helps Claude generate code that matches the project's conventions, improving integration of AI-generated code.

5. **Onboarding Pathway**: Serves as a key step in the onboarding flow for new projects, guiding users toward the most effective usage patterns.

The `init` command exemplifies Claude Code's overall approach to becoming more effective over time by creating persistent context that improves future interactions. By capturing project-specific information in a standardized format, it enables Claude to provide more tailored assistance for each unique codebase.

### listen Command

The `listen` command provides macOS users with the ability to dictate to Claude Code using speech recognition, enhancing accessibility and offering an alternative input method.

#### Implementation

The command is implemented in `commands/listen.ts` as a type: 'local' command that invokes macOS's built-in dictation feature:

```typescript
import { Command } from "../commands";
import { logError } from "../utils/log";
import { execFileNoThrow } from "../utils/execFileNoThrow";

const isEnabled =
  process.platform === "darwin" &&
  ["iTerm.app", "Apple_Terminal"].includes(process.env.TERM_PROGRAM || "");

const listen: Command = {
  type: "local",
  name: "listen",
  description: "Activates speech recognition and transcribes speech to text",
  isEnabled: isEnabled,
  isHidden: isEnabled,
  userFacingName() {
    return "listen";
  },
  async call(_, { abortController }) {
    // Start dictation using AppleScript
    const script = `tell application "System Events" to tell ¬
(the first process whose frontmost is true) to tell ¬
menu bar 1 to tell ¬
menu bar item "Edit" to tell ¬
menu "Edit" to tell ¬
menu item "Start Dictation" to ¬
if exists then click it`;

    const { stderr, code } = await execFileNoThrow(
      "osascript",
      ["-e", script],
      abortController.signal
    );

    if (code !== 0) {
      logError(`Failed to start dictation: ${stderr}`);
      return "Failed to start dictation";
    }
    return "Dictation started. Press esc to stop.";
  },
};

export default listen;
```

The command uses AppleScript to trigger macOS's built-in dictation feature, automating the process of selecting "Start Dictation" from the Edit menu.

#### Functionality

The `listen` command provides a simple but effective accessibility enhancement:

1. **Platform Integration**:

   - Invokes macOS's built-in dictation feature
   - Uses AppleScript to navigate the application's menu structure
   - Triggers the "Start Dictation" menu item in the Edit menu

2. **Status Reporting**:

   - Returns clear success or error messages
   - Provides user instructions on how to stop dictation
   - Logs detailed error information when dictation fails to start

3. **Platform-Specific Availability**:
   - Only enabled on macOS platforms
   - Further restricted to specific terminal applications (iTerm.app and Apple_Terminal)
   - Hidden from command listings on unsupported platforms

#### Technical Implementation Notes

The `listen` command demonstrates several interesting technical approaches:

1. **Platform Detection**: Uses environment variables and platform checks to determine when the command should be available:

   ```typescript
   const isEnabled =
     process.platform === "darwin" &&
     ["iTerm.app", "Apple_Terminal"].includes(process.env.TERM_PROGRAM || "");
   ```

2. **AppleScript Integration**: Uses a complex AppleScript command to navigate through application menus:

   ```typescript
   const script = `tell application "System Events" to tell ¬
   (the first process whose frontmost is true) to tell ¬
   menu bar 1 to tell ¬
   menu bar item "Edit" to tell ¬
   menu "Edit" to tell ¬
   menu item "Start Dictation" to ¬
   if exists then click it`;
   ```

   This script navigates the UI hierarchy to find and click the dictation menu item.

3. **Command Visibility Control**: Uses the same conditions for both `isEnabled` and `isHidden`, ensuring the command is simultaneously enabled and hidden on supported platforms:

   ```typescript
   isEnabled: isEnabled,
   isHidden: isEnabled,
   ```

   This unusual pattern makes the command available but not visible in help listings, suggesting it's an internal or experimental feature.

4. **Error Handling**: Implements robust error handling with detailed logging:
   ```typescript
   if (code !== 0) {
     logError(`Failed to start dictation: ${stderr}`);
     return "Failed to start dictation";
   }
   ```

#### User Experience Considerations

While simple in implementation, the `listen` command addresses several important user needs:

1. **Accessibility Enhancement**: Provides an alternative input method for users who prefer or require speech recognition.

2. **Workflow Efficiency**: Eliminates the need to manually navigate menus to start dictation, streamlining the process.

3. **Integrated Experience**: Keeps users within the Claude Code interface rather than requiring them to use separate dictation tools.

4. **Platform Integration**: Leverages native OS capabilities rather than implementing custom speech recognition, ensuring high-quality transcription.

The `listen` command demonstrates Claude Code's commitment to accessibility and platform integration, even if the implementation is relatively simple. By leveraging existing OS capabilities rather than reinventing them, it provides a valuable feature with minimal code complexity.

### login Command

The `login` command provides users with a secure OAuth 2.0 authentication flow to connect Claude Code with their Anthropic Console account, enabling API access and proper billing.

#### Implementation

The command is implemented in `commands/login.tsx` as a type: 'local-jsx' command that renders a React component for the authentication flow:

```typescript
import * as React from "react";
import type { Command } from "../commands";
import { ConsoleOAuthFlow } from "../components/ConsoleOAuthFlow";
import { clearTerminal } from "../utils/terminal";
import { isLoggedInToAnthropic } from "../utils/auth";
import { useExitOnCtrlCD } from "../hooks/useExitOnCtrlCD";
import { Box, Text } from "ink";
import { clearConversation } from "./clear";

export default () =>
  ({
    type: "local-jsx",
    name: "login",
    description: isLoggedInToAnthropic()
      ? "Switch Anthropic accounts"
      : "Sign in with your Anthropic account",
    isEnabled: true,
    isHidden: false,
    async call(onDone, context) {
      await clearTerminal();
      return (
        <Login
          onDone={async () => {
            clearConversation(context);
            onDone();
          }}
        />
      );
    },
    userFacingName() {
      return "login";
    },
  } satisfies Command);

function Login(props: { onDone: () => void }) {
  const exitState = useExitOnCtrlCD(props.onDone);
  return (
    <Box flexDirection="column">
      <ConsoleOAuthFlow onDone={props.onDone} />
      <Box marginLeft={3}>
        <Text dimColor>
          {exitState.pending ? (
            <>Press {exitState.keyName} again to exit</>
          ) : (
            ""
          )}
        </Text>
      </Box>
    </Box>
  );
}
```

The command uses a factory function to dynamically create a command object that adapts its description based on the current login state. The main logic is delegated to the `ConsoleOAuthFlow` component, which handles the OAuth flow with the Anthropic API.

#### Functionality

The `login` command implements a comprehensive authentication flow:

1. **OAuth 2.0 Integration**:

   - Uses OAuth 2.0 with PKCE (Proof Key for Code Exchange) for security
   - Opens a browser for the user to log in to Anthropic Console
   - Handles both automatic browser redirect and manual code entry flows
   - Securely exchanges authorization codes for access tokens

2. **Account Management**:

   - Creates and stores API keys for authenticated users
   - Normalizes and securely saves keys in the global configuration
   - Tracks account information including account UUID and organization details
   - Provides context-aware descriptions ("Sign in" vs "Switch accounts")

3. **Security Features**:

   - Implements state verification to prevent CSRF attacks
   - Uses code verifiers and challenges for secure code exchange
   - Validates all tokens and responses from the authentication server
   - Provides clear error messages for authentication failures

4. **UI Experience**:
   - Clears the terminal for a clean login experience
   - Provides a progressive disclosure flow with appropriate status messages
   - Offers fallback mechanisms for cases where automatic browser opening fails
   - Shows loading indicators during asynchronous operations

#### Technical Implementation Notes

The login command demonstrates several sophisticated technical approaches:

1. **Local HTTP Server**: Creates a temporary HTTP server for OAuth callback handling:

   ```typescript
   this.server = http.createServer(
     (req: IncomingMessage, res: ServerResponse) => {
       const parsedUrl = url.parse(req.url || "", true);
       if (parsedUrl.pathname === "/callback") {
         // Handle OAuth callback
       }
     }
   );
   ```

2. **PKCE Implementation**: Implements the Proof Key for Code Exchange extension to OAuth:

   ```typescript
   function generateCodeVerifier(): string {
     return base64URLEncode(crypto.randomBytes(32));
   }

   async function generateCodeChallenge(verifier: string): Promise<string> {
     const encoder = new TextEncoder();
     const data = encoder.encode(verifier);
     const digest = await crypto.subtle.digest("SHA-256", data);
     return base64URLEncode(Buffer.from(digest));
   }
   ```

3. **Parallel Authentication Paths**: Supports both automatic and manual authentication flows:

   ```typescript
   const { autoUrl, manualUrl } = this.generateAuthUrls(codeChallenge, state);
   await authURLHandler(manualUrl); // Show manual URL in UI
   await openBrowser(autoUrl); // Try automatic browser opening
   ```

4. **Promise-Based Flow Control**: Uses promises to coordinate the asynchronous authentication flow:

   ```typescript
   const { authorizationCode, useManualRedirect } = await new Promise<{
     authorizationCode: string;
     useManualRedirect: boolean;
   }>((resolve, reject) => {
     this.pendingCodePromise = { resolve, reject };
     this.startLocalServer(state, onReady);
   });
   ```

5. **State Management with React**: Uses React state and hooks for UI management:

   ```typescript
   const [oauthStatus, setOAuthStatus] = useState<OAuthStatus>({
     state: "idle",
   });
   ```

6. **Error Recovery**: Implements sophisticated error handling with retry mechanisms:
   ```typescript
   if (oauthStatus.state === "error" && oauthStatus.toRetry) {
     setPastedCode("");
     setOAuthStatus({
       state: "about_to_retry",
       nextState: oauthStatus.toRetry,
     });
   }
   ```

#### User Experience Benefits

The `login` command addresses several important user needs:

1. **Seamless Authentication**: Provides a smooth authentication experience without requiring manual API key creation or copying.

2. **Cross-Platform Compatibility**: Works across different operating systems and browsers.

3. **Fallback Mechanisms**: Offers manual code entry when automatic browser redirection fails.

4. **Clear Progress Indicators**: Shows detailed status messages throughout the authentication process.

5. **Error Resilience**: Provides helpful error messages and retry options when authentication issues occur.

6. **Account Switching**: Allows users to easily switch between different Anthropic accounts.

The login command exemplifies Claude Code's approach to security and user experience, implementing a complex authentication flow with attention to both security best practices and ease of use.

### logout Command

The `logout` command provides users with the ability to sign out from their Anthropic account, removing stored authentication credentials and API keys from the local configuration.

#### Implementation

The command is implemented in `commands/logout.tsx` as a type: 'local-jsx' command that handles the logout process and renders a confirmation message:

```typescript
import * as React from "react";
import type { Command } from "../commands";
import { getGlobalConfig, saveGlobalConfig } from "../utils/config";
import { clearTerminal } from "../utils/terminal";
import { Text } from "ink";

export default {
  type: "local-jsx",
  name: "logout",
  description: "Sign out from your Anthropic account",
  isEnabled: true,
  isHidden: false,
  async call() {
    await clearTerminal();

    const config = getGlobalConfig();

    config.oauthAccount = undefined;
    config.primaryApiKey = undefined;
    config.hasCompletedOnboarding = false;

    if (config.customApiKeyResponses?.approved) {
      config.customApiKeyResponses.approved = [];
    }

    saveGlobalConfig(config);

    const message = (
      <Text>Successfully logged out from your Anthropic account.</Text>
    );

    setTimeout(() => {
      process.exit(0);
    }, 200);

    return message;
  },
  userFacingName() {
    return "logout";
  },
} satisfies Command;
```

Unlike the more complex `login` command, the `logout` command is relatively straightforward, focusing on removing authentication data from the configuration and providing a clean exit.

#### Functionality

The `logout` command performs several critical operations:

1. **Credential Removal**:

   - Clears the OAuth account information from the global configuration
   - Removes the primary API key used for authentication
   - Erases the list of approved API keys from storage
   - Resets the onboarding completion status

2. **User Experience**:

   - Clears the terminal before displaying the logout message
   - Provides a clear confirmation message about successful logout
   - Exits the application completely after a short delay
   - Ensures a clean break with the authenticated session

3. **Security Focus**:
   - Removes all sensitive authentication data from the local configuration
   - Ensures the next application start will require re-authentication
   - Prevents accidental API usage with old credentials
   - Provides a clean slate for a new login if desired

#### Technical Implementation Notes

Despite its relative simplicity, the `logout` command demonstrates several interesting implementation details:

1. **Configuration Management**: Uses the global configuration system to handle persistent state:

   ```typescript
   const config = getGlobalConfig();

   config.oauthAccount = undefined;
   config.primaryApiKey = undefined;
   config.hasCompletedOnboarding = false;

   if (config.customApiKeyResponses?.approved) {
     config.customApiKeyResponses.approved = [];
   }

   saveGlobalConfig(config);
   ```

2. **Graceful Exit Strategy**: Uses a timeout to allow the message to be displayed before exiting:

   ```typescript
   setTimeout(() => {
     process.exit(0);
   }, 200);
   ```

   This ensures the user sees confirmation before the application closes.

3. **Type Safety**: Uses the `satisfies Command` pattern to ensure type correctness:

   ```typescript
   export default {
     // Command implementation
   } satisfies Command;
   ```

4. **Terminal Management**: Clears the terminal before displaying the logout confirmation:

   ```typescript
   await clearTerminal();
   ```

   This creates a clean visual experience for the logout process.

5. **Optional Field Handling**: Carefully checks for the existence of optional configuration fields:
   ```typescript
   if (config.customApiKeyResponses?.approved) {
     config.customApiKeyResponses.approved = [];
   }
   ```

#### User Experience Benefits

The `logout` command addresses several important user needs:

1. **Account Security**: Provides a clear way to remove credentials when sharing devices or ending a session.

2. **User Confidence**: Confirms successful logout with a clear message, reassuring users their credentials have been removed.

3. **Clean Exit**: Exits the application completely, avoiding any state confusion in the current process.

4. **Simplicity**: Keeps the logout process straightforward and quick, with minimal user interaction required.

5. **Fresh Start**: Resets the onboarding status, ensuring a proper re-onboarding flow on next login.

The `logout` command provides a necessary counterpart to the `login` command, completing the authentication lifecycle with a secure, clean way to end a session. While much simpler than its login counterpart, it maintains the same attention to security and user experience that characterizes Claude Code's approach to authentication management.

### model Command

> [!WARNING]
> This command implementation is specific to the anon-kode fork of Claude Code and is not part of the original Claude Code codebase. The analysis below pertains to this specific implementation rather than standard Claude Code functionality.

The `model` command provides users with a comprehensive interface to configure and customize the AI models used by Claude Code, enabling fine-grained control over model selection, parameters, and provider settings.

#### Implementation

The command is implemented in `commands/model.tsx` as a type: 'local-jsx' command that renders a React component for model configuration:

```typescript
import React from "react";
import { render } from "ink";
import { ModelSelector } from "../components/ModelSelector";
import { enableConfigs } from "../utils/config";

export const help = "Change your AI provider and model settings";
export const description = "Change your AI provider and model settings";
export const isEnabled = true;
export const isHidden = false;
export const name = "model";
export const type = "local-jsx";

export function userFacingName(): string {
  return name;
}

export async function call(
  onDone: (result?: string) => void,
  { abortController }: { abortController?: AbortController }
): Promise<React.ReactNode> {
  enableConfigs();
  abortController?.abort?.();
  return (
    <ModelSelector
      onDone={() => {
        onDone();
      }}
    />
  );
}
```

The command uses a different export style than other commands, directly exporting properties and functions rather than a single object. The main functionality is handled by the `ModelSelector` component, which provides an interactive UI for configuring model settings.

#### Functionality

The `model` command provides a sophisticated model selection and configuration workflow:

1. **Multi-Model Management**:

   - Allows configuring both "large" and "small" models separately or together
   - Provides different models for different task complexities for optimal cost/performance
   - Shows current configuration information for reference

2. **Provider Selection**:

   - Supports multiple AI providers (Anthropic, OpenAI, Gemini, etc.)
   - Dynamically fetches available models from the selected provider's API
   - Handles provider-specific API requirements and authentication

3. **Model Parameters**:

   - Configures maximum token settings for response length control
   - Offers reasoning effort controls for supported models (low/medium/high)
   - Preserves provider-specific configuration options

4. **Search and Filtering**:

   - Provides search functionality to filter large model lists
   - Displays model capabilities including token limits and feature support
   - Organizes models with sensible sorting and grouping

5. **API Key Management**:
   - Securely handles API keys for different providers
   - Masks sensitive information during input and display
   - Stores keys securely in the local configuration

#### Technical Implementation Notes

The `model` command demonstrates several sophisticated technical approaches:

1. **Multi-Step Navigation**: Implements a screen stack pattern for intuitive flow navigation:

   ```typescript
   const [screenStack, setScreenStack] = useState<
     Array<
       | "modelType"
       | "provider"
       | "apiKey"
       | "model"
       | "modelParams"
       | "confirmation"
     >
   >(["modelType"]);

   // Current screen is always the last item in the stack
   const currentScreen = screenStack[screenStack.length - 1];

   // Function to navigate to a new screen
   const navigateTo = (
     screen:
       | "modelType"
       | "provider"
       | "apiKey"
       | "model"
       | "modelParams"
       | "confirmation"
   ) => {
     setScreenStack((prev) => [...prev, screen]);
   };

   // Function to go back to the previous screen
   const goBack = () => {
     if (screenStack.length > 1) {
       // Remove the current screen from the stack
       setScreenStack((prev) => prev.slice(0, -1));
     } else {
       // If we're at the first screen, call onDone to exit
       onDone();
     }
   };
   ```

2. **Dynamic Model Loading**: Fetches available models directly from provider APIs:

   ```typescript
   async function fetchModels() {
     setIsLoadingModels(true);
     setModelLoadError(null);

     try {
       // Provider-specific logic...
       const openai = new OpenAI({
         apiKey: apiKey,
         baseURL: baseURL,
         dangerouslyAllowBrowser: true,
       });

       // Fetch the models
       const response = await openai.models.list();

       // Transform the response into our ModelInfo format
       const fetchedModels = [];
       // Process models...

       return fetchedModels;
     } catch (error) {
       setModelLoadError(`Failed to load models: ${error.message}`);
       throw error;
     } finally {
       setIsLoadingModels(false);
     }
   }
   ```

3. **Form Focus Management**: Implements sophisticated form navigation with keyboard support:

   ```typescript
   // Handle Tab key for form navigation in model params screen
   useInput((input, key) => {
     if (currentScreen === "modelParams" && key.tab) {
       const formFields = getFormFieldsForModelParams();
       // Move to next field
       setActiveFieldIndex((current) => (current + 1) % formFields.length);
       return;
     }

     // Handle Enter key for form submission in model params screen
     if (currentScreen === "modelParams" && key.return) {
       const formFields = getFormFieldsForModelParams();

       if (activeFieldIndex === formFields.length - 1) {
         // If on the Continue button, submit the form
         handleModelParamsSubmit();
       }
       return;
     }
   });
   ```

4. **Provider-Specific Handling**: Implements custom logic for different AI providers:

   ```typescript
   // For Gemini, use the separate fetchGeminiModels function
   if (selectedProvider === "gemini") {
     const geminiModels = await fetchGeminiModels();
     setAvailableModels(geminiModels);
     navigateTo("model");
     return geminiModels;
   }
   ```

5. **Configuration Persistence**: Carefully updates global configuration with new model settings:
   ```typescript
   function saveConfiguration(provider: ProviderType, model: string) {
     const baseURL = providers[provider]?.baseURL || "";

     // Create a new config object based on the existing one
     const newConfig = { ...config };

     // Update the primary provider regardless of which model we're changing
     newConfig.primaryProvider = provider;

     // Update the appropriate model based on the selection
     if (modelTypeToChange === "both" || modelTypeToChange === "large") {
       newConfig.largeModelName = model;
       newConfig.largeModelBaseURL = baseURL;
       newConfig.largeModelApiKey = apiKey || config.largeModelApiKey;
       newConfig.largeModelMaxTokens = parseInt(maxTokens);

       // Save reasoning effort for large model if supported
       if (supportsReasoningEffort) {
         newConfig.largeModelReasoningEffort = reasoningEffort;
       } else {
         newConfig.largeModelReasoningEffort = undefined;
       }
     }

     // Similar handling for small model...

     // Save the updated configuration
     saveGlobalConfig(newConfig);
   }
   ```

#### User Experience Benefits

The `model` command provides several important benefits for Claude Code users:

1. **Customization Control**: Gives users fine-grained control over the AI models powering their interaction.

2. **Cost Optimization**: Allows setting different models for different complexity tasks, optimizing for cost and speed.

3. **Provider Flexibility**: Enables users to choose from multiple AI providers based on preference, cost, or feature needs.

4. **Parameter Tuning**: Offers advanced users the ability to tune model parameters for optimal performance.

5. **Progressive Disclosure**: Uses a step-by-step flow that makes configuration accessible to both novice and advanced users.

6. **Intuitive Navigation**: Implements keyboard navigation with clear indicators for a smooth configuration experience.

The `model` command exemplifies Claude Code's approach to giving users control and flexibility while maintaining an accessible interface, keeping advanced configuration options available but not overwhelming.

### cost Command

The `cost` command provides users with visibility into the cost and duration of their current Claude Code session, helping them monitor their API usage and expenses.

#### Implementation

The command is implemented in `commands/cost.ts` as a simple type: 'local' command that calls a formatting function:

```typescript
import type { Command } from "../commands";
import { formatTotalCost } from "../cost-tracker";

const cost = {
  type: "local",
  name: "cost",
  description: "Show the total cost and duration of the current session",
  isEnabled: true,
  isHidden: false,
  async call() {
    return formatTotalCost();
  },
  userFacingName() {
    return "cost";
  },
} satisfies Command;

export default cost;
```

This command relies on the cost tracking system implemented in `cost-tracker.ts`, which maintains a running total of API costs and session duration.

#### Cost Tracking System

The cost tracking system is implemented in `cost-tracker.ts` and consists of several key components:

1. **State Management**: Maintains a simple singleton state object tracking:

   - `totalCost`: Running total of API costs in USD
   - `totalAPIDuration`: Cumulative time spent waiting for API responses
   - `startTime`: Timestamp when the session began

2. **Cost Accumulation**: Provides a function to add costs as they occur:

   ```typescript
   export function addToTotalCost(cost: number, duration: number): void {
     STATE.totalCost += cost;
     STATE.totalAPIDuration += duration;
   }
   ```

3. **Reporting**: Formats cost information in a human-readable format:

   ```typescript
   export function formatTotalCost(): string {
     return chalk.grey(
       `Total cost: ${formatCost(STATE.totalCost)}
       Total duration (API): ${formatDuration(STATE.totalAPIDuration)}
       Total duration (wall): ${formatDuration(getTotalDuration())}`
     );
   }
   ```

4. **Persistence**: Uses a React hook to save session cost data when the process exits:
   ```typescript
   export function useCostSummary(): void {
     useEffect(() => {
       const f = () => {
         process.stdout.write("\n" + formatTotalCost() + "\n");

         // Save last cost and duration to project config
         const projectConfig = getCurrentProjectConfig();
         saveCurrentProjectConfig({
           ...projectConfig,
           lastCost: STATE.totalCost,
           lastAPIDuration: STATE.totalAPIDuration,
           lastDuration: getTotalDuration(),
           lastSessionId: SESSION_ID,
         });
       };
       process.on("exit", f);
       return () => {
         process.off("exit", f);
       };
     }, []);
   }
   ```

#### UI Components

The cost tracking system is complemented by two UI components:

1. **Cost Component**: A simple display component used in the debug panel to show the most recent API call cost:

   ```typescript
   export function Cost({
     costUSD,
     durationMs,
     debug,
   }: Props): React.ReactNode {
     if (!debug) {
       return null;
     }

     const durationInSeconds = (durationMs / 1000).toFixed(1);
     return (
       <Box flexDirection="column" minWidth={23} width={23}>
         <Text dimColor>
           Cost: ${costUSD.toFixed(4)} ({durationInSeconds}s)
         </Text>
       </Box>
     );
   }
   ```

2. **CostThresholdDialog**: A warning dialog shown when users exceed a certain cost threshold:

   ```typescript
   export function CostThresholdDialog({ onDone }: Props): React.ReactNode {
     // Handle Ctrl+C, Ctrl+D and Esc
     useInput((input, key) => {
       if ((key.ctrl && (input === "c" || input === "d")) || key.escape) {
         onDone();
       }
     });

     return (
       <Box
         flexDirection="column"
         borderStyle="round"
         padding={1}
         borderColor={getTheme().secondaryBorder}
       >
         <Box marginBottom={1} flexDirection="column">
           <Text bold>You've spent $5 on the Anthropic API this session.</Text>
           <Text>Learn more about how to monitor your spending:</Text>
           <Link url="https://docs.anthropic.com/s/claude-code-cost" />
         </Box>
         <Box>
           <Select
             options={[
               {
                 value: "ok",
                 label: "Got it, thanks!",
               },
             ]}
             onChange={onDone}
           />
         </Box>
       </Box>
     );
   }
   ```

#### Technical Implementation Notes

The cost tracking system demonstrates several design considerations:

1. **Singleton State**: Uses a single state object with a clear comment warning against adding more state.

2. **Persistence Across Sessions**: Saves cost data to the project configuration, allowing for tracking across sessions.

3. **Formatting Flexibility**: Uses different decimal precision based on the cost amount (4 decimal places for small amounts, 2 for larger ones).

4. **Multiple Time Metrics**: Tracks both wall clock time and API request time separately.

5. **Environment-Aware Testing**: Includes a reset function that's only available in test environments.

6. **Exit Hooks**: Uses process exit hooks to ensure cost data is saved and displayed even if the application exits unexpectedly.

#### User Experience Considerations

The cost tracking system addresses several user needs:

1. **Transparency**: Provides clear visibility into API usage costs.

2. **Usage Monitoring**: Helps users track and manage their API spending.

3. **Efficiency Insights**: Shows both total runtime and API time, helping identify bottlenecks.

4. **Threshold Warnings**: Alerts users when they've spent significant amounts.

5. **Documentation Links**: Provides resources for learning more about cost management.

The `/cost` command and associated systems represent Claude Code's approach to transparent cost management, giving users control over their API usage while maintaining a simple, unobtrusive interface.

### onboarding Command

The `onboarding` command provides a guided first-run experience for new users, helping them configure Claude Code to their preferences and introducing them to the tool's capabilities.

#### Implementation

The command is implemented in `commands/onboarding.tsx` as a type: 'local-jsx' command that renders a React component:

```typescript
import * as React from "react";
import type { Command } from "../commands";
import { Onboarding } from "../components/Onboarding";
import { clearTerminal } from "../utils/terminal";
import { getGlobalConfig, saveGlobalConfig } from "../utils/config";
import { clearConversation } from "./clear";

export default {
  type: "local-jsx",
  name: "onboarding",
  description: "[ANT-ONLY] Run through the onboarding flow",
  isEnabled: true,
  isHidden: false,
  async call(onDone, context) {
    await clearTerminal();
    const config = getGlobalConfig();
    saveGlobalConfig({
      ...config,
      theme: "dark",
    });

    return (
      <Onboarding
        onDone={async () => {
          clearConversation(context);
          onDone();
        }}
      />
    );
  },
  userFacingName() {
    return "onboarding";
  },
} satisfies Command;
```

The command delegates to the `Onboarding` component in `components/Onboarding.tsx`, which handles the multi-step onboarding flow.

#### Functionality

The `onboarding` command implements a comprehensive first-run experience:

1. **Multi-Step Flow**:

   - Walks users through a series of configuration steps with a smooth, guided experience
   - Includes theme selection, usage guidance, and model selection
   - Uses a stack-based navigation system for intuitive flow between steps

2. **Theme Configuration**:

   - Allows users to choose between light and dark themes
   - Includes colorblind-friendly theme options for accessibility
   - Provides a live preview of the selected theme using a code diff example

3. **Usage Guidelines**:

   - Introduces users to effective ways of using Claude Code
   - Explains how to provide clear context and work with the tool
   - Sets appropriate expectations for the tool's capabilities

4. **Model Selection**:

   - Guides users through configuring AI provider and model settings
   - Uses the `ModelSelector` component for a consistent model selection experience
   - Allows configuration of both small and large models for different tasks

5. **Configuration Persistence**:
   - Saves user preferences to the global configuration
   - Marks onboarding as complete to prevent repeat runs
   - Clears the conversation after onboarding to provide a clean start

#### Technical Implementation Notes

The `onboarding` command demonstrates several sophisticated patterns:

1. **Screen Navigation Stack**: Implements a stack-based navigation system for multi-step flow:

   ```typescript
   const [screenStack, setScreenStack] = useState<
     Array<
       | "modelType"
       | "provider"
       | "apiKey"
       | "model"
       | "modelParams"
       | "confirmation"
     >
   >(["modelType"]);

   // Current screen is always the last item in the stack
   const currentScreen = screenStack[screenStack.length - 1];

   // Function to navigate to a new screen
   const navigateTo = (screen) => {
     setScreenStack((prev) => [...prev, screen]);
   };

   // Function to go back to the previous screen
   const goBack = () => {
     if (screenStack.length > 1) {
       setScreenStack((prev) => prev.slice(0, -1));
     } else {
       onDone();
     }
   };
   ```

2. **Progressive Disclosure**: Presents information in digestible chunks across multiple steps.

3. **Terminal UI Adaptation**: Uses Ink components optimized for terminal rendering:

   ```typescript
   <Box flexDirection="column" gap={1} paddingLeft={1}>
     <Text bold>Using {PRODUCT_NAME} effectively:</Text>
     <Box flexDirection="column" width={70}>
       <OrderedList>
         <OrderedList.Item>
           <Text>
             Start in your project directory
             <Newline />
             <Text color={theme.secondaryText}>
               Files are automatically added to context when needed.
             </Text>
             <Newline />
           </Text>
         </OrderedList.Item>
         {/* Additional list items */}
       </OrderedList>
     </Box>
     <PressEnterToContinue />
   </Box>
   ```

4. **Interactive Components**: Uses custom select components for theme selection with previews:

   ```typescript
   <Select
     options={[
       { label: "Light text", value: "dark" },
       { label: "Dark text", value: "light" },
       {
         label: "Light text (colorblind-friendly)",
         value: "dark-daltonized",
       },
       {
         label: "Dark text (colorblind-friendly)",
         value: "light-daltonized",
       },
     ]}
     onFocus={handleThemePreview}
     onChange={handleThemeSelection}
   />
   ```

5. **Exit Handling**: Implements `useExitOnCtrlCD` to provide users with a clear way to exit the flow:

   ```typescript
   const exitState = useExitOnCtrlCD(() => process.exit(0));
   ```

6. **Conditional Rendering**: Uses state to conditionally show different screens:
   ```typescript
   // If we're showing the model selector screen, render it directly
   if (showModelSelector) {
     return <ModelSelector onDone={handleModelSelectionDone} />;
   }
   ```

#### User Experience Benefits

The `onboarding` command addresses several key needs for new users:

1. **Guided Setup**: Provides a structured introduction to Claude Code rather than dropping users into a blank interface.

2. **Preference Customization**: Allows users to set their preferences immediately, increasing comfort with the tool.

3. **Learning Opportunity**: Teaches best practices for using the tool effectively from the start.

4. **Accessibility Awareness**: Explicitly offers colorblind-friendly themes, demonstrating attention to accessibility.

5. **Progressive Complexity**: Introduces features gradually, avoiding overwhelming new users.

The `onboarding` command exemplifies Claude Code's attention to user experience, ensuring new users can quickly set up the tool according to their preferences and learn how to use it effectively from the beginning.

### pr_comments Command

The `pr_comments` command provides a specialized interface for retrieving and displaying GitHub pull request comments, helping users review feedback on their code without leaving the terminal.

#### Implementation

The command is implemented in `commands/pr_comments.ts` as a type: 'prompt' command that formulates a specialized request to Claude:

```typescript
import { Command } from '../commands'

export default {
  type: 'prompt',
  name: 'pr-comments',
  description: 'Get comments from a GitHub pull request',
  progressMessage: 'fetching PR comments',
  isEnabled: true,
  isHidden: false,
  userFacingName() {
    return 'pr-comments'
  },
  async getPromptForCommand(args: string) {
    return [
      {
        role: 'user',
        content: [
          {
            type: 'text',
            text: `You are an AI assistant integrated into a git-based version control system. Your task is to fetch and display comments from a GitHub pull request.

Follow these steps:

1. Use \`gh pr view --json number,headRepository\` to get the PR number and repository info
2. Use \`gh api /repos/{owner}/{repo}/issues/{number}/comments\` to get PR-level comments
3. Use \`gh api /repos/{owner}/{repo}/pulls/{number}/comments\` to get review comments. Pay particular attention to the following fields: \`body\`, \`diff_hunk\`, \`path\`, \`line\`, etc. If the comment references some code, consider fetching it using eg \`gh api /repos/{owner}/{repo}/contents/{path}?ref={branch} | jq .content -r | base64 -d\`
4. Parse and format all comments in a readable way
5. Return ONLY the formatted comments, with no additional text

Format the comments as:

```
