### BashTool: Command Execution

BashTool executes bash commands in a persistent shell session, providing Claude with access to the terminal.

#### Implementation

- Uses a PersistentShell singleton for command execution
- Enforces strict security boundaries with banned command list
- Manages comprehensive permission system for command approval
- Detailed output handling with truncation for large results

#### Security Mechanisms

- Command validation against banned list (curl, wget, browsers, etc.)
- Permission system with risk-score approach
- Sanitization of output and command display
- Prevention of directory traversal outside working directory

#### Permission Architecture

The permission system is particularly robust:

- Dedicated BashPermissionRequest component for approval UI
- Three permission options: temporary, prefix-based, or exact command
- Permission persistence for approved command patterns
- Analytics logging of permission requests

BashTool demonstrates the balance between power and security in Claude Code. It gives Claude access to the full capabilities of the shell while implementing guards against potential misuse.

