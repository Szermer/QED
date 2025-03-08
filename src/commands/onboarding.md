### onboarding Command

The `onboarding` command provides a guided first-run experience for new users, helping them configure Claude Code to their preferences and introducing them to the tool's capabilities.

#### Implementation

The command is implemented in `commands/onboarding.tsx` as a type: 'local-jsx' command that renders a React component:

```typescript
import * as React from "react";
import type { Command } from "../commands";
import { Onboarding } from "../components/Onboarding";
import { clearTerminal } from "../utils/terminal";
import { getGlobalConfig, saveGlobalConfig } from "../utils/config";
import { clearConversation } from "./clear";

export default {
  type: "local-jsx",
  name: "onboarding",
  description: "[ANT-ONLY] Run through the onboarding flow",
  isEnabled: true,
  isHidden: false,
  async call(onDone, context) {
    await clearTerminal();
    const config = getGlobalConfig();
    saveGlobalConfig({
      ...config,
      theme: "dark",
    });

    return (
      <Onboarding
        onDone={async () => {
          clearConversation(context);
          onDone();
        }}
      />
    );
  },
  userFacingName() {
    return "onboarding";
  },
} satisfies Command;
```

The command delegates to the `Onboarding` component in `components/Onboarding.tsx`, which handles the multi-step onboarding flow.

#### Functionality

The `onboarding` command implements a comprehensive first-run experience:

1. **Multi-Step Flow**:

   - Walks users through a series of configuration steps with a smooth, guided experience
   - Includes theme selection, usage guidance, and model selection
   - Uses a stack-based navigation system for intuitive flow between steps

2. **Theme Configuration**:

   - Allows users to choose between light and dark themes
   - Includes colorblind-friendly theme options for accessibility
   - Provides a live preview of the selected theme using a code diff example

3. **Usage Guidelines**:

   - Introduces users to effective ways of using Claude Code
   - Explains how to provide clear context and work with the tool
   - Sets appropriate expectations for the tool's capabilities

4. **Model Selection**:

   - Guides users through configuring AI provider and model settings
   - Uses the `ModelSelector` component for a consistent model selection experience
   - Allows configuration of both small and large models for different tasks

5. **Configuration Persistence**:
   - Saves user preferences to the global configuration
   - Marks onboarding as complete to prevent repeat runs
   - Clears the conversation after onboarding to provide a clean start

#### Technical Implementation Notes

The `onboarding` command demonstrates several sophisticated patterns:

1. **Screen Navigation Stack**: Implements a stack-based navigation system for multi-step flow:

   ```typescript
   const [screenStack, setScreenStack] = useState<
     Array<
       | "modelType"
       | "provider"
       | "apiKey"
       | "model"
       | "modelParams"
       | "confirmation"
     >
   >(["modelType"]);

   // Current screen is always the last item in the stack
   const currentScreen = screenStack[screenStack.length - 1];

   // Function to navigate to a new screen
   const navigateTo = (screen) => {
     setScreenStack((prev) => [...prev, screen]);
   };

   // Function to go back to the previous screen
   const goBack = () => {
     if (screenStack.length > 1) {
       setScreenStack((prev) => prev.slice(0, -1));
     } else {
       onDone();
     }
   };
   ```

2. **Progressive Disclosure**: Presents information in digestible chunks across multiple steps.

3. **Terminal UI Adaptation**: Uses Ink components optimized for terminal rendering:

   ```typescript
   <Box flexDirection="column" gap={1} paddingLeft={1}>
     <Text bold>Using {PRODUCT_NAME} effectively:</Text>
     <Box flexDirection="column" width={70}>
       <OrderedList>
         <OrderedList.Item>
           <Text>
             Start in your project directory
             <Newline />
             <Text color={theme.secondaryText}>
               Files are automatically added to context when needed.
             </Text>
             <Newline />
           </Text>
         </OrderedList.Item>
         {/* Additional list items */}
       </OrderedList>
     </Box>
     <PressEnterToContinue />
   </Box>
   ```

4. **Interactive Components**: Uses custom select components for theme selection with previews:

   ```typescript
   <Select
     options={[
       { label: "Light text", value: "dark" },
       { label: "Dark text", value: "light" },
       {
         label: "Light text (colorblind-friendly)",
         value: "dark-daltonized",
       },
       {
         label: "Dark text (colorblind-friendly)",
         value: "light-daltonized",
       },
     ]}
     onFocus={handleThemePreview}
     onChange={handleThemeSelection}
   />
   ```

5. **Exit Handling**: Implements `useExitOnCtrlCD` to provide users with a clear way to exit the flow:

   ```typescript
   const exitState = useExitOnCtrlCD(() => process.exit(0));
   ```

6. **Conditional Rendering**: Uses state to conditionally show different screens:
   ```typescript
   // If we're showing the model selector screen, render it directly
   if (showModelSelector) {
     return <ModelSelector onDone={handleModelSelectionDone} />;
   }
   ```

#### User Experience Benefits

The `onboarding` command addresses several key needs for new users:

1. **Guided Setup**: Provides a structured introduction to Claude Code rather than dropping users into a blank interface.

2. **Preference Customization**: Allows users to set their preferences immediately, increasing comfort with the tool.

3. **Learning Opportunity**: Teaches best practices for using the tool effectively from the start.

4. **Accessibility Awareness**: Explicitly offers colorblind-friendly themes, demonstrating attention to accessibility.

5. **Progressive Complexity**: Introduces features gradually, avoiding overwhelming new users.

The `onboarding` command exemplifies Claude Code's attention to user experience, ensuring new users can quickly set up the tool according to their preferences and learn how to use it effectively from the beginning.

