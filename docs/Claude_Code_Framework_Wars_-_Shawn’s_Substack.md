# Claude Code Framework Wars - Shawn’s Substack

We’re just now starting to learn how to work with AI as software developers.

The big idea: **Claude can automate the coding, while you step into higher-value roles as project manager, designer, and software architect.** The trick is to stop treating Claude as a chatbox and start treating it as a **framework**—a set of rules, roles, and workflows that make its output predictable and valuable.

Even more fascinating - claude code doesn’t require code to become a framework - just structured prompts. And right now, the developer community is experimenting wildly—what you could call the **Claude Code Framework Wars**. Dozens of open-source projects are testing different recipes for how to work with AI productively.

Here’s a field report.

[

![Https%3A%2F%2Fsubstack post media.s3.amazonaws.com%2Fpublic%2Fimages%2F4aca2f45 4920 4dc6 94f3 bc1269aea406 1536x1024](https://substackcdn.com/image/fetch/$s_!ZKCU!,w_1456,c_limit,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F4aca2f45-4920-4dc6-94f3-bc1269aea406_1536x1024.png)

](https://substackcdn.com/image/fetch/$s_!ZKCU!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F4aca2f45-4920-4dc6-94f3-bc1269aea406_1536x1024.png)

If you’re designing your own Claude setup, there are seven big choices you’ll need to make:

1.  Where tasks live?
    
2.  How do you guide Claude?
    
3.  How agents coordinate?
    
4.  How sessions are run?
    
5.  How code accesses tools?
    
6.  How code is developed?
    
7.  How code is delivered?
    
8.  How context is preserved?
    

Think of it like setting up a kitchen. Claude is the line cook, but you need to decide: where do recipes go, how do cooks learn the house style, who runs the kitchen, and how does food reach the table?

Claude needs a source of truth.

-   **Markdown backlogs:** Tasks as a todo list in markdown.
    
    *Example:* [Backlog.md](https://github.com/MrLesk/Backlog.md), [ReqText](https://github.com/fred-terzi/reqtext).
    
-   **Structured text:** Specify product specs that get converted into tasks.*Example: [Agent OS](https://github.com/buildermethods/agent-os)*
    
-   **Issues/tickets:** Store specs as GitHub Issues or Jira tickets, tie them to code reviews.
    
    *Example:* [ccpm](https://github.com/automazeio/ccpm)
    

**Takeaway:** Tasks must live somewhere Claude can see them and you can trace them.

Replace ambigious prompts with structure.

-   **Command libraries:** Prebuilt slash commands (e.g. /create-tasks, /review).
    
-   **Coding standards**: Clarify the tech stack, coding guidelines
    
-   **Definition of Done:** Encode “definition of done”
    
-   **Trigger Validation Hooks**: enforce linting & tests on every change
    
-   **Claude as a Reviewer:** Claude as the developer and reviewer
    

**Takeaway:** Claude does better work when the rules are clear and repeatable.

Multiple Claudes? Give them roles and a plan.

-   **Role simulation:** AI as PM, architect, developer, tester.
    
    *Example:* [Agent OS](https://github.com/buildermethods/agent-os)
    
-   **Swarm parallelism:** Many agents run at once in a structured flow (e.g. spec → pseudocode → code → tests).
    
    *Example:* [Claude-Flow](https://github.com/ruvnet/claude-flow).
    
-   **Repo-native artifacts:** Store tasks, logs, and ADRs in codebase so memory persists.
    
    *Example:* [Roo Commander](https://github.com/jezweb/roo-commander).
    

**Takeaway:** Coordination keeps many AI workers from stepping on each other.

AI output can get messy—sessions are your workstation setup.

-   **Terminal orchestration:** Claude controls commands, panes, and logs.
    
    *Example:* [Symphony](https://github.com/sincover/Symphony), [Claude-Squad](https://github.com/smtg-ai/claude-squad).
    
-   **Parallel worktrees:** [Run multiple branches in parallel using Git Worktrees](https://docs.anthropic.com/en/docs/claude-code/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees).
    
    *Example:* [Crystal](https://github.com/stravu/crystal).
    
-   **Parallel containers**: [Run Claude in isolated containers](https://docs.anthropic.com/en/docs/claude-code/devcontainer) to avoid collisions  
    *Example: [ClaudeBox](https://github.com/RchGrav/claudebox)*
    

**Takeaway:** Get more done by running tasks in parallel without constant collisions

Give Claude knowledge about your whole stack.

-   **MCP Integrations (Model Context Protocol):** bundled MCP servers that connect Claude to external resources—browsers, databases, test runners, even UI automation frameworks.
    
-   **Custom Tool Libraries:** built in shell scripts and commands  
    Example: [Symphony](https://github.com/sincover/Symphony)
    
-   **Database Accessors:** tooling for strong database access  
    Example: [Claudable](https://github.com/opactorai/Claudable) with Supabase
    
-   **Testing and Validation Hooks:** run tests (e.g., Vitest, Jest) before declaring work “done.” This ties Claude’s output into real validation loops  
    Example: [Agent OS](https://github.com/buildermethods/agent-os)
    

**Takeaway:** Tooling turns Claude from “a smart autocomplete” into “an active teammate” who can check their own work and interact with your systems.

Claude can wear different hats depending on what you need:

-   **Project Manager (PM):** turns product specs into tasks and backlogs
    
    *Example:* [ccpm](https://github.com/automazeio/ccpm), [Agent OS](https://github.com/buildermethods/agent-os)
    
-   **Architect:** designs the overall structure, defines interfaces, and sets conventions before coding begins.
    
-   **Implementer:** writes code inside those guardrails, following tests and standards.
    
-   **QA:** reviews work for issues  
    *Example*: [BMAD-code](https://github.com/bmad-code-org/BMAD-METHOD)
    
-   **Reviewer:** audits PRs for quality, readability, and risk.
    

**Takeaway:** leverage AI at each step of the software lifecycle.

How does the code reach your repo?

-   **Small diffs:** AI picks up tickets and produces small PRs, always reviewed.
    
    *Example:* [ai-ticket](https://github.com/jmikedupont2/ai-ticket).
    
-   **Experiments:** Deploying changes behind feature flags
    
-   **Full app scaffolds:** AI builds and deploys entire apps from high-level prompts.
    
    *Example:* [Claudable](https://github.com/opactorai/Claudable).
    

**Takeaway:** Pick your scale—safe iteration for production, scaffolds for prototypes.

Claude forgets. Frameworks remember.

-   **Docs and journals:** Keep CLAUDE.md, architecture notes, and project journals fresh.
    
    *Example:* [Claude Conductor](https://github.com/superbasicstudio/claude-conductor).
    
-   **Persistent memory & checkups:** Recap recent work, run project health checks, store decisions.
    
    *Example:* [Claude-Flow](https://github.com/ruvnet/claude-flow).
    

**Takeaway:** Without memory, AI repeats mistakes. With memory, it compounds progress.

Think of these options as a menu. You don’t need to order everything at once.

-   **Beginner setup:** Markdown backlog + ticket diffs.
    
-   **Structured team:** Product Specs + standards + role simulation.
    
-   **Experiment-heavy:** Repo artifacts + parallel sessions.
    
-   **Prototype mode:** App builder + docs scaffolding.
    

The early lesson from the Claude Code framework wars is simple: **AI works best when you give it structure.**

Claude isn’t replacing developers—it’s shifting their roles. You spend less time typing boilerplate and more time shaping specs, reviewing designs, and defining architecture. If you’re not doing your job, things can go off the rails fast.

We’re still early, but the frameworks are converging on a future where AI is not a magic box but a **set of** **teammates you manage**. And that’s the exciting part: the more structure you give, the more you get back.

---
Source: [Claude Code Framework Wars - Shawn’s Substack](https://shmck.substack.com/p/claude-code-framework-wars?utm_source=tldrai)