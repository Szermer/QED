# BashTool: Command Execution

BashTool runs commands in a persistent shell session. It maintains state between commands and has security measures to keep things safe while still being useful.

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

## How It Works

The BashTool has a few key parts:

1. **PersistentShell**
   - Keeps one shell session running throughout your conversation
   - Remembers working directory and environment variables
   - Sets up a proper interactive shell
   - Handles command timeouts

2. **Security**
   - Blocks potentially dangerous commands
   - Keeps operations within your project directories
   - Validates commands before running them
   - Checks shell syntax validity

3. **Permission System**
   - Three approval levels:
     - One-time (temporary)
     - Pattern-based (like all `git` commands)
     - Exact command matches
   - Evaluates command risk levels
   - Explains what commands do in plain language

4. **Output Handling**
   - Manages stdout and stderr
   - Handles output truncation for large results
   - Processes multi-line commands
   - Preserves special formatting

5. **Command Management**
   - Runs commands sequentially
   - Handles timeouts
   - Tracks exit codes
   - Cleans up processes and temporary files

## Under the Hood

BashTool is built in layers:

```
BashTool.tsx (Interface)
  ↓
PersistentShell (Core)
  ↓
Node child_process (Execution)
```

When you run a command, it goes through these steps:

1. **Setup**
   - Initializes the shell
   - Creates temp files for output
   - Loads configurations
   - Sets up environment

2. **Validation**
   - Checks against banned commands
   - Ensures `cd` commands stay within bounds
   - Validates shell syntax
   - Determines required permissions

3. **Execution**
   - Runs commands in order
   - Captures output
   - Monitors for completion or timeout
   - Handles interruptions

4. **Processing**
   - Reads output files
   - Formats and truncates if needed
   - Reports errors
   - Preserves shell state

5. **Cleanup**
   - Terminates processes if needed
   - Updates timestamps
   - Returns results
   - Clears buffers

## Permissions

BashTool always requires permission:

```typescript
needsPermissions(): boolean {
  // Always check permissions for Bash
  return true
}
```

Unlike other tools that might skip permission checks, BashTool always asks.

The permission system offers three options:

1. **Temporary**
   - Just for this one command
   - Doesn't persist between sessions
   - Good for one-off commands

2. **Prefix**
   - Allows all commands with a common prefix
   - Example: approve all `git` commands with one permission
   - Persists between sessions

3. **Full Command**
   - Approves only that exact command
   - Most restrictive option
   - Persists between sessions

The system tracks what gets approved or denied to help improve the tool.

## Examples

Here's how to use BashTool for common tasks:

1. **Environment Info**
```typescript
Bash({ command: "pwd" })
Bash({ command: "env | grep PATH" })
```

2. **Project Tasks**
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

5. **Multi-step Commands**
```typescript
Bash({ command: "export NODE_ENV=production && npm run build && node ./scripts/post-build.js" })
```

BashTool lets Claude execute terminal commands safely. It handles everything from simple file operations to complex build pipelines while keeping security guardrails in place.

