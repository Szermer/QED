# Feature Flag Integration

The codebase demonstrates a robust pattern for controlling feature availability using a feature flag system. This approach allows for gradual rollouts and experimental features.

## Implementation Pattern

```mermaid
flowchart TB
    Tool["Tool.isEnabled()"] -->|"Calls"| CheckGate["checkGate(gate_name)"]
    CheckGate -->|"Uses"| User["getUser()"]
    CheckGate -->|"Uses"| StatsigClient["StatsigClient"]
    StatsigClient -->|"Stores"| Storage["FileSystemStorageProvider"]
    User -->|"Provides"| UserContext["User Context\n- ID\n- Email\n- Platform\n- Session"]
    
    classDef primary fill:#f9f,stroke:#333,stroke-width:2px;
    classDef secondary fill:#bbf,stroke:#333,stroke-width:1px;
    
    class Tool,CheckGate primary;
    class User,StatsigClient,Storage,UserContext secondary;
```

The feature flag system follows this pattern:

1. **Flag Definition**: The `isEnabled()` method in each tool controls availability:

```typescript
async isEnabled() {
  // Tool-specific activation logic
  return Boolean(process.env.SOME_FLAG) && (await checkGate('gate_name'));
}
```

2. **Statsig Client**: The system uses Statsig for feature flags with these core functions:

```typescript
export const checkGate = memoize(async (gateName: string): Promise<boolean> => {
  // Gate checking logic - currently simplified
  return true;
  // Full implementation would initialize client and check actual flag value
})
```

3. **User Context**: Flag evaluation includes user context from `utils/user.ts`:

```typescript
export const getUser = memoize(async (): Promise<StatsigUser> => {
  const userID = getOrCreateUserID()
  // Collects user information including email, platform, session
  // ...
})
```

4. **Persistence**: Flag states are cached using a custom storage provider:

```typescript
export class FileSystemStorageProvider implements StorageProvider {
  // Stores Statsig data in ~/.claude/statsig/
  // ...
}
```

5. **Gate Pattern**: Many tools follow a pattern seen in ThinkTool:

```typescript
isEnabled: async () =>
  Boolean(process.env.THINK_TOOL) && (await checkGate('tengu_think_tool')),
```

## Benefits for Agentic Systems

```mermaid
graph TD
    FF[Feature Flags] --> SR[Staged Rollouts]
    FF --> AB[A/B Testing]
    FF --> AC[Access Control]
    FF --> RM[Resource Management]
    
    SR --> |Detect Issues Early| Safety[Safety]
    AB --> |Compare Implementations| Optimization[Optimization]
    AC --> |Restrict Features| Security[Security]
    RM --> |Control Resource Usage| Performance[Performance]
    
    classDef benefit fill:#90EE90,stroke:#006400,stroke-width:1px;
    classDef outcome fill:#ADD8E6,stroke:#00008B,stroke-width:1px;
    
    class FF,SR,AB,AC,RM benefit;
    class Safety,Optimization,Security,Performance outcome;
```

Feature flags provide several practical benefits for agentic systems:

- **Staged Rollouts**: Gradually release features to detect issues before wide deployment
- **A/B Testing**: Compare different implementations of the same feature
- **Access Control**: Restrict experimental features to specific users or environments
- **Resource Management**: Selectively enable resource-intensive features

## Feature Flag Standards

For implementing feature flags in your own agentic system, consider [OpenFeature](https://openfeature.dev/), which provides a standardized API with implementations across multiple languages.

## Usage in the Codebase

```mermaid
flowchart LR
    FeatureFlags[Feature Flags] --> Tools[Tool Availability]
    FeatureFlags --> Variants[Feature Variants]
    FeatureFlags --> Models[Model Behavior]
    FeatureFlags --> UI[UI Components]
    
    Tools --> ToolSystem[Tool System]
    Variants --> SystemBehavior[System Behavior]
    Models --> APIRequests[API Requests]
    UI --> UserExperience[User Experience]
    
    classDef flag fill:#FFA07A,stroke:#FF6347,stroke-width:2px;
    classDef target fill:#87CEFA,stroke:#1E90FF,stroke-width:1px;
    classDef effect fill:#98FB98,stroke:#228B22,stroke-width:1px;
    
    class FeatureFlags flag;
    class Tools,Variants,Models,UI target;
    class ToolSystem,SystemBehavior,APIRequests,UserExperience effect;
```

Throughout the codebase, feature flags control:

- **Tool availability** (through each tool's `isEnabled()` method)
- **Feature variants** (via experiment configuration)
- **Model behavior** (through beta headers and capabilities)
- **UI components** (conditionally rendering based on flag state)

This creates a flexible system where capabilities can be adjusted without code changes, making it ideal for evolving agentic systems.