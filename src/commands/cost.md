### cost Command

The `cost` command provides users with visibility into the cost and duration of their current Claude Code session, helping them monitor their API usage and expenses.

#### Implementation

The command is implemented in `commands/cost.ts` as a simple type: 'local' command that calls a formatting function:

```typescript
import type { Command } from "../commands";
import { formatTotalCost } from "../cost-tracker";

const cost = {
  type: "local",
  name: "cost",
  description: "Show the total cost and duration of the current session",
  isEnabled: true,
  isHidden: false,
  async call() {
    return formatTotalCost();
  },
  userFacingName() {
    return "cost";
  },
} satisfies Command;

export default cost;
```

This command relies on the cost tracking system implemented in `cost-tracker.ts`, which maintains a running total of API costs and session duration.

#### Cost Tracking System

The cost tracking system is implemented in `cost-tracker.ts` and consists of several key components:

1. **State Management**: Maintains a simple singleton state object tracking:

   - `totalCost`: Running total of API costs in USD
   - `totalAPIDuration`: Cumulative time spent waiting for API responses
   - `startTime`: Timestamp when the session began

2. **Cost Accumulation**: Provides a function to add costs as they occur:

   ```typescript
   export function addToTotalCost(cost: number, duration: number): void {
     STATE.totalCost += cost;
     STATE.totalAPIDuration += duration;
   }
   ```

3. **Reporting**: Formats cost information in a human-readable format:

   ```typescript
   export function formatTotalCost(): string {
     return chalk.grey(
       `Total cost: ${formatCost(STATE.totalCost)}
       Total duration (API): ${formatDuration(STATE.totalAPIDuration)}
       Total duration (wall): ${formatDuration(getTotalDuration())}`
     );
   }
   ```

4. **Persistence**: Uses a React hook to save session cost data when the process exits:

   ```typescript
   export function useCostSummary(): void {
     useEffect(() => {
       const f = () => {
         process.stdout.write("\n" + formatTotalCost() + "\n");

         // Save last cost and duration to project config
         const projectConfig = getCurrentProjectConfig();
         saveCurrentProjectConfig({
           ...projectConfig,
           lastCost: STATE.totalCost,
           lastAPIDuration: STATE.totalAPIDuration,
           lastDuration: getTotalDuration(),
           lastSessionId: SESSION_ID,
         });
       };
       process.on("exit", f);
       return () => {
         process.off("exit", f);
       };
     }, []);
   }
   ```

#### UI Components

The cost tracking system is complemented by two UI components:

1. **Cost Component**: A simple display component used in the debug panel to show the most recent API call cost:

   ```typescript
   export function Cost({
     costUSD,
     durationMs,
     debug,
   }: Props): React.ReactNode {
     if (!debug) {
       return null;
     }

     const durationInSeconds = (durationMs / 1000).toFixed(1);
     return (
       <Box flexDirection="column" minWidth={23} width={23}>
         <Text dimColor>
           Cost: ${costUSD.toFixed(4)} ({durationInSeconds}s)
         </Text>
       </Box>
     );
   }
   ```

2. **CostThresholdDialog**: A warning dialog shown when users exceed a certain cost threshold:

   ```typescript
   export function CostThresholdDialog({ onDone }: Props): React.ReactNode {
     // Handle Ctrl+C, Ctrl+D and Esc
     useInput((input, key) => {
       if ((key.ctrl && (input === "c" || input === "d")) || key.escape) {
         onDone();
       }
     });

     return (
       <Box
         flexDirection="column"
         borderStyle="round"
         padding={1}
         borderColor={getTheme().secondaryBorder}
       >
         <Box marginBottom={1} flexDirection="column">
           <Text bold>You've spent $5 on the Anthropic API this session.</Text>
           <Text>Learn more about how to monitor your spending:</Text>
           <Link url="https://docs.anthropic.com/s/claude-code-cost" />
         </Box>
         <Box>
           <Select
             options={[
               {
                 value: "ok",
                 label: "Got it, thanks!",
               },
             ]}
             onChange={onDone}
           />
         </Box>
       </Box>
     );
   }
   ```

#### Technical Implementation Notes

The cost tracking system demonstrates several design considerations:

1. **Singleton State**: Uses a single state object with a clear comment warning against adding more state.

2. **Persistence Across Sessions**: Saves cost data to the project configuration, allowing for tracking across sessions.

3. **Formatting Flexibility**: Uses different decimal precision based on the cost amount (4 decimal places for small amounts, 2 for larger ones).

4. **Multiple Time Metrics**: Tracks both wall clock time and API request time separately.

5. **Environment-Aware Testing**: Includes a reset function that's only available in test environments.

6. **Exit Hooks**: Uses process exit hooks to ensure cost data is saved and displayed even if the application exits unexpectedly.

#### User Experience Considerations

The cost tracking system addresses several user needs:

1. **Transparency**: Provides clear visibility into API usage costs.

2. **Usage Monitoring**: Helps users track and manage their API spending.

3. **Efficiency Insights**: Shows both total runtime and API time, helping identify bottlenecks.

4. **Threshold Warnings**: Alerts users when they've spent significant amounts.

5. **Documentation Links**: Provides resources for learning more about cost management.

The `/cost` command and associated systems represent Claude Code's approach to transparent cost management, giving users control over their API usage while maintaining a simple, unobtrusive interface.

