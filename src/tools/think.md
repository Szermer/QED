### ThinkTool: Structured Reasoning

ThinkTool provides Claude with a mechanism to externalize its reasoning process, making complex thinking visible to users.

#### Implementation

- Simple schema with single "thought" string parameter
- Special rendering as AssistantThinkingMessage
- No permissions required (marked as read-only)
- Conditionally enabled via feature flags

#### Integration

ThinkTool is special-cased in the UI rendering system, displaying its output as a distinct thinking message rather than standard tool output. This creates a visual distinction between Claude's reasoning process and its actual actions.

