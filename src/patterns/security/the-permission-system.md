## The Permission System

The permission system forms a crucial security layer through a three-part model:

1. **Request**: Tools indicate what permissions they need via `needsPermissions()`
2. **Dialog**: Users see explicit permission requests with context via `PermissionRequest` components
3. **Persistence**: Approved permissions can be saved for future use via `savePermission()`

### Implementation in TypeScript

Here's how this works in practice:

```typescript
// Tool requesting permissions
const EditTool: Tool = {
  name: "Edit",
  /* other properties */
  
  // Each tool decides when it needs permission
  needsPermissions: (input: EditParams): boolean => {
    const { file_path } = input;
    return !hasPermissionForPath(file_path, "write");
  },
  
  async *call(input: EditParams, context: ToolContext) {
    const { file_path, old_string, new_string } = input;
    
    // Access will be automatically checked by the framework
    // If permission is needed but not granted, this code won't run
    
    // Perform the edit operation...
    const result = await modifyFile(file_path, old_string, new_string);
    yield { success: true, message: `Modified ${file_path}` };
  }
};

// Permission system implementation
function hasPermissionForPath(path: string, access: "read" | "write"): boolean {
  // Check cached permissions first
  const permissions = getPermissions();
  
  // Try to match permissions with path prefix
  for (const perm of permissions) {
    if (
      perm.type === "path" && 
      perm.access === access &&
      path.startsWith(perm.path)
    ) {
      return true;
    }
  }
  
  return false;
}

// Rendering permission requests to the user
function PermissionRequest({ 
  tool, 
  params,
  onApprove, 
  onDeny 
}: PermissionProps) {
  return (
    <Box flexDirection="column" borderStyle="round" padding={1}>
      <Text>Claude wants to use {tool.name} to modify</Text>
      <Text bold>{params.file_path}</Text>
      
      <Box marginTop={1}>
        <Button onPress={() => {
          // Save permission for future use
          savePermission({
            type: "path",
            path: params.file_path,
            access: "write",
            permanent: true 
          });
          onApprove();
        }}>
          Allow
        </Button>
        
        <Box marginLeft={2}>
          <Button onPress={onDeny}>Deny</Button>
        </Box>
      </Box>
    </Box>
  );
}
```

The system has specialized handling for different permission types:

- **Tool Permissions**: General permissions for using specific tools
- **Bash Command Permissions**: Fine-grained control over shell commands 
- **Filesystem Permissions**: Separate read/write permissions for directories

### Path-Based Permission Model

For filesystem operations, directory permissions cascade to child paths, reducing permission fatigue while maintaining security boundaries:

```typescript
// Parent directory permissions cascade to children
if (hasPermissionForPath("/home/user/project", "write")) {
  // These will automatically be allowed without additional prompts
  editFile("/home/user/project/src/main.ts");
  createFile("/home/user/project/src/utils/helpers.ts");
  deleteFile("/home/user/project/tests/old-test.js");
}

// But operations outside that directory still need approval
editFile("/home/user/other-project/config.js"); // Will prompt for permission
```

This pattern balances security with usability - users don't need to approve every single file operation, but still maintain control over which directories an agent can access.

### Security Measures

Additional security features include:

- **Command injection detection**: Analyzes shell commands for suspicious patterns
- **Path normalization**: Prevents path traversal attacks by normalizing paths before checks
- **Risk scoring**: Assigns risk levels to operations based on their potential impact
- **Safe commands list**: Pre-approves common dev operations (ls, git status, etc.)

The permission system is the primary safety mechanism that lets users confidently interact with an AI that has direct access to their filesystem and terminal.

