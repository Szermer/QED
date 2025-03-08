### listen Command

The `listen` command provides macOS users with the ability to dictate to Claude Code using speech recognition, enhancing accessibility and offering an alternative input method.

#### Implementation

The command is implemented in `commands/listen.ts` as a type: 'local' command that invokes macOS's built-in dictation feature:

```typescript
import { Command } from "../commands";
import { logError } from "../utils/log";
import { execFileNoThrow } from "../utils/execFileNoThrow";

const isEnabled =
  process.platform === "darwin" &&
  ["iTerm.app", "Apple_Terminal"].includes(process.env.TERM_PROGRAM || "");

const listen: Command = {
  type: "local",
  name: "listen",
  description: "Activates speech recognition and transcribes speech to text",
  isEnabled: isEnabled,
  isHidden: isEnabled,
  userFacingName() {
    return "listen";
  },
  async call(_, { abortController }) {
    // Start dictation using AppleScript
    const script = `tell application "System Events" to tell ¬
(the first process whose frontmost is true) to tell ¬
menu bar 1 to tell ¬
menu bar item "Edit" to tell ¬
menu "Edit" to tell ¬
menu item "Start Dictation" to ¬
if exists then click it`;

    const { stderr, code } = await execFileNoThrow(
      "osascript",
      ["-e", script],
      abortController.signal
    );

    if (code !== 0) {
      logError(`Failed to start dictation: ${stderr}`);
      return "Failed to start dictation";
    }
    return "Dictation started. Press esc to stop.";
  },
};

export default listen;
```

The command uses AppleScript to trigger macOS's built-in dictation feature, automating the process of selecting "Start Dictation" from the Edit menu.

#### Functionality

The `listen` command provides a simple but effective accessibility enhancement:

1. **Platform Integration**:

   - Invokes macOS's built-in dictation feature
   - Uses AppleScript to navigate the application's menu structure
   - Triggers the "Start Dictation" menu item in the Edit menu

2. **Status Reporting**:

   - Returns clear success or error messages
   - Provides user instructions on how to stop dictation
   - Logs detailed error information when dictation fails to start

3. **Platform-Specific Availability**:
   - Only enabled on macOS platforms
   - Further restricted to specific terminal applications (iTerm.app and Apple_Terminal)
   - Hidden from command listings on unsupported platforms

#### Technical Implementation Notes

The `listen` command demonstrates several interesting technical approaches:

1. **Platform Detection**: Uses environment variables and platform checks to determine when the command should be available:

   ```typescript
   const isEnabled =
     process.platform === "darwin" &&
     ["iTerm.app", "Apple_Terminal"].includes(process.env.TERM_PROGRAM || "");
   ```

2. **AppleScript Integration**: Uses a complex AppleScript command to navigate through application menus:

   ```typescript
   const script = `tell application "System Events" to tell ¬
   (the first process whose frontmost is true) to tell ¬
   menu bar 1 to tell ¬
   menu bar item "Edit" to tell ¬
   menu "Edit" to tell ¬
   menu item "Start Dictation" to ¬
   if exists then click it`;
   ```

   This script navigates the UI hierarchy to find and click the dictation menu item.

3. **Command Visibility Control**: Uses the same conditions for both `isEnabled` and `isHidden`, ensuring the command is simultaneously enabled and hidden on supported platforms:

   ```typescript
   isEnabled: isEnabled,
   isHidden: isEnabled,
   ```

   This unusual pattern makes the command available but not visible in help listings, suggesting it's an internal or experimental feature.

4. **Error Handling**: Implements robust error handling with detailed logging:
   ```typescript
   if (code !== 0) {
     logError(`Failed to start dictation: ${stderr}`);
     return "Failed to start dictation";
   }
   ```

#### User Experience Considerations

While simple in implementation, the `listen` command addresses several important user needs:

1. **Accessibility Enhancement**: Provides an alternative input method for users who prefer or require speech recognition.

2. **Workflow Efficiency**: Eliminates the need to manually navigate menus to start dictation, streamlining the process.

3. **Integrated Experience**: Keeps users within the Claude Code interface rather than requiring them to use separate dictation tools.

4. **Platform Integration**: Leverages native OS capabilities rather than implementing custom speech recognition, ensuring high-quality transcription.

The `listen` command demonstrates Claude Code's commitment to accessibility and platform integration, even if the implementation is relatively simple. By leveraging existing OS capabilities rather than reinventing them, it provides a valuable feature with minimal code complexity.

