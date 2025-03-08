### pr_comments Command

The `pr_comments` command provides a specialized interface for retrieving and displaying GitHub pull request comments, helping users review feedback on their code without leaving the terminal.

#### Implementation

The command is implemented in `commands/pr_comments.ts` as a type: 'prompt' command that formulates a specialized request to Claude:

```typescript
import { Command } from "../commands";

export default {
  type: "prompt",
  name: "pr-comments",
  description: "Get comments from a GitHub pull request",
  progressMessage: "fetching PR comments",
  isEnabled: true,
  isHidden: false,
  userFacingName() {
    return "pr-comments";
  },
  async getPromptForCommand(args: string) {
    return [
      {
        role: "user",
        content: [
          {
            type: "text",
            text: `You are an AI assistant integrated into a git-based version control system. Your task is to fetch and display comments from a GitHub pull request.

Follow these steps:

1. Use \`gh pr view --json number,headRepository\` to get the PR number and repository info
2. Use \`gh api /repos/{owner}/{repo}/issues/{number}/comments\` to get PR-level comments
3. Use \`gh api /repos/{owner}/{repo}/pulls/{number}/comments\` to get review comments. Pay particular attention to the following fields: \`body\`, \`diff_hunk\`, \`path\`, \`line\`, etc. If the comment references some code, consider fetching it using eg \`gh api /repos/{owner}/{repo}/contents/{path}?ref={branch} | jq .content -r | base64 -d\`
4. Parse and format all comments in a readable way
5. Return ONLY the formatted comments, with no additional text

Format the comments as:

## Comments

[For each comment thread:]
- @author file.ts#line:
  \`\`\`diff
  [diff_hunk from the API response]
  \`\`\`
  > quoted comment text
  
  [any replies indented]

If there are no comments, return "No comments found."

Remember:
1. Only show the actual comments, no explanatory text
2. Include both PR-level and code review comments
3. Preserve the threading/nesting of comment replies
4. Show the file and line number context for code review comments
5. Use jq to parse the JSON responses from the GitHub API

${args ? "Additional user input: " + args : ""}
`,
          },
        ],
      },
    ];
  },
} satisfies Command;
```

Unlike commands that directly render UI components, the `pr_comments` command is a 'prompt' type command that formulates a specific request to Claude, instructing it to perform a complex sequence of operations using the GitHub CLI and API.

#### Functionality

The `pr_comments` command provides several key capabilities:

1. **GitHub Integration**:

   - Uses the GitHub CLI (`gh`) to interact with GitHub's API
   - Retrieves both PR-level comments (issue comments) and review comments (inline code comments)
   - Handles authentication and API access through the existing GitHub CLI configuration

2. **Comment Retrieval**:

   - Fetches PR metadata to determine repository and PR information
   - Makes API calls to retrieve different types of comments
   - Handles pagination and JSON parsing using `jq` utility

3. **Context Preservation**:

   - Retrieves code context for review comments using the `diff_hunk` field
   - Shows file paths and line numbers for specific comments
   - Preserves the hierarchical structure of comment threads and replies

4. **Formatted Output**:

   - Creates a well-structured, readable display of comments
   - Uses Markdown formatting for readability
   - Shows comments in a hierarchical, threaded view

5. **Progress Indication**:
   - Shows a progress message ("fetching PR comments") while the operation is in progress
   - Provides clear indication when no comments are found

#### Technical Implementation Notes

The `pr_comments` command demonstrates several sophisticated approaches:

1. **Prompt-Based Implementation**: Unlike UI commands, this command uses Claude itself to execute a complex sequence of operations through a carefully crafted prompt.

2. **GitHub CLI Utilization**: Leverages the GitHub CLI's capabilities to interact with GitHub's API, taking advantage of existing authentication and configuration.

3. **API Interaction Patterns**: Provides a detailed workflow for accessing and processing data from different GitHub API endpoints:

   ```
   gh api /repos/{owner}/{repo}/issues/{number}/comments
   gh api /repos/{owner}/{repo}/pulls/{number}/comments
   ```

4. **JSON Processing with JQ**: Uses the `jq` command-line JSON processor for parsing complex API responses.

5. **Complex Data Formatting**: Provides explicit formatting instructions to ensure consistent, readable output:

   ````
   - @author file.ts#line:
     ```diff
     [diff_hunk from the API response]
   ````

   > quoted comment text

   [any replies indented]

   ```

   ```

6. **Arguments Passthrough**: Allows users to provide additional arguments that are appended to the prompt, enabling refinement of the command's behavior.

#### User Experience Benefits

The `pr_comments` command addresses several important needs for developers:

1. **Context Switching Reduction**: Allows reviewing PR comments without leaving the terminal or switching to a browser.

2. **Comment Aggregation**: Brings together comments from different locations (PR-level and code-specific) in a single view.

3. **Reading Optimization**: Formats comments with proper context, improving readability compared to raw API responses.

4. **Workflow Integration**: Enables PR review activities to be part of the normal development workflow in the terminal.

5. **GitHub Integration**: Takes advantage of existing GitHub CLI authentication and configuration.

The `pr_comments` command exemplifies how Claude Code can leverage Claude's capabilities to implement complex workflows that would otherwise require significant custom code. By using a prompt-based approach, it achieves powerful GitHub integration with minimal implementation complexity.

