### review Command

The `review` command provides a specialized workflow for reviewing GitHub pull requests, leveraging Claude's code analysis capabilities to generate comprehensive code reviews.

#### Implementation

The command is implemented in `commands/review.ts` as a type: 'prompt' command that formulates a specific request to Claude:

```typescript
import { Command } from "../commands";
import { BashTool } from "../tools/BashTool/BashTool";

export default {
  type: "prompt",
  name: "review",
  description: "Review a pull request",
  isEnabled: true,
  isHidden: false,
  progressMessage: "reviewing pull request",
  userFacingName() {
    return "review";
  },
  async getPromptForCommand(args) {
    return [
      {
        role: "user",
        content: [
          {
            type: "text",
            text: `
      You are an expert code reviewer. Follow these steps:

      1. If no PR number is provided in the args, use ${BashTool.name}("gh pr list") to show open PRs
      2. If a PR number is provided, use ${BashTool.name}("gh pr view <number>") to get PR details
      3. Use ${BashTool.name}("gh pr diff <number>") to get the diff
      4. Analyze the changes and provide a thorough code review that includes:
         - Overview of what the PR does
         - Analysis of code quality and style
         - Specific suggestions for improvements
         - Any potential issues or risks
      
      Keep your review concise but thorough. Focus on:
      - Code correctness
      - Following project conventions
      - Performance implications
      - Test coverage
      - Security considerations

      Format your review with clear sections and bullet points.

      PR number: ${args}
    `,
          },
        ],
      },
    ];
  },
} satisfies Command;
```

Like the `pr_comments` command, the `review` command is a 'prompt' type command that formulates a specific request to Claude, instructing it to perform a complex sequence of operations using the GitHub CLI.

#### Functionality

The `review` command implements a comprehensive PR review workflow:

1. **PR Discovery and Selection**:

   - Lists open pull requests if no PR number is specified
   - Retrieves details for a specific PR when a number is provided
   - Presents options for users to select which PR to review

2. **Code Analysis**:

   - Fetches the PR diff to understand code changes
   - Analyzes code quality, style, and potential issues
   - Evaluates changes in the context of the project's conventions

3. **Review Generation**:

   - Creates a structured code review with logical sections
   - Highlights potential improvements and issues
   - Provides specific, actionable feedback on code changes

4. **Focus Areas**:

   - Analyzes code correctness and logical issues
   - Evaluates adherence to project conventions
   - Assesses performance implications of changes
   - Reviews test coverage of new code
   - Identifies potential security considerations

5. **Progress Indication**:
   - Shows a "reviewing pull request" message during analysis
   - Provides a clear visual indication that processing is underway

#### Technical Implementation Notes

The `review` command demonstrates several important implementation patterns:

1. **Tool Reference in Prompt**: Explicitly references the BashTool by name in the prompt to ensure proper tool usage:

   ```typescript
   use ${BashTool.name}("gh pr list")
   ```

   This ensures the correct tool is used regardless of how Claude might interpret the instruction.

2. **GitHub CLI Integration**: Leverages the GitHub CLI's capabilities for PR interaction:

   ```
   gh pr list - Show open PRs
   gh pr view <number> - Get PR details
   gh pr diff <number> - Get the diff
   ```

3. **Comprehensive Analysis Instructions**: Provides Claude with a detailed framework for analysis:

   ```
   Analyze the changes and provide a thorough code review that includes:
   - Overview of what the PR does
   - Analysis of code quality and style
   - Specific suggestions for improvements
   - Any potential issues or risks
   ```

4. **Focus Guidance**: Directs Claude's analysis toward specific aspects of code quality:

   ```
   Focus on:
   - Code correctness
   - Following project conventions
   - Performance implications
   - Test coverage
   - Security considerations
   ```

5. **Formatting Guidance**: Ensures consistent output format with clear instructions:
   ```
   Format your review with clear sections and bullet points.
   ```

#### User Experience Benefits

The `review` command provides several valuable benefits for developers:

1. **Code Review Automation**: Reduces the manual effort required for initial PR reviews.

2. **Consistent Review Quality**: Ensures all PRs receive a thorough analysis covering key areas.

3. **Learning Opportunity**: Exposes developers to alternative perspectives on their code.

4. **Workflow Integration**: Fits seamlessly into GitHub-based development workflows.

5. **Time Efficiency**: Quickly generates comprehensive reviews that serve as a starting point for human reviewers.

The `review` command exemplifies how Claude Code can leverage Claude's code analysis capabilities to add value to existing development workflows. It transforms Claude from a conversational assistant into an active participant in the code review process.

