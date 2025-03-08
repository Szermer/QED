## System Architecture Diagram

Claude Code solves a core challenge: making an AI coding assistant responsive while handling complex operations. It's not just an API wrapper but a system where components work together for a natural coding experience.

<div class="info-box">
<strong>🏗️ Architectural Philosophy:</strong> A system designed for real-time interaction with large codebases where each component handles a specific responsibility within a consistent information flow.
</div>

### High-Level Architecture Overview

The diagram below illustrates the core architecture of Claude Code, organized into four key domains that show how information flows through the system:

1. **User-Facing Layer**: Where you interact with the system
2. **Conversation Management**: Handles the flow of messages and maintains context
3. **Claude AI Integration**: Connects with Claude's intelligence capabilities
4. **External World Interaction**: Allows Claude to interact with files and your environment

This organization shows the journey of a user request: starting from the user interface, moving through conversation management to Claude's AI, then interacting with the external world if needed, and finally returning results back up the chain.

```mermaid
flowchart TB
    %% Define the main components
    UI[User Interface] --> MSG[Message Processing]
    MSG --> QRY[Query System]
    QRY --> API[API Integration]
    API --> TOOL[Tool System]
    TOOL --> PAR[Parallel Execution]
    PAR --> API
    API --> MSG
    
    %% Group components into domains
    subgraph "User-Facing Layer"
        UI
    end
    
    subgraph "Conversation Management"
        MSG
        QRY
    end
    
    subgraph "Claude AI Integration"
        API
    end
    
    subgraph "External World Interaction"
        TOOL
        PAR
    end
    
    %% Distinct styling for each component
    classDef uiStyle fill:#d9f7be,stroke:#389e0d,stroke-width:2px
    classDef msgStyle fill:#d6e4ff,stroke:#1d39c4,stroke-width:2px
    classDef queryStyle fill:#fff1b8,stroke:#d48806,stroke-width:2px
    classDef apiStyle fill:#ffd6e7,stroke:#c41d7f,stroke-width:2px
    classDef toolStyle fill:#fff2e8,stroke:#d4380d,stroke-width:2px
    classDef parStyle fill:#f5f5f5,stroke:#434343,stroke-width:2px
    
    %% Apply styles to components
    class UI uiStyle
    class MSG msgStyle
    class QRY queryStyle
    class API apiStyle
    class TOOL toolStyle
    class PAR parStyle
```

## Key Components

Each component handles a specific job in the architecture. Let's look at them individually before seeing how they work together. For detailed implementation of these components, see the [Core Architecture](./core-architecture.md) page.

### User Interface Layer

The UI layer manages what you see and how you interact with Claude Code in the terminal.

```mermaid
flowchart TB
    UI_Input["PromptInput.tsx\nUser Input Capture"]
    UI_Messages["Message Components\nText, Tool Use, Results"]
    UI_REPL["REPL.tsx\nMain UI Loop"]
    
    UI_Input --> UI_REPL
    UI_REPL --> UI_Messages
    UI_Messages --> UI_REPL
    
    classDef UI fill:#d9f7be,stroke:#389e0d
    class UI_Input,UI_Messages,UI_REPL UI
```

Built with React and Ink for rich terminal interactions, the UI's key innovation is its streaming capability. Instead of waiting for complete answers, it renders partial responses as they arrive.

- **PromptInput.tsx** - Captures user input with history navigation and command recognition
- **Message Components** - Renders text, code blocks, tool outputs, and errors
- **REPL.tsx** - Maintains conversation state and orchestrates the interaction loop

### Message Processing

This layer takes raw user input and turns it into something the system can work with.

```mermaid
flowchart TB
    MSG_Process["processUserInput()\nCommand Detection"]
    MSG_Format["Message Normalization"]
    MSG_State["messages.ts\nMessage State"]
    
    MSG_Process --> MSG_Format
    MSG_Format --> MSG_State
    
    classDef MSG fill:#d6e4ff,stroke:#1d39c4
    class MSG_Process,MSG_Format,MSG_State MSG
```

Before generating responses, the system needs to understand and route user input:

- **processUserInput()** - Routes input by distinguishing between regular prompts, slash commands (/), and bash commands (!)
- **Message Normalization** - Converts different message formats into consistent structures
- **messages.ts** - Manages message state throughout the conversation history

### Query System

The query system is the brain of Claude Code, coordinating everything from user input to AI responses.

```mermaid
flowchart TB
    QRY_Main["query.ts\nMain Query Logic"]
    QRY_Format["Message Formatting"]
    QRY_Generator["async generators\nStreaming Results"]
    
    QRY_Main --> QRY_Format
    QRY_Format --> QRY_Generator
    
    classDef QRY fill:#fff1b8,stroke:#d48806
    class QRY_Main,QRY_Format,QRY_Generator QRY
```

<div class="warning-box">
<strong>🔑 Critical Path:</strong> The query.ts file contains the essential logic that powers conversational capabilities, coordinating between user input, AI processing, and tool execution.
</div>

- **query.ts** - Implements the main query generator orchestrating conversation flow
- **Message Formatting** - Prepares API-compatible messages with appropriate context
- **Async Generators** - Enable token-by-token streaming for immediate feedback

### Tool System

The tool system lets Claude interact with your environment - reading files, running commands, and making changes.

```mermaid
flowchart TB
    TOOL_Manager["Tool Management"]
    TOOL_Permission["Permission System"]
    
    subgraph "Read-Only Tools"
        TOOL_Glob["GlobTool\nFile Pattern Matching"]
        TOOL_Grep["GrepTool\nContent Searching"]
        TOOL_View["View\nFile Reading"]
        TOOL_LS["LS\nDirectory Listing"]
    end

    subgraph "Non-Read-Only Tools"
        TOOL_Edit["Edit\nFile Modification"]
        TOOL_Bash["Bash\nCommand Execution"]
        TOOL_Write["Replace\nFile Writing"]
    end

    TOOL_Manager --> TOOL_Permission
    TOOL_Permission --> Read-Only-Tools
    TOOL_Permission --> Non-Read-Only-Tools
    
    classDef TOOL fill:#fff2e8,stroke:#d4380d
    class TOOL_Manager,TOOL_Glob,TOOL_Grep,TOOL_View,TOOL_LS,TOOL_Edit,TOOL_Bash,TOOL_Write,TOOL_Permission TOOL
```

This system is what separates Claude Code from other coding assistants. Instead of just talking about code, Claude can directly interact with it:

- **Tool Management** - Registers and manages available tools
- **Read-Only Tools** - Safe operations that don't modify state (GlobTool, GrepTool, View, LS)
- **Non-Read-Only Tools** - Operations that modify files or execute commands (Edit, Bash, Replace)
- **Permission System** - Enforces security boundaries between tool capabilities

### API Integration

This component handles communication with Claude's API endpoints to get language processing capabilities.

```mermaid
flowchart TB
    API_Claude["services/claude.ts\nAPI Client"]
    API_Format["Request/Response Formatting"]
    
    API_Claude --> API_Format
    
    classDef API fill:#ffd6e7,stroke:#c41d7f
    class API_Claude,API_Format API
```

- **services/claude.ts** - Manages API connections, authentication, and error handling
- **Request/Response Formatting** - Transforms internal message formats to/from API structures

### Parallel Execution

One of Claude Code's key performance features is its ability to run operations concurrently rather than one at a time.

```mermaid
flowchart TB
    PAR_Check["Read-Only Check"]
    PAR_Concurrent["runToolsConcurrently()"]
    PAR_Serial["runToolsSerially()"]
    PAR_Generator["generators.all()\nConcurrency Control"]
    PAR_Sort["Result Sorting"]
    
    PAR_Check -->|"All Read-Only"| PAR_Concurrent
    PAR_Check -->|"Any Non-Read-Only"| PAR_Serial
    PAR_Concurrent & PAR_Serial --> PAR_Generator
    PAR_Generator --> PAR_Sort
    
    classDef PAR fill:#f5f5f5,stroke:#434343
    class PAR_Check,PAR_Concurrent,PAR_Serial,PAR_Generator,PAR_Sort PAR
```

<div class="info-box">
<strong>🔍 Performance Pattern:</strong> When searching codebases, the system examines multiple files simultaneously rather than sequentially, dramatically improving response time.
</div>

- **Read-Only Check** - Determines if requested tools can safely run in parallel
- **runToolsConcurrently()** - Executes compatible tools simultaneously
- **runToolsSerially()** - Executes tools sequentially when order matters or safety requires it
- **generators.all()** - Core utility managing multiple concurrent async generators
- **Result Sorting** - Ensures consistent ordering regardless of execution timing

## Integrated Data Flow

Now that we've seen each component, here's how they all work together in practice, with the domains clearly labeled:

```mermaid
flowchart TB
    User([Human User]) -->|Types request| UI
    
    subgraph "User-Facing Layer"
        UI -->|Shows results| User
    end
    
    subgraph "Conversation Management"
        UI -->|Processes input| MSG
        MSG -->|Maintains context| QRY
        QRY -->|Returns response| MSG
        MSG -->|Displays output| UI
    end
    
    subgraph "Claude AI Integration"
        QRY -->|Sends request| API
        API -->|Returns response| QRY
    end
    
    subgraph "External World Interaction"
        API -->|Requests tool use| TOOL
        TOOL -->|Runs operations| PAR
        PAR -->|Returns results| TOOL
        TOOL -->|Provides results| API
    end
    
    classDef system fill:#f9f9f9,stroke:#333333
    classDef external fill:#e6f7ff,stroke:#1890ff,stroke-width:2px
    class UI,MSG,QRY,API,TOOL,PAR system
    class User external
```

This diagram shows four key interaction patterns:

1. **Human-System Loop**: You type a request, and Claude Code processes it and shows results
   * _Example: You ask "How does this code work?" and get an explanation_

2. **AI Consultation**: Your request gets sent to Claude for analysis
   * _Example: Claude analyzes code structure and identifies design patterns_

3. **Environment Interaction**: Claude uses tools to interact with your files and system
   * _Example: Claude searches for relevant files, reads them, and makes changes_

4. **Feedback Cycle**: Results from tools feed back into Claude's thinking
   * _Example: After reading a file, Claude refines its explanation based on what it found_

What makes Claude Code powerful is that these patterns work together seamlessly. Instead of just chatting about code, Claude can actively explore, understand, and modify it in real-time.