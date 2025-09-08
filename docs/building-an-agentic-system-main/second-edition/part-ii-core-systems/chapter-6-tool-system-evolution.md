# Chapter 6: Tool System Architecture Evolution

Tools are the hands of an AI coding assistant. They transform conversations into concrete actions—reading files, running commands, searching codebases, and modifying code. As AI assistants evolved from single-user to collaborative systems, their tool architectures had to evolve as well.

This chapter explores how tool systems evolve to support distributed execution, external integrations, and sophisticated resource management while maintaining security and performance at scale.

## The Tool System Challenge

Building tools for collaborative AI assistants introduces unique requirements:

1. **Safety at Scale** - Thousands of users running arbitrary commands
2. **Resource Management** - Preventing runaway processes and quota exhaustion  
3. **Extensibility** - Supporting third-party tool integrations
4. **Auditability** - Tracking who changed what and when
5. **Performance** - Parallel execution without conflicts
6. **Rollback** - Undoing tool actions when things go wrong

Traditional CLI tools weren't designed for these constraints. Amp had to rethink tool architecture from the ground up.

## Tool System Architecture Evolution

Tool systems evolve through distinct generations as they mature from simple execution to collaborative systems.

**Recognition Pattern**: You need tool architecture evolution when:
- Moving from single-user to multi-user environments
- Adding safety and permission requirements
- Supporting long-running and cancellable operations
- Integrating with external systems and APIs

### Generation 1: Direct Execution

Simple, immediate tool execution suitable for single-user environments.

```typescript
// Direct execution pattern
interface SimpleTool {
  execute(args: ToolArgs): Promise<string>;
}

// Example: Basic file edit
class FileEditTool implements SimpleTool {
  async execute(args: { path: string; content: string }): Promise<string> {
    await writeFile(args.path, args.content);
    return `Wrote ${args.path}`;
  }
}
```

**Limitations**: No safety checks, no rollback, no collaboration support.

### Generation 2: Stateful Execution

Adds state tracking, validation, and undo capabilities for better reliability.

```typescript
// Stateful execution pattern
interface StatefulTool {
  execute(args: ToolArgs, context: ToolContext): Promise<ToolResult>;
}

interface ToolResult {
  message: string;
  undo?: () => Promise<void>;
  filesChanged?: string[];
}

// Example: File edit with undo
class StatefulFileEditTool implements StatefulTool {
  async execute(args: EditArgs, context: ToolContext): Promise<ToolResult> {
    // Validate and track changes
    const before = await readFile(args.path);
    await writeFile(args.path, args.content);
    
    return {
      message: `Edited ${args.path}`,
      undo: () => writeFile(args.path, before),
      filesChanged: [args.path]
    };
  }
}
```

**Benefits**: Rollback support, change tracking, basic safety.

### Generation 3: Observable Tool System

Reactive system with permissions, progress tracking, and collaborative features.

```typescript
// Observable execution pattern
type ToolRun<T> = 
  | { status: 'queued' }
  | { status: 'blocked-on-user'; permissions?: string[] }
  | { status: 'in-progress'; progress?: T }
  | { status: 'done'; result: T }
  | { status: 'error'; error: Error };

interface ObservableTool<T> {
  execute(args: ToolArgs): Observable<ToolRun<T>>;
  cancel?(runId: string): Promise<void>;
}
```

**Benefits**: Real-time progress, cancellation, permission handling, collaborative safety.

## The Tool Service Architecture

Amp's ToolService orchestrates all tool operations:

```typescript
export class ToolService implements IToolService {
  private tools = new Map<string, ToolRegistration<any>>();
  private activeCalls = new Map<string, ActiveToolCall>();
  private fileTracker: FileChangeTracker;
  private permissionService: ToolPermissionService;
  
  constructor(
    private config: ConfigService,
    private mcpService?: MCPService
  ) {
    this.registerBuiltinTools();
    this.registerMCPTools();
  }
  
  private registerBuiltinTools(): void {
    // Register core tools
    this.register(createFileEditTool());
    this.register(createBashTool());
    this.register(createGrepTool());
    this.register(createTaskTool());
    // ... more tools
  }
  
  private registerMCPTools(): void {
    if (!this.mcpService) return;
    
    // Watch for MCP tool changes
    this.mcpService.observeTools().subscribe(tools => {
      // Unregister old MCP tools
      for (const [name, tool] of this.tools) {
        if (tool.spec.source.mcp) {
          this.tools.delete(name);
        }
      }
      
      // Register new MCP tools
      for (const mcpTool of tools) {
        this.register({
          spec: {
            name: mcpTool.name,
            description: mcpTool.description,
            inputSchema: mcpTool.inputSchema,
            source: { mcp: mcpTool.serverId }
          },
          fn: (args, env) => this.callMCPTool(mcpTool, args, env)
        });
      }
    });
  }
  
  async callTool(
    name: string,
    args: unknown,
    env: ToolEnvironment
  ): Promise<Observable<ToolRun>> {
    const tool = this.getEnabledTool(name);
    if (!tool) {
      throw new Error(`Tool ${name} not found or disabled`);
    }
    
    // Create execution context
    const callId = generateId();
    const run$ = new BehaviorSubject<ToolRun>({ status: 'queued' });
    
    this.activeCalls.set(callId, {
      tool,
      run$,
      startTime: Date.now(),
      env
    });
    
    // Execute asynchronously
    this.executeTool(callId, tool, args, env).catch(error => {
      run$.next({ status: 'error', error: error.message });
      run$.complete();
    });
    
    return run$.asObservable();
  }
  
  private async executeTool(
    callId: string,
    tool: ToolRegistration<any>,
    args: unknown,
    env: ToolEnvironment
  ): Promise<void> {
    const run$ = this.activeCalls.get(callId)!.run$;
    
    try {
      // Check permissions
      const permission = await this.checkPermission(tool, args, env);
      if (permission.requiresApproval) {
        run$.next({ 
          status: 'blocked-on-user',
          toAllow: permission.toAllow 
        });
        
        const approved = await this.waitForApproval(callId);
        if (!approved) {
          run$.next({ status: 'rejected-by-user' });
          return;
        }
      }
      
      // Preprocess arguments
      if (tool.preprocessArgs) {
        args = await tool.preprocessArgs(args, env);
      }
      
      // Start execution
      run$.next({ status: 'in-progress' });
      
      // Track file changes
      const fileTracker = this.fileTracker.startTracking(callId);
      
      // Execute with timeout
      const result = await this.withTimeout(
        tool.fn(args, {
          ...env,
          onProgress: (progress) => {
            run$.next({ 
              status: 'in-progress',
              progress 
            });
          }
        }),
        env.timeout || 120000 // 2 minute default
      );
      
      // Get modified files
      const files = await fileTracker.getModifiedFiles();
      
      run$.next({ 
        status: 'done',
        result,
        files 
      });
      
    } finally {
      run$.complete();
      this.activeCalls.delete(callId);
    }
  }
}
```

## File Change Tracking

Every tool operation tracks file modifications for auditability and rollback:

```typescript
export class FileChangeTracker {
  private changes = new Map<string, FileChangeRecord[]>();
  private backupDir: string;
  
  constructor() {
    this.backupDir = path.join(os.tmpdir(), 'amp-backups');
  }
  
  startTracking(operationId: string): FileOperationTracker {
    const tracker = new FileOperationTracker(operationId, this);
    
    // Set up file system monitoring
    const fsWatcher = chokidar.watch('.', {
      ignored: /(^|[\/\\])\../, // Skip hidden files
      persistent: true,
      awaitWriteFinish: {
        stabilityThreshold: 100,
        pollInterval: 50
      }
    });
    
    // Track different types of file changes
    fsWatcher.on('change', async (filePath) => {
      await tracker.recordModification(filePath, 'modify');
    });
    
    fsWatcher.on('add', async (filePath) => {
      await tracker.recordModification(filePath, 'create');
    });
    
    fsWatcher.on('unlink', async (filePath) => {
      await tracker.recordModification(filePath, 'delete');
    });
    
    return tracker;
  }
  
  async recordChange(
    operationId: string,
    filePath: string,
    type: 'create' | 'modify' | 'delete',
    content?: string
  ): Promise<void> {
    const changes = this.changes.get(operationId) || [];
    
    // Create backup of original
    const backupPath = path.join(
      this.backupDir,
      operationId,
      filePath
    );
    
    if (type !== 'create') {
      try {
        const original = await fs.readFile(filePath, 'utf-8');
        await fs.mkdir(path.dirname(backupPath), { recursive: true });
        await fs.writeFile(backupPath, original);
      } catch (error) {
        // File might already be deleted
      }
    }
    
    changes.push({
      id: generateId(),
      filePath,
      type,
      timestamp: Date.now(),
      backupPath: type !== 'create' ? backupPath : undefined,
      newContent: content,
      operationId
    });
    
    this.changes.set(operationId, changes);
  }
  
  async rollback(operationId: string): Promise<void> {
    const changes = this.changes.get(operationId) || [];
    
    // Rollback in reverse order
    for (const change of changes.reverse()) {
      try {
        switch (change.type) {
          case 'create':
            // Delete created file
            await fs.unlink(change.filePath);
            break;
            
          case 'modify':
            // Restore from backup
            if (change.backupPath) {
              const backup = await fs.readFile(change.backupPath, 'utf-8');
              await fs.writeFile(change.filePath, backup);
            }
            break;
            
          case 'delete':
            // Restore deleted file
            if (change.backupPath) {
              const backup = await fs.readFile(change.backupPath, 'utf-8');
              await fs.writeFile(change.filePath, backup);
            }
            break;
        }
      } catch (error) {
        logger.error(`Failed to rollback ${change.filePath}:`, error);
      }
    }
    
    // Clean up backups
    const backupDir = path.join(this.backupDir, operationId);
    await fs.rm(backupDir, { recursive: true, force: true });
    
    this.changes.delete(operationId);
  }
}
```

## Tool Security and Permissions

Amp implements defense-in-depth for tool security:

### Layer 1: Tool Enablement

```typescript
export function toolEnablement(
  tool: ToolSpec,
  config: Config
): ToolStatusEnablement {
  // Check if tool is explicitly disabled
  const disabled = config.get('tools.disable', []);
  
  if (disabled.includes('*')) {
    return { enabled: false, reason: 'All tools disabled' };
  }
  
  if (disabled.includes(tool.name)) {
    return { enabled: false, reason: 'Tool explicitly disabled' };
  }
  
  // Check source-based disabling
  if (tool.source.mcp && disabled.includes('mcp:*')) {
    return { enabled: false, reason: 'MCP tools disabled' };
  }
  
  // Check feature flags
  if (tool.name === 'task' && !config.get('subagents.enabled')) {
    return { enabled: false, reason: 'Sub-agents not enabled' };
  }
  
  return { enabled: true };
}
```

### Layer 2: Command Approval

```typescript
export class CommandApprovalService {
  private userAllowlist: Set<string>;
  private sessionAllowlist: Set<string>;
  
  async checkCommand(
    command: string,
    workingDir: string
  ): Promise<ApprovalResult> {
    const parsed = this.parseCommand(command);
    const validation = this.validateCommand(parsed, workingDir);
    
    if (!validation.safe) {
      return {
        approved: false,
        requiresApproval: true,
        reason: validation.reason,
        toAllow: validation.suggestions
      };
    }
    
    // Check allowlists
    if (this.isAllowed(command)) {
      return { approved: true };
    }
    
    // Check if it's a safe read-only command
    if (this.isSafeCommand(parsed.command)) {
      return { approved: true };
    }
    
    // Requires user approval
    return {
      approved: false,
      requiresApproval: true,
      toAllow: [command, parsed.command, '*']
    };
  }
  
  private isSafeCommand(cmd: string): boolean {
    const SAFE_COMMANDS = [
      'ls', 'pwd', 'echo', 'cat', 'grep', 'find', 'head', 'tail',
      'wc', 'sort', 'uniq', 'diff', 'git status', 'git log',
      'npm list', 'yarn list', 'pip list'
    ];
    
    return SAFE_COMMANDS.some(safe => 
      cmd === safe || cmd.startsWith(safe + ' ')
    );
  }
  
  private validateCommand(
    parsed: ParsedCommand,
    workingDir: string
  ): ValidationResult {
    // Check for path traversal
    for (const arg of parsed.args) {
      if (arg.includes('../') || arg.includes('..\\')) {
        return {
          safe: false,
          reason: 'Path traversal detected'
        };
      }
    }
    
    // Check for dangerous commands
    const DANGEROUS = ['rm -rf', 'dd', 'format', ':(){ :|:& };:'];
    if (DANGEROUS.some(d => parsed.full.includes(d))) {
      return {
        safe: false,
        reason: 'Potentially dangerous command'
      };
    }
    
    // Check for output redirection to sensitive files
    if (parsed.full.match(/>\s*\/etc|>\s*~\/\.|>\s*\/sys/)) {
      return {
        safe: false,
        reason: 'Output redirection to sensitive location'
      };
    }
    
    return { safe: true };
  }
}
```

### Layer 3: Resource Limits

```typescript
export class ResourceLimiter {
  private limits: ResourceLimits = {
    maxOutputSize: 50_000,         // 50KB
    maxExecutionTime: 120_000,     // 2 minutes
    maxConcurrentTools: 10,
    maxFileSize: 10_000_000,       // 10MB
    maxFilesPerOperation: 100
  };
  
  async enforceOutputLimit(
    stream: Readable,
    limit = this.limits.maxOutputSize
  ): Promise<string> {
    let output = '';
    let truncated = false;
    
    for await (const chunk of stream) {
      output += chunk;
      
      if (output.length > limit) {
        output = output.slice(0, limit);
        truncated = true;
        break;
      }
    }
    
    if (truncated) {
      output += '\n\n[Output truncated - exceeded 50KB limit]';
    }
    
    return output;
  }
  
  createTimeout(ms = this.limits.maxExecutionTime): AbortSignal {
    const controller = new AbortController();
    
    const timeout = setTimeout(() => {
      controller.abort(new Error(`Operation timed out after ${ms}ms`));
    }, ms);
    
    // Clean up timeout if operation completes
    controller.signal.addEventListener('abort', () => {
      clearTimeout(timeout);
    });
    
    return controller.signal;
  }
  
  async checkFileLimits(files: string[]): Promise<void> {
    if (files.length > this.limits.maxFilesPerOperation) {
      throw new Error(
        `Too many files (${files.length}). ` +
        `Maximum ${this.limits.maxFilesPerOperation} files per operation.`
      );
    }
    
    for (const file of files) {
      const stats = await fs.stat(file);
      if (stats.size > this.limits.maxFileSize) {
        throw new Error(
          `File ${file} exceeds size limit ` +
          `(${stats.size} > ${this.limits.maxFileSize})`
        );
      }
    }
  }
}
```

## External Tool Integration

Amp supports external tool integration through standardized protocols:

```typescript
// Manages connections to external tool providers
export class ExternalToolService {
  private activeConnections = new Map<string, ToolProvider>();
  private availableTools$ = new BehaviorSubject<ExternalTool[]>([]);
  
  constructor(private configService: ConfigService) {
    this.initializeProviders();
  }
  
  private async initializeProviders(): Promise<void> {
    const providers = this.configService.get('external.toolProviders', {});
    
    for (const [name, config] of Object.entries(providers)) {
      try {
        const provider = await this.createProvider(name, config);
        this.activeConnections.set(name, provider);
        
        // Monitor tool availability changes
        provider.observeTools().subscribe(tools => {
          this.updateAvailableTools();
        });
      } catch (error) {
        console.error(`Failed to initialize tool provider ${name}:`, error);
      }
    }
  }
  
  private async createProvider(
    name: string,
    config: ProviderConfig
  ): Promise<ToolProvider> {
    if (config.type === 'stdio') {
      return new StdioToolProvider(name, config);
    } else if (config.type === 'http') {
      return new HTTPToolProvider(name, config);
    }
    
    throw new Error(`Unknown tool provider type: ${config.type}`);
  }
  
  observeAvailableTools(): Observable<ExternalTool[]> {
    return this.availableTools$.asObservable();
  }
  
  async executeTool(
    providerId: string,
    toolName: string,
    args: unknown
  ): Promise<unknown> {
    const provider = this.activeConnections.get(providerId);
    if (!provider) {
      throw new Error(`Tool provider ${providerId} not found`);
    }
    
    return provider.executeTool({ name: toolName, arguments: args });
  }
}

// Example stdio-based tool provider implementation
class StdioToolProvider implements ToolProvider {
  private childProcess: ChildProcess;
  private availableTools = new BehaviorSubject<Tool[]>([]);
  
  constructor(
    private providerName: string,
    private configuration: StdioProviderConfig
  ) {
    this.spawnProcess();
  }
  
  private spawnProcess(): void {
    this.childProcess = spawn(this.configuration.command, this.configuration.args, {
      stdio: ['pipe', 'pipe', 'pipe'],
      env: { ...process.env, ...this.configuration.env }
    });
    
    // Set up communication channel
    const transport = new StdioTransport(
      this.childProcess.stdin,
      this.childProcess.stdout
    );
    
    this.rpcClient = new JSONRPCClient(transport);
    
    // Initialize provider connection
    this.initializeConnection();
  }
  
  private async initializeConnection(): Promise<void> {
    // Send initialization handshake
    const response = await this.rpcClient.request('initialize', {
      protocolVersion: '1.0',
      clientInfo: {
        name: 'amp',
        version: this.configuration.version
      }
    });
    
    // Request available tools list
    const toolsResponse = await this.rpcClient.request('tools/list', {});
    this.availableTools.next(toolsResponse.tools);
  }
  
  observeTools(): Observable<Tool[]> {
    return this.availableTools.asObservable();
  }
  
  async executeTool(params: ToolExecutionParams): Promise<unknown> {
    const response = await this.rpcClient.request('tools/execute', params);
    return response.result;
  }
  
  async dispose(): Promise<void> {
    this.childProcess.kill();
    await new Promise(resolve => this.childProcess.once('exit', resolve));
  }
}
```

## Sub-Agent Orchestration

The Task tool enables hierarchical execution for complex workflows:

```typescript
// Implements delegated task execution through sub-agents
export class TaskTool implements Tool {
  name = 'task';
  description = 'Delegate a specific task to a specialized sub-agent';
  
  async execute(
    args: { prompt: string; context?: string },
    env: ToolEnvironment
  ): Promise<Observable<TaskProgress>> {
    const progress$ = new Subject<TaskProgress>();
    
    // Initialize sub-agent with restricted capabilities
    const subAgent = new SubAgent({
      availableTools: this.getRestrictedToolSet(),
      systemPrompt: this.constructSystemPrompt(args.context),
      taskDescription: args.prompt,
      environment: {
        ...env,
        threadId: `${env.threadId}:subtask:${this.generateTaskId()}`,
        isSubAgent: true
      }
    });
    
    // Stream execution progress
    subAgent.observeExecutionStatus().subscribe(status => {
      progress$.next({
        type: 'status',
        state: status.currentState,
        message: status.description
      });
    });
    
    subAgent.observeToolExecutions().subscribe(toolExecution => {
      progress$.next({
        type: 'tool-execution',
        toolName: toolExecution.name,
        arguments: toolExecution.args,
        result: toolExecution.result
      });
    });
    
    // Begin asynchronous execution
    this.executeSubAgent(subAgent, progress$);
    
    return progress$.asObservable();
  }
  
  private getRestrictedToolSet(): Tool[] {
    // Sub-agents operate with limited tool access for safety
    return [
      'read_file',
      'write_file', 
      'edit_file',
      'list_directory',
      'search',
      'bash' // With enhanced restrictions
    ].map(name => this.toolService.getToolByName(name))
     .filter(Boolean);
  }
  
  private async executeSubAgent(
    agent: SubAgent,
    progress$: Subject<TaskProgress>
  ): Promise<void> {
    try {
      const executionResult = await agent.executeTask();
      
      progress$.next({
        type: 'complete',
        summary: executionResult.taskSummary,
        toolExecutions: executionResult.toolExecutions,
        modifiedFiles: executionResult.modifiedFiles
      });
      
    } catch (error) {
      progress$.next({
        type: 'error',
        errorMessage: error.message
      });
    } finally {
      progress$.complete();
      agent.cleanup();
    }
  }
}

// Sub-agent implementation with isolated execution context
export class SubAgent {
  private toolService: ToolService;
  private llmService: LLMService;
  private changeTracker: FileChangeTracker;
  
  constructor(private configuration: SubAgentConfig) {
    // Create restricted tool service for sub-agent
    this.toolService = new ToolService({
      availableTools: configuration.availableTools,
      permissionLevel: 'restricted'
    });
    
    this.changeTracker = new FileChangeTracker();
  }
  
  async executeTask(): Promise<SubAgentResult> {
    const conversationHistory: Message[] = [
      {
        role: 'system',
        content: this.configuration.systemPrompt || DEFAULT_SUB_AGENT_PROMPT
      },
      {
        role: 'user',
        content: this.configuration.taskDescription
      }
    ];
    
    const maxExecutionCycles = 10;
    let currentCycle = 0;
    
    while (currentCycle < maxExecutionCycles) {
      currentCycle++;
      
      // Generate next response
      const llmResponse = await this.llmService.generateResponse({
        messages: conversationHistory,
        availableTools: this.toolService.getToolSchemas(),
        temperature: 0.2, // Lower temperature for focused task execution
        maxTokens: 4000
      });
      
      conversationHistory.push(llmResponse.message);
      
      // Execute any tool calls
      if (llmResponse.toolCalls) {
        const toolResults = await this.executeToolCalls(llmResponse.toolCalls);
        conversationHistory.push({
          role: 'tool',
          content: toolResults
        });
        continue;
      }
      
      // Task completed
      break;
    }
    
    return {
      taskSummary: this.generateTaskSummary(conversationHistory),
      toolExecutions: this.changeTracker.getExecutionHistory(),
      modifiedFiles: await this.changeTracker.getModifiedFiles()
    };
  }
}
```

## Performance Optimization Strategies

Amp employs several techniques to maintain tool execution performance:

### 1. Parallel Tool Execution

```typescript
// Executes independent tools in parallel while respecting dependencies
export class ParallelToolExecutor {
  async executeToolBatch(
    toolCalls: ToolCall[]
  ): Promise<ToolResult[]> {
    // Analyze dependencies and group tools
    const executionGroups = this.analyzeExecutionDependencies(toolCalls);
    
    const allResults: ToolResult[] = [];
    
    // Execute groups sequentially, tools within groups in parallel
    for (const group of executionGroups) {
      const groupResults = await Promise.all(
        group.map(call => this.executeSingleTool(call))
      );
      allResults.push(...groupResults);
    }
    
    return allResults;
  }
  
  private analyzeExecutionDependencies(calls: ToolCall[]): ToolCall[][] {
    const executionGroups: ToolCall[][] = [];
    const processedCalls = new Set<string>();
    
    for (const call of calls) {
      // Identify tool dependencies (e.g., file reads before writes)
      const dependencies = this.identifyDependencies(call, calls);
      
      // Find suitable execution group
      let targetGroup = executionGroups.length;
      for (let i = 0; i < executionGroups.length; i++) {
        const groupCallIds = new Set(executionGroups[i].map(c => c.id));
        const hasBlockingDependency = dependencies.some(dep => groupCallIds.has(dep));
        
        if (!hasBlockingDependency) {
          targetGroup = i;
          break;
        }
      }
      
      if (targetGroup === executionGroups.length) {
        executionGroups.push([]);
      }
      
      executionGroups[targetGroup].push(call);
    }
    
    return executionGroups;
  }
}
```

### 2. Intelligent Result Caching

```typescript
// Caches tool results for read-only operations with dependency tracking
export class CachingToolExecutor {
  private resultCache = new LRUCache<string, CachedResult>({
    max: 1000,
    ttl: 1000 * 60 * 5 // 5-minute TTL
  });
  
  async executeWithCaching(
    tool: Tool,
    args: unknown,
    env: ToolEnvironment
  ): Promise<unknown> {
    // Generate cache key from tool and arguments
    const cacheKey = this.generateCacheKey(tool.name, args, env);
    
    // Check cache for read-only operations
    if (tool.spec.metadata?.readonly) {
      const cachedResult = this.resultCache.get(cacheKey);
      if (cachedResult && !this.isCacheStale(cachedResult)) {
        return cachedResult.result;
      }
    }
    
    // Execute tool and get result
    const result = await tool.implementation(args, env);
    
    // Cache result if tool is cacheable
    if (tool.spec.metadata?.cacheable) {
      this.resultCache.set(cacheKey, {
        result,
        timestamp: Date.now(),
        dependencies: await this.extractFileDependencies(tool, args)
      });
    }
    
    return result;
  }
  
  private isCacheStale(cached: CachedResult): boolean {
    // Check if dependent files have been modified since caching
    for (const dependency of cached.dependencies) {
      const currentModTime = fs.statSync(dependency.path).mtime.getTime();
      if (currentModTime > cached.timestamp) {
        return true;
      }
    }
    
    return false;
  }
}
```

### 3. Streaming Output for Long-Running Operations

```typescript
// Provides real-time output streaming for shell command execution
export class StreamingCommandTool implements Tool {
  async execute(
    args: { command: string },
    env: ToolEnvironment
  ): Promise<Observable<CommandProgress>> {
    const progress$ = new Subject<CommandProgress>();
    
    const process = spawn('bash', ['-c', args.command], {
      cwd: env.workingDirectory,
      env: env.environmentVariables
    });
    
    // Stream standard output
    process.stdout.on('data', (chunk) => {
      progress$.next({
        type: 'stdout',
        content: chunk.toString()
      });
    });
    
    // Stream error output
    process.stderr.on('data', (chunk) => {
      progress$.next({
        type: 'stderr',
        content: chunk.toString()
      });
    });
    
    // Handle process completion
    process.on('exit', (exitCode) => {
      progress$.next({
        type: 'completion',
        exitCode
      });
      progress$.complete();
    });
    
    // Handle process errors
    process.on('error', (error) => {
      progress$.error(error);
    });
    
    return progress$.asObservable();
  }
}
```

## Tool Testing Infrastructure

Amp provides comprehensive testing utilities for tool development:

```typescript
// Test harness for isolated tool testing
export class ToolTestHarness {
  private mockFileSystem = new MockFileSystem();
  private mockProcessManager = new MockProcessManager();
  
  async runToolTest(
    tool: Tool,
    testScenario: TestScenario
  ): Promise<TestResult> {
    // Initialize mock environment
    this.mockFileSystem.setup(testScenario.initialFiles);
    this.mockProcessManager.setup(testScenario.processesSetup);
    
    const testEnvironment: ToolEnvironment = {
      workingDirectory: '/test-workspace',
      fileSystem: this.mockFileSystem,
      processManager: this.mockProcessManager,
      ...testScenario.environment
    };
    
    // Execute tool under test
    const executionResult = await tool.execute(testScenario.arguments, testEnvironment);
    
    // Validate results against expectations
    const validationErrors: string[] = [];
    
    // Verify file system changes
    for (const expectedFile of testScenario.expectedFiles) {
      const actualContent = this.mockFileSystem.readFileSync(expectedFile.path);
      if (actualContent !== expectedFile.content) {
        validationErrors.push(
          `File ${expectedFile.path} content mismatch:\n` +
          `Expected: ${expectedFile.content}\n` +
          `Actual: ${actualContent}`
        );
      }
    }
    
    // Verify process executions
    const actualProcessCalls = this.mockProcessManager.getExecutionHistory();
    if (testScenario.expectedProcessCalls) {
      // Validate process call expectations
    }
    
    return {
      passed: validationErrors.length === 0,
      validationErrors,
      executionResult
    };
  }
}

// Example test scenario
const editFileScenario: TestScenario = {
  tool: 'edit_file',
  args: {
    path: 'test.js',
    old_string: 'console.log("hello")',
    new_string: 'console.log("goodbye")'
  },
  files: {
    'test.js': 'console.log("hello")\nmore code'
  },
  expectedFiles: [{
    path: 'test.js',
    content: 'console.log("goodbye")\nmore code'
  }]
};
```

## Summary

This chapter explored the evolution from simple tool execution to sophisticated orchestration systems:

- **Observable execution patterns** enable progress tracking and cancellation
- **Layered security architectures** protect against dangerous operations
- **Comprehensive audit trails** provide rollback and accountability
- **External integration protocols** allow third-party tool extensions
- **Hierarchical execution models** enable complex multi-tool workflows
- **Resource management systems** prevent abuse and runaway processes
- **Performance optimization strategies** maintain responsiveness at scale

The key insight: modern tool systems must balance expressive power with safety constraints, extensibility with security, and performance with correctness through architectural discipline.

The next chapter examines collaboration and permission systems that enable secure multi-user workflows while preserving privacy and control.