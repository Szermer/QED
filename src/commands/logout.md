### logout Command

The `logout` command provides users with the ability to sign out from their Anthropic account, removing stored authentication credentials and API keys from the local configuration.

#### Implementation

The command is implemented in `commands/logout.tsx` as a type: 'local-jsx' command that handles the logout process and renders a confirmation message:

```typescript
import * as React from "react";
import type { Command } from "../commands";
import { getGlobalConfig, saveGlobalConfig } from "../utils/config";
import { clearTerminal } from "../utils/terminal";
import { Text } from "ink";

export default {
  type: "local-jsx",
  name: "logout",
  description: "Sign out from your Anthropic account",
  isEnabled: true,
  isHidden: false,
  async call() {
    await clearTerminal();

    const config = getGlobalConfig();

    config.oauthAccount = undefined;
    config.primaryApiKey = undefined;
    config.hasCompletedOnboarding = false;

    if (config.customApiKeyResponses?.approved) {
      config.customApiKeyResponses.approved = [];
    }

    saveGlobalConfig(config);

    const message = (
      <Text>Successfully logged out from your Anthropic account.</Text>
    );

    setTimeout(() => {
      process.exit(0);
    }, 200);

    return message;
  },
  userFacingName() {
    return "logout";
  },
} satisfies Command;
```

Unlike the more complex `login` command, the `logout` command is relatively straightforward, focusing on removing authentication data from the configuration and providing a clean exit.

#### Functionality

The `logout` command performs several critical operations:

1. **Credential Removal**:

   - Clears the OAuth account information from the global configuration
   - Removes the primary API key used for authentication
   - Erases the list of approved API keys from storage
   - Resets the onboarding completion status

2. **User Experience**:

   - Clears the terminal before displaying the logout message
   - Provides a clear confirmation message about successful logout
   - Exits the application completely after a short delay
   - Ensures a clean break with the authenticated session

3. **Security Focus**:
   - Removes all sensitive authentication data from the local configuration
   - Ensures the next application start will require re-authentication
   - Prevents accidental API usage with old credentials
   - Provides a clean slate for a new login if desired

#### Technical Implementation Notes

Despite its relative simplicity, the `logout` command demonstrates several interesting implementation details:

1. **Configuration Management**: Uses the global configuration system to handle persistent state:

   ```typescript
   const config = getGlobalConfig();

   config.oauthAccount = undefined;
   config.primaryApiKey = undefined;
   config.hasCompletedOnboarding = false;

   if (config.customApiKeyResponses?.approved) {
     config.customApiKeyResponses.approved = [];
   }

   saveGlobalConfig(config);
   ```

2. **Graceful Exit Strategy**: Uses a timeout to allow the message to be displayed before exiting:

   ```typescript
   setTimeout(() => {
     process.exit(0);
   }, 200);
   ```

   This ensures the user sees confirmation before the application closes.

3. **Type Safety**: Uses the `satisfies Command` pattern to ensure type correctness:

   ```typescript
   export default {
     // Command implementation
   } satisfies Command;
   ```

4. **Terminal Management**: Clears the terminal before displaying the logout confirmation:

   ```typescript
   await clearTerminal();
   ```

   This creates a clean visual experience for the logout process.

5. **Optional Field Handling**: Carefully checks for the existence of optional configuration fields:
   ```typescript
   if (config.customApiKeyResponses?.approved) {
     config.customApiKeyResponses.approved = [];
   }
   ```

#### User Experience Benefits

The `logout` command addresses several important user needs:

1. **Account Security**: Provides a clear way to remove credentials when sharing devices or ending a session.

2. **User Confidence**: Confirms successful logout with a clear message, reassuring users their credentials have been removed.

3. **Clean Exit**: Exits the application completely, avoiding any state confusion in the current process.

4. **Simplicity**: Keeps the logout process straightforward and quick, with minimal user interaction required.

5. **Fresh Start**: Resets the onboarding status, ensuring a proper re-onboarding flow on next login.

The `logout` command provides a necessary counterpart to the `login` command, completing the authentication lifecycle with a secure, clean way to end a session. While much simpler than its login counterpart, it maintains the same attention to security and user experience that characterizes Claude Code's approach to authentication management.

