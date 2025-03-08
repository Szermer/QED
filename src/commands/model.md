### model Command

> [!WARNING]
> This command implementation is specific to the anon-kode fork of Claude Code and is not part of the original Claude Code codebase. The analysis below pertains to this specific implementation rather than standard Claude Code functionality.

The `model` command provides users with a comprehensive interface to configure and customize the AI models used by Claude Code, enabling fine-grained control over model selection, parameters, and provider settings.

#### Implementation

The command is implemented in `commands/model.tsx` as a type: 'local-jsx' command that renders a React component for model configuration:

```typescript
import React from "react";
import { render } from "ink";
import { ModelSelector } from "../components/ModelSelector";
import { enableConfigs } from "../utils/config";

export const help = "Change your AI provider and model settings";
export const description = "Change your AI provider and model settings";
export const isEnabled = true;
export const isHidden = false;
export const name = "model";
export const type = "local-jsx";

export function userFacingName(): string {
  return name;
}

export async function call(
  onDone: (result?: string) => void,
  { abortController }: { abortController?: AbortController }
): Promise<React.ReactNode> {
  enableConfigs();
  abortController?.abort?.();
  return (
    <ModelSelector
      onDone={() => {
        onDone();
      }}
    />
  );
}
```

The command uses a different export style than other commands, directly exporting properties and functions rather than a single object. The main functionality is handled by the `ModelSelector` component, which provides an interactive UI for configuring model settings.

#### Functionality

The `model` command provides a sophisticated model selection and configuration workflow:

1. **Multi-Model Management**:

   - Allows configuring both "large" and "small" models separately or together
   - Provides different models for different task complexities for optimal cost/performance
   - Shows current configuration information for reference

2. **Provider Selection**:

   - Supports multiple AI providers (Anthropic, OpenAI, Gemini, etc.)
   - Dynamically fetches available models from the selected provider's API
   - Handles provider-specific API requirements and authentication

3. **Model Parameters**:

   - Configures maximum token settings for response length control
   - Offers reasoning effort controls for supported models (low/medium/high)
   - Preserves provider-specific configuration options

4. **Search and Filtering**:

   - Provides search functionality to filter large model lists
   - Displays model capabilities including token limits and feature support
   - Organizes models with sensible sorting and grouping

5. **API Key Management**:
   - Securely handles API keys for different providers
   - Masks sensitive information during input and display
   - Stores keys securely in the local configuration

#### Technical Implementation Notes

The `model` command demonstrates several sophisticated technical approaches:

1. **Multi-Step Navigation**: Implements a screen stack pattern for intuitive flow navigation:

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
   const navigateTo = (
     screen:
       | "modelType"
       | "provider"
       | "apiKey"
       | "model"
       | "modelParams"
       | "confirmation"
   ) => {
     setScreenStack((prev) => [...prev, screen]);
   };

   // Function to go back to the previous screen
   const goBack = () => {
     if (screenStack.length > 1) {
       // Remove the current screen from the stack
       setScreenStack((prev) => prev.slice(0, -1));
     } else {
       // If we're at the first screen, call onDone to exit
       onDone();
     }
   };
   ```

2. **Dynamic Model Loading**: Fetches available models directly from provider APIs:

   ```typescript
   async function fetchModels() {
     setIsLoadingModels(true);
     setModelLoadError(null);

     try {
       // Provider-specific logic...
       const openai = new OpenAI({
         apiKey: apiKey,
         baseURL: baseURL,
         dangerouslyAllowBrowser: true,
       });

       // Fetch the models
       const response = await openai.models.list();

       // Transform the response into our ModelInfo format
       const fetchedModels = [];
       // Process models...

       return fetchedModels;
     } catch (error) {
       setModelLoadError(`Failed to load models: ${error.message}`);
       throw error;
     } finally {
       setIsLoadingModels(false);
     }
   }
   ```

3. **Form Focus Management**: Implements sophisticated form navigation with keyboard support:

   ```typescript
   // Handle Tab key for form navigation in model params screen
   useInput((input, key) => {
     if (currentScreen === "modelParams" && key.tab) {
       const formFields = getFormFieldsForModelParams();
       // Move to next field
       setActiveFieldIndex((current) => (current + 1) % formFields.length);
       return;
     }

     // Handle Enter key for form submission in model params screen
     if (currentScreen === "modelParams" && key.return) {
       const formFields = getFormFieldsForModelParams();

       if (activeFieldIndex === formFields.length - 1) {
         // If on the Continue button, submit the form
         handleModelParamsSubmit();
       }
       return;
     }
   });
   ```

4. **Provider-Specific Handling**: Implements custom logic for different AI providers:

   ```typescript
   // For Gemini, use the separate fetchGeminiModels function
   if (selectedProvider === "gemini") {
     const geminiModels = await fetchGeminiModels();
     setAvailableModels(geminiModels);
     navigateTo("model");
     return geminiModels;
   }
   ```

5. **Configuration Persistence**: Carefully updates global configuration with new model settings:

   ```typescript
   function saveConfiguration(provider: ProviderType, model: string) {
     const baseURL = providers[provider]?.baseURL || "";

     // Create a new config object based on the existing one
     const newConfig = { ...config };

     // Update the primary provider regardless of which model we're changing
     newConfig.primaryProvider = provider;

     // Update the appropriate model based on the selection
     if (modelTypeToChange === "both" || modelTypeToChange === "large") {
       newConfig.largeModelName = model;
       newConfig.largeModelBaseURL = baseURL;
       newConfig.largeModelApiKey = apiKey || config.largeModelApiKey;
       newConfig.largeModelMaxTokens = parseInt(maxTokens);

       // Save reasoning effort for large model if supported
       if (supportsReasoningEffort) {
         newConfig.largeModelReasoningEffort = reasoningEffort;
       } else {
         newConfig.largeModelReasoningEffort = undefined;
       }
     }

     // Similar handling for small model...

     // Save the updated configuration
     saveGlobalConfig(newConfig);
   }
   ```

#### User Experience Benefits

The `model` command provides several important benefits for Claude Code users:

1. **Customization Control**: Gives users fine-grained control over the AI models powering their interaction.

2. **Cost Optimization**: Allows setting different models for different complexity tasks, optimizing for cost and speed.

3. **Provider Flexibility**: Enables users to choose from multiple AI providers based on preference, cost, or feature needs.

4. **Parameter Tuning**: Offers advanced users the ability to tune model parameters for optimal performance.

5. **Progressive Disclosure**: Uses a step-by-step flow that makes configuration accessible to both novice and advanced users.

6. **Intuitive Navigation**: Implements keyboard navigation with clear indicators for a smooth configuration experience.

The `model` command exemplifies Claude Code's approach to giving users control and flexibility while maintaining an accessible interface, keeping advanced configuration options available but not overwhelming.

