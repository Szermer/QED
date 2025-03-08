### StickerRequestTool: User Engagement

StickerRequestTool provides an interactive form for users to request physical Anthropic/Claude stickers.

#### Implementation

- Interactive form rendering within the CLI interface
- Promise-based mechanism to track form completion
- Analytics integration via Statsig for user engagement tracking
- Feature flag control ('tengu_sticker_easter_egg')

#### User Experience

- Temporarily replaces the prompt input with an interactive form
- Handles form cancellation gracefully
- Provides custom rendering for rejection messages
- Logs various events through Statsig for analytics

StickerRequestTool demonstrates how Claude Code can handle interactive multi-step user input beyond simple text prompts, showcasing the flexibility of the terminal UI framework.
