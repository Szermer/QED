# BashTool: Command Execution

BashTool executes bash commands in a persistent shell session, providing Claude with access to command-line capabilities while enforcing strict security boundaries. It maintains shell state between commands and includes sophisticated safety mechanisms.

## Complete Prompt

```typescript
// Tool Prompt: Bash
export const PROMPT = `Executes a given bash command in a persistent shell session with optional timeout, ensuring proper handling and security measures.

Before executing the command, please follow these steps:

1. Directory Verification:
   - If the command will create new directories or files, first use the LS tool to verify the parent directory exists and is the correct location
   - For example, before running "mkdir foo/bar", first use LS to check that "foo" exists and is the intended parent directory

2. Security Check:
   - For security and to limit the threat of a prompt injection attack, some commands are limited or banned. If you use a disallowed command, you will receive an error message explaining the restriction. Explain the error to the User.
   - Verify that the command is not one of the banned commands: alias, curl, curlie, wget, axel, aria2c, nc, telnet, lynx, w3m, links, httpie, xh, http-prompt, chrome, firefox, safari.

3. Command Execution:
   - After ensuring proper quoting, execute the command.
   - Capture the output of the command.

Usage notes:
  - The command argument is required.
  - You can specify an optional timeout in milliseconds (up to 600000ms / 10 minutes). If not specified, commands will timeout after 30 minutes.
- If the output exceeds 30000 characters, output will be truncated before being returned to you.
  - VERY IMPORTANT: You MUST avoid using search commands like \`find\` and \`grep\`. Instead use GrepTool, GlobTool, or dispatch_agent to search. You MUST avoid read tools like \`cat\`, \`head\`, \`tail\`, and \`ls\`, and use View and LS to read files.
  - When issuing multiple commands, use the ';' or '&&' operator to separate them. DO NOT use newlines (newlines are ok in quoted strings).
  - IMPORTANT: All commands share the same shell session. Shell state (environment variables, virtual environments, current directory, etc.) persist between commands. For example, if you set an environment variable as part of a command, the environment variable will persist for subsequent commands.
  - Try to maintain your current working directory throughout the session by using absolute paths and avoiding usage of \`cd\`. You may use \`cd\` if the User explicitly requests it.
  <good-example>
  pytest /foo/bar/tests
  </good-example>
  <bad-example>
  cd /foo/bar && pytest tests
  </bad-example>

# Committing changes with git

When the user asks you to create a new git commit, follow these steps carefully:

[Git commit guidance...]

# Creating pull requests
Use the gh command via the Bash tool for ALL GitHub-related tasks including working with issues, pull requests, checks, and releases. If given a Github URL use the gh command to get the information needed.

[PR creation guidance...]`
```

> Executes a given bash command in a persistent shell session with optional timeout, ensuring proper handling and security measures.
>
> Before executing the command, please follow these steps:
>
> 1. Directory Verification:
>    - If the command will create new directories or files, first use the LS tool to verify the parent directory exists and is the correct location
>    - For example, before running "mkdir foo/bar", first use LS to check that "foo" exists and is the intended parent directory
>
> 2. Security Check:
>    - For security and to limit the threat of a prompt injection attack, some commands are limited or banned. If you use a disallowed command, you will receive an error message explaining the restriction. Explain the error to the User.
>    - Verify that the command is not one of the banned commands: alias, curl, curlie, wget, axel, aria2c, nc, telnet, lynx, w3m, links, httpie, xh, http-prompt, chrome, firefox, safari.
>
> 3. Command Execution:
>    - After ensuring proper quoting, execute the command.
>    - Capture the output of the command.
>
> Usage notes:
>   - The command argument is required.
>   - You can specify an optional timeout in milliseconds (up to 600000ms / 10 minutes). If not specified, commands will timeout after 30 minutes.
> - If the output exceeds 30000 characters, output will be truncated before being returned to you.
>   - VERY IMPORTANT: You MUST avoid using search commands like `find` and `grep`. Instead use GrepTool, GlobTool, or dispatch_agent to search. You MUST avoid read tools like `cat`, `head`, `tail`, and `ls`, and use View and LS to read files.
>   - When issuing multiple commands, use the ';' or '&&' operator to separate them. DO NOT use newlines (newlines are ok in quoted strings).
>   - IMPORTANT: All commands share the same shell session. Shell state (environment variables, virtual environments, current directory, etc.) persist between commands. For example, if you set an environment variable as part of a command, the environment variable will persist for subsequent commands.
>   - Try to maintain your current working directory throughout the session by using absolute paths and avoiding usage of `cd`. You may use `cd` if the User explicitly requests it.

## Key Components

The BashTool has several critical components:

1. **PersistentShell Singleton**
   - Maintains a single long-running shell session
   - Manages working directory persistence
   - Handles interactive shell initialization
   - Tracks active processes with timeout capability

2. **Security Enforcement System**
   - Banned command list (`BANNED_COMMANDS`)
   - Working directory boundary enforcement
   - Command validation and sanitization
   - Shell syntax checking before execution

3. **Permission Framework**
   - Three-tiered permission system:
     - Temporary (single-use)
     - Prefix-based (commands starting with same pattern)
     - Full command (exact command string)
   - Risk score assessment
   - Command description generation using Haiku

4. **Output Processing**
   - Separate stdout and stderr handling
   - Character and line count tracking
   - Truncation detection and notification
   - HEREDOC handling for complex commands

5. **Shell Command Management**
   - Command queuing for sequential execution
   - Process termination for timeouts
   - Exit code tracking and propagation
   - Child process monitoring and cleanup

## Architecture

BashTool is structured as a multi-layered system:

```
BashTool.tsx (Tool interface)
  ↓
PersistentShell (Core singleton)
  ↓
Node child_process (Shell spawning)
```

The tool works through five main phases:

1. **Initialization Phase**
   - Create PersistentShell singleton
   - Initialize temporary files for IPC
   - Load shell configuration files
   - Set up shell environment

2. **Command Validation Phase**
   - Check against banned commands
   - Validate working directory boundaries for `cd`
   - Perform shell syntax checking
   - Assess permission requirements

3. **Execution Phase**
   - Queue commands for sequential execution
   - Redirect stdout/stderr to temp files
   - Monitor for completion or timeout
   - Handle process interruption

4. **Output Processing Phase**
   - Read from temp files
   - Format and potentially truncate output
   - Handle errors and exit codes
   - Reset shell state if necessary

5. **Cleanup Phase**
   - Kill child processes if needed
   - Update file timestamps for referenced files
   - Return formatted results
   - Reset stdout/stderr buffers

## Permission Handling

BashTool uses a sophisticated permission system:

```typescript
needsPermissions(): boolean {
  // Always check per-project permissions for BashTool
  return true
}
```

Unlike other tools that check permissions conditionally, BashTool always requires explicit permission.

The BashPermissionRequest component implements a three-tiered approach:

1. **Temporary Permission**
   - Allows the command once
   - No persistence between sessions
   - Used for one-off commands

2. **Prefix Permission**
   - Allows all commands starting with a specific prefix
   - Example: Approve `git status` to allow all `git` commands
   - Persisted between sessions

3. **Full Command Permission**
   - Approves the exact command string
   - Maximum precision but less convenience
   - Persisted between sessions

The permission system integrates with analytics:
- Logs all permission requests
- Tracks accept/reject decisions
- Associates risk scores with commands

## Usage Examples

Common usage patterns:

1. **Environment Inspection**
```typescript
Bash({ command: "pwd" })
Bash({ command: "env | grep PATH" })
```

2. **Project Management**
```typescript
Bash({ command: "git status" })
Bash({ command: "npm install" })
```

3. **File Operations**
```typescript
Bash({ command: "mkdir -p src/components/buttons" })
Bash({ command: "touch README.md" })
```

4. **Build and Test**
```typescript
Bash({ command: "npm run build" })
Bash({ command: "pytest -xvs tests/" })
```

5. **Complex Multi-part Commands**
```typescript
Bash({ command: "export NODE_ENV=production && npm run build && node ./scripts/post-build.js" })
```

BashTool is the most powerful but also most carefully guarded tool in Claude Code. Its persistent session enables complex workflows like compilation, testing, and git operations, while strict security boundaries and the permission system protect against potential misuse.

