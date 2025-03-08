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

