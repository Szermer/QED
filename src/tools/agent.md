### AgentTool: Meta-Tool for Delegated Tasks

AgentTool functions as a meta-tool that launches autonomous sub-agents to perform specialized tasks.

#### Implementation

- Manages separate message thread and tool executions
- Supports launching multiple agents in parallel
- Follows generator pattern for real-time progress updates
- Implements clear permission boundaries for agents

#### Tool Delegation

- Filters available tools based on permission level
- Prevents recursive agent calls
- Restricts modification tools in read-only mode
- Maintains separate log chain for each agent

#### Execution Flow

1. Initializes with user message containing the prompt
2. Determines available tools based on permissions
3. Loads agent prompt, context, and model configurations
4. Queries Claude API with appropriate context
5. Processes messages and tool uses with progress tracking
6. Returns serialized text blocks as the agent's response

AgentTool showcases advanced architectural patterns for task delegation while maintaining security boundaries and detailed usage tracking.

