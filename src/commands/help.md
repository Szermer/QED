### help Command

The `help` command provides users with information about Claude Code's usage, available commands, and general guidance for effective interaction with the tool.

#### Implementation

The command is implemented in `commands/help.tsx` as a type: 'local-jsx' command that renders a React component:

```typescript
import { Command } from "../commands";
import { Help } from "../components/Help";
import * as React from "react";

const help = {
  type: "local-jsx",
  name: "help",
  description: "Show help and available commands",
  isEnabled: true,
  isHidden: false,
  async call(onDone, { options: { commands } }) {
    return <Help commands={commands} onClose={onDone} />;
  },
  userFacingName() {
    return "help";
  },
} satisfies Command;

export default help;
```

The command delegates to the `Help` component in `components/Help.tsx`, passing the list of available commands and an `onClose` callback to handle when the help screen should be dismissed.

#### Functionality

The `Help` component implements a progressive disclosure pattern for displaying information:

1. **Basic Information**:

   - Shows the product name and version
   - Displays a brief description of Claude Code's capabilities and limitations
   - Presents a disclaimer about the beta nature of the product

2. **Usage Modes** (shown after a brief delay):

   - Explains the two primary ways to use Claude Code:
     - REPL (interactive session)
     - Non-interactive mode with the `-p` flag for one-off questions
   - Mentions that users can run `claude -h` for additional command-line options

3. **Common Tasks** (shown after a longer delay):

   - Lists examples of typical use cases:
     - Asking questions about the codebase
     - Editing files
     - Fixing errors
     - Running commands
     - Running bash commands

4. **Available Commands** (shown after the longest delay):

   - Displays a comprehensive list of all enabled slash commands
   - Shows command names and descriptions
   - Filters out hidden commands

5. **Additional Resources**:
   - Provides links for getting more help
   - Shows different resources based on user type (internal vs. external)

#### Technical Implementation Notes

The `help` command demonstrates several effective patterns:

1. **Progressive Disclosure**: Uses a time-based mechanism to gradually reveal information:

   ```typescript
   const [count, setCount] = React.useState(0);

   React.useEffect(() => {
     const timer = setTimeout(() => {
       if (count < 3) {
         setCount(count + 1);
       }
     }, 250);

     return () => clearTimeout(timer);
   }, [count]);
   ```

   This approach avoids overwhelming users with too much information at once, showing more details as they spend time on the help screen.

2. **Filtering System**: Uses `filter` to show only non-hidden commands:

   ```typescript
   const filteredCommands = commands.filter((cmd) => !cmd.isHidden);
   ```

   This keeps the help screen focused on commands relevant to users.

3. **Dynamic Resource Links**: Changes help resources based on user type:

   ```typescript
   const isInternal = process.env.USER_TYPE === "ant";
   const moreHelp = isInternal
     ? "[ANT-ONLY] For more help: go/claude-cli or #claude-cli-feedback"
     : `Learn more at: ${MACRO.README_URL}`;
   ```

   This customizes the experience for different user populations.

4. **Input Handling**: Uses Ink's `useInput` hook to detect when the user presses Enter:

   ```typescript
   useInput((_, key) => {
     if (key.return) onClose();
   });
   ```

   This allows for clean dismissal of the help screen.

5. **Conditional Rendering**: Uses the `count` state to progressively show different sections:
   ```typescript
   {
     count >= 1 && (
       <Box flexDirection="column" marginTop={1}>
         <Text bold>Usage Modes:</Text>
         {/* Usage content */}
       </Box>
     );
   }
   ```
   This creates the staggered reveal effect for information groups.

#### User Experience Benefits

The `help` command addresses several important needs for CLI tool users:

1. **Onboarding Assistance**: Provides new users with immediate guidance on how to use the tool effectively.

2. **Command Discovery**: Makes it easy to see what slash commands are available without having to memorize them.

3. **Progressive Learning**: The staggered reveal of information allows users to absorb basics first before seeing more advanced options.

4. **Usage Examples**: Shows concrete examples of common use cases, helping users understand practical applications.

5. **Quick Reference**: Serves as a compact reference for command options during regular use.

The help command exemplifies Claude Code's approach to user experience: it's focused on being informative while remaining concise and unobtrusive, with multiple levels of detail available as users need them.

