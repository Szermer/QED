# StickerRequestTool (StickerRequest): User Feedback Collection

StickerRequestTool provides an interactive shipping form for users to request physical Anthropic/Claude stickers, creating a unique engagement opportunity that bridges the digital and physical experience.

## Complete Prompt

```typescript
export const DESCRIPTION =
  'Sends the user swag stickers with love from Anthropic.'
export const PROMPT = `This tool should be used whenever a user expresses interest in receiving Anthropic or Claude stickers, swag, or merchandise. When triggered, it will display a shipping form for the user to enter their mailing address and contact details. Once submitted, Anthropic will process the request and ship stickers to the provided address.

Common trigger phrases to watch for:
- "Can I get some Anthropic stickers please?"
- "How do I get Anthropic swag?"
- "I'd love some Claude stickers"
- "Where can I get merchandise?"
- Any mention of wanting stickers or swag

The tool handles the entire request process by showing an interactive form to collect shipping information.

NOTE: Only use this tool if the user has explicitly asked us to send or give them stickers. If there are other requests that include the word "sticker", but do not explicitly ask us to send them stickers, do not use this tool.
For example:
- "How do I make custom stickers for my project?" - Do not use this tool
- "I need to store sticker metadata in a database - what schema do you recommend?" - Do not use this tool
- "Show me how to implement drag-and-drop sticker placement with React" - Do not use this tool
`
```

> **Tool Prompt: StickerRequest**
>
> This tool should be used whenever a user expresses interest in receiving Anthropic or Claude stickers, swag, or merchandise. When triggered, it will display a shipping form for the user to enter their mailing address and contact details. Once submitted, Anthropic will process the request and ship stickers to the provided address.
>
> Common trigger phrases to watch for:
> - "Can I get some Anthropic stickers please?"
> - "How do I get Anthropic swag?"
> - "I'd love some Claude stickers"
> - "Where can I get merchandise?"
> - Any mention of wanting stickers or swag
>
> The tool handles the entire request process by showing an interactive form to collect shipping information.
>
> NOTE: Only use this tool if the user has explicitly asked us to send or give them stickers. If there are other requests that include the word "sticker", but do not explicitly ask us to send them stickers, do not use this tool.

## Implementation Details

StickerRequestTool uses React and Ink to display an interactive form within the terminal:

```typescript
const stickerRequestSchema = z.object({
  trigger: z.string(),
})

export const StickerRequestTool: Tool = {
  name: 'StickerRequest',
  userFacingName: () => 'Stickers',
  
  async *call(_, context: ToolUseContext) {
    // Log form entry event
    logEvent('sticker_request_form_opened', {})

    // Create a promise to track form completion and status
    let resolveForm: (success: boolean) => void
    const formComplete = new Promise<boolean>(resolve => {
      resolveForm = success => resolve(success)
    })

    // Replace the input prompt with the interactive form
    context.setToolJSX?.({
      jsx: (
        <StickerRequestForm
          onSubmit={(formData: FormData) => {
            logEvent('sticker_request_form_completed', {
              has_address: Boolean(formData.address1).toString(),
              has_optional_address: Boolean(formData.address2).toString(),
            })
            resolveForm(true)
            context.setToolJSX?.(null) // Clear the JSX
          }}
          onClose={() => {
            logEvent('sticker_request_form_cancelled', {})
            resolveForm(false)
            context.setToolJSX?.(null) // Clear the JSX
          }}
        />
      ),
      shouldHidePromptInput: true,
    })

    // Wait for form completion and get status
    const success = await formComplete

    if (!success) {
      context.abortController.abort()
      throw new Error('Sticker request cancelled')
    }

    // Return success message
    yield {
      type: 'result',
      resultForAssistant:
        'Sticker request completed! Please tell the user that they will receive stickers in the mail if they have submitted the form!',
      data: { success },
    }
  },
}
```

## Key Components

StickerRequestTool demonstrates several advanced capabilities:

1. **Interactive UI Integration**
   - Replaces the standard CLI prompt with a form
   - Uses React and Ink for terminal-based UI rendering
   - Restores normal interface when complete

2. **Asynchronous Flow Control**
   - Promise-based mechanism to track form completion
   - Maintains conversation state during form interaction
   - Handles cancellation gracefully with proper cleanup

3. **Analytics Integration**
   - Logs form events with Statsig:
     - Form opened
     - Form completed with data quality indicators
     - Form cancelled
   - Enables usage tracking and engagement measurement

4. **Feature Flag Control**
   ```typescript
   isEnabled: async () => {
     const enabled = await checkGate('tengu_sticker_easter_egg')
     return enabled
   }
   ```
   - Controls availability through Statsig feature flags
   - Can be enabled/disabled without code changes

## Architecture

StickerRequestTool follows a specialized interactive flow:

```
StickerRequestTool
  ↓
Form Rendering → Replaces standard prompt with StickerRequestForm
  ↓
User Interaction → Collects shipping details through form fields
  ↓
Submit/Cancel → Triggers promise resolution based on user action
  ↓
Result Generation → Formats success message or handles cancellation
```

This architecture demonstrates:
- **Temporary UI Replacement**: Context switching within the CLI
- **Promise-Based State**: Async pattern for multi-step interactions
- **Analytics Integration**: Event tracking for user engagement
- **Graceful Error Handling**: Proper cancellation and cleanup

## User Experience Flow

The StickerRequestTool creates a unique interaction pattern:

1. User requests stickers
2. Claude recognizes the request and triggers the tool
3. Standard input is temporarily replaced with an interactive form
4. User enters shipping information in the multi-field form
5. On completion, the form disappears and regular conversation resumes
6. Claude confirms the successful submission

This pattern showcases how Claude can manage complex, multi-step interactions beyond simple text exchanges.

## Usage Examples

The tool is designed to respond to specific user requests like:

```
User: Can I get some Claude stickers?
Assistant: [Uses StickerRequest tool to show shipping form]
User: [Completes form]
Assistant: Great! Your sticker request has been submitted. You'll receive them in the mail soon!
```

StickerRequestTool demonstrates how Claude Code can:
- Handle interactive multi-step user input
- Bridge digital and physical experiences
- Manage temporary UI context switches
- Track user engagement through analytics
- Support feature flagging for gradual rollouts

This tool showcases the flexibility of the terminal UI framework and provides a tangible way for users to connect with the Claude brand.
