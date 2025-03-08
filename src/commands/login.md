### login Command

The `login` command provides users with a secure OAuth 2.0 authentication flow to connect Claude Code with their Anthropic Console account, enabling API access and proper billing.

#### Implementation

The command is implemented in `commands/login.tsx` as a type: 'local-jsx' command that renders a React component for the authentication flow:

```typescript
import * as React from "react";
import type { Command } from "../commands";
import { ConsoleOAuthFlow } from "../components/ConsoleOAuthFlow";
import { clearTerminal } from "../utils/terminal";
import { isLoggedInToAnthropic } from "../utils/auth";
import { useExitOnCtrlCD } from "../hooks/useExitOnCtrlCD";
import { Box, Text } from "ink";
import { clearConversation } from "./clear";

export default () =>
  ({
    type: "local-jsx",
    name: "login",
    description: isLoggedInToAnthropic()
      ? "Switch Anthropic accounts"
      : "Sign in with your Anthropic account",
    isEnabled: true,
    isHidden: false,
    async call(onDone, context) {
      await clearTerminal();
      return (
        <Login
          onDone={async () => {
            clearConversation(context);
            onDone();
          }}
        />
      );
    },
    userFacingName() {
      return "login";
    },
  } satisfies Command);

function Login(props: { onDone: () => void }) {
  const exitState = useExitOnCtrlCD(props.onDone);
  return (
    <Box flexDirection="column">
      <ConsoleOAuthFlow onDone={props.onDone} />
      <Box marginLeft={3}>
        <Text dimColor>
          {exitState.pending ? (
            <>Press {exitState.keyName} again to exit</>
          ) : (
            ""
          )}
        </Text>
      </Box>
    </Box>
  );
}
```

The command uses a factory function to dynamically create a command object that adapts its description based on the current login state. The main logic is delegated to the `ConsoleOAuthFlow` component, which handles the OAuth flow with the Anthropic API.

#### Functionality

The `login` command implements a comprehensive authentication flow:

1. **OAuth 2.0 Integration**:

   - Uses OAuth 2.0 with PKCE (Proof Key for Code Exchange) for security
   - Opens a browser for the user to log in to Anthropic Console
   - Handles both automatic browser redirect and manual code entry flows
   - Securely exchanges authorization codes for access tokens

2. **Account Management**:

   - Creates and stores API keys for authenticated users
   - Normalizes and securely saves keys in the global configuration
   - Tracks account information including account UUID and organization details
   - Provides context-aware descriptions ("Sign in" vs "Switch accounts")

3. **Security Features**:

   - Implements state verification to prevent CSRF attacks
   - Uses code verifiers and challenges for secure code exchange
   - Validates all tokens and responses from the authentication server
   - Provides clear error messages for authentication failures

4. **UI Experience**:
   - Clears the terminal for a clean login experience
   - Provides a progressive disclosure flow with appropriate status messages
   - Offers fallback mechanisms for cases where automatic browser opening fails
   - Shows loading indicators during asynchronous operations

#### Technical Implementation Notes

The login command demonstrates several sophisticated technical approaches:

1. **Local HTTP Server**: Creates a temporary HTTP server for OAuth callback handling:

   ```typescript
   this.server = http.createServer(
     (req: IncomingMessage, res: ServerResponse) => {
       const parsedUrl = url.parse(req.url || "", true);
       if (parsedUrl.pathname === "/callback") {
         // Handle OAuth callback
       }
     }
   );
   ```

2. **PKCE Implementation**: Implements the Proof Key for Code Exchange extension to OAuth:

   ```typescript
   function generateCodeVerifier(): string {
     return base64URLEncode(crypto.randomBytes(32));
   }

   async function generateCodeChallenge(verifier: string): Promise<string> {
     const encoder = new TextEncoder();
     const data = encoder.encode(verifier);
     const digest = await crypto.subtle.digest("SHA-256", data);
     return base64URLEncode(Buffer.from(digest));
   }
   ```

3. **Parallel Authentication Paths**: Supports both automatic and manual authentication flows:

   ```typescript
   const { autoUrl, manualUrl } = this.generateAuthUrls(codeChallenge, state);
   await authURLHandler(manualUrl); // Show manual URL in UI
   await openBrowser(autoUrl); // Try automatic browser opening
   ```

4. **Promise-Based Flow Control**: Uses promises to coordinate the asynchronous authentication flow:

   ```typescript
   const { authorizationCode, useManualRedirect } = await new Promise<{
     authorizationCode: string;
     useManualRedirect: boolean;
   }>((resolve, reject) => {
     this.pendingCodePromise = { resolve, reject };
     this.startLocalServer(state, onReady);
   });
   ```

5. **State Management with React**: Uses React state and hooks for UI management:

   ```typescript
   const [oauthStatus, setOAuthStatus] = useState<OAuthStatus>({
     state: "idle",
   });
   ```

6. **Error Recovery**: Implements sophisticated error handling with retry mechanisms:
   ```typescript
   if (oauthStatus.state === "error" && oauthStatus.toRetry) {
     setPastedCode("");
     setOAuthStatus({
       state: "about_to_retry",
       nextState: oauthStatus.toRetry,
     });
   }
   ```

#### User Experience Benefits

The `login` command addresses several important user needs:

1. **Seamless Authentication**: Provides a smooth authentication experience without requiring manual API key creation or copying.

2. **Cross-Platform Compatibility**: Works across different operating systems and browsers.

3. **Fallback Mechanisms**: Offers manual code entry when automatic browser redirection fails.

4. **Clear Progress Indicators**: Shows detailed status messages throughout the authentication process.

5. **Error Resilience**: Provides helpful error messages and retry options when authentication issues occur.

6. **Account Switching**: Allows users to easily switch between different Anthropic accounts.

The login command exemplifies Claude Code's approach to security and user experience, implementing a complex authentication flow with attention to both security best practices and ease of use.

