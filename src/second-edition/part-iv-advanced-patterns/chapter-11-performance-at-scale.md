# Chapter 11: Performance Patterns at Scale

Running an AI coding assistant for a handful of developers differs dramatically from serving thousands of concurrent users. When AI processes complex refactoring requests that spawn multiple sub-agents, each analyzing different parts of a codebase, the computational demands multiply quickly. Add real-time synchronization, file system operations, and LLM inference costs, and performance becomes the make-or-break factor for production viability.

This chapter explores performance patterns that enable AI coding assistants to scale from proof-of-concept to production systems serving entire engineering organizations. We'll examine caching strategies, database optimizations, edge computing patterns, and load balancing approaches that maintain sub-second response times even under heavy load.

## The Performance Challenge

AI coding assistants face unique performance constraints compared to traditional web applications:

```typescript
// A single user interaction might trigger:
- Multiple model inference calls (coordinators + specialized agents)
- Dozens of file system operations
- Real-time synchronization across platforms
- Tool executions that spawn processes
- Code analysis across thousands of files
- Version control operations on large repositories
```

Consider what happens when a user asks an AI assistant to "refactor this authentication system to use OAuth":

1. **Initial Analysis** - The system reads dozens of files to understand the current auth implementation
2. **Planning** - Model generates a refactoring plan, potentially coordinating multiple agents
3. **Execution** - Multiple tools modify files, run tests, and verify changes
4. **Synchronization** - All changes sync across environments and collaborators
5. **Persistence** - Conversation history, file changes, and metadata save to storage

Each step has opportunities for optimization—and potential bottlenecks that can degrade the user experience.

## Caching Strategies

The most effective performance optimization is avoiding work entirely. Multi-layered caching minimizes redundant operations:

### Model Response Caching

Model inference represents the largest latency and cost factor. Intelligent caching can dramatically improve performance:

```typescript
class ModelResponseCache {
  private memoryCache = new Map<string, CachedResponse>();
  private persistentCache: PersistentStorage;
  private readonly config: CacheConfiguration;
  
  constructor(config: CacheConfiguration) {
    this.config = {
      maxMemoryEntries: 1000,
      ttlMs: 3600000, // 1 hour
      persistHighValue: true,
      ...config
    };
    
    this.initializePersistentCache();
  }
  
  async get(
    request: ModelRequest
  ): Promise<CachedResponse | null> {
    // Generate stable cache key from request parameters
    const key = this.generateCacheKey(request);
    
    // Check memory cache first (fastest)
    const memoryResult = this.memoryCache.get(key);
    if (memoryResult && this.isValid(memoryResult)) {
      this.updateAccessMetrics(memoryResult);
      return memoryResult;
    }
    
    // Check persistent cache (slower but larger)
    const persistentResult = await this.persistentCache.get(key);
    if (persistentResult && this.isValid(persistentResult)) {
      // Promote to memory cache
      this.memoryCache.set(key, persistentResult);
      return persistentResult;
    }
    
    return null;
  }
  
  async set(
    messages: Message[],
    model: string,
    temperature: number,
    response: LLMResponse
  ): Promise<void> {
    const key = this.generateCacheKey(messages, model, temperature);
    
    const cached: CachedResponse = {
      key,
      messages,
      model,
      temperature,
      response,
      timestamp: Date.now(),
      lastAccessed: Date.now(),
      hitCount: 0
    };
    
    this.cache.set(key, cached);
    
    // Evict old entries if cache is full
    if (this.cache.size > this.MAX_CACHE_SIZE) {
      this.evictLRU();
    }
    
    // Persist high-value entries
    if (this.shouldPersist(cached)) {
      await this.persistEntry(key, cached);
    }
  }
  
  private generateCacheKey(
    messages: Message[],
    model: string,
    temperature: number
  ): string {
    // Only cache deterministic requests (temperature = 0)
    if (temperature > 0) {
      return crypto.randomUUID(); // Unique key = no caching
    }
    
    // Create stable key from messages
    const messageHash = crypto
      .createHash('sha256')
      .update(JSON.stringify(messages))
      .digest('hex');
    
    return `${model}:${temperature}:${messageHash}`;
  }
  
  private evictLRU(): void {
    // Find least recently used entry
    let lruKey: string | null = null;
    let lruTime = Infinity;
    
    for (const [key, entry] of this.cache) {
      if (entry.lastAccessed < lruTime) {
        lruTime = entry.lastAccessed;
        lruKey = key;
      }
    }
    
    if (lruKey) {
      this.cache.delete(lruKey);
    }
  }
  
  private shouldPersist(entry: CachedResponse): boolean {
    // Persist frequently accessed or expensive responses
    return entry.hitCount > 5 || 
           entry.response.usage.totalTokens > 4000;
  }
}
```

### File System Caching

File operations are frequent and can be expensive, especially on network filesystems:

```typescript
export class FileSystemCache {
  private contentCache = new Map<string, FileCacheEntry>();
  private statCache = new Map<string, StatCacheEntry>();
  
  // Watch for file changes to invalidate cache
  private watcher = chokidar.watch([], {
    persistent: true,
    ignoreInitial: true
  });
  
  constructor() {
    this.watcher.on('change', path => this.invalidate(path));
    this.watcher.on('unlink', path => this.invalidate(path));
  }
  
  async readFile(path: string): Promise<string> {
    const cached = this.contentCache.get(path);
    
    if (cached) {
      // Verify cache validity
      const stats = await fs.stat(path);
      if (stats.mtimeMs <= cached.mtime) {
        cached.hits++;
        return cached.content;
      }
    }
    
    // Cache miss - read from disk
    const content = await fs.readFile(path, 'utf-8');
    const stats = await fs.stat(path);
    
    this.contentCache.set(path, {
      content,
      mtime: stats.mtimeMs,
      size: stats.size,
      hits: 0
    });
    
    // Start watching this file
    this.watcher.add(path);
    
    return content;
  }
  
  async glob(pattern: string, options: GlobOptions = {}): Promise<string[]> {
    const cacheKey = `${pattern}:${JSON.stringify(options)}`;
    
    // Use cached result if recent enough
    const cached = this.globCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < 5000) {
      return cached.results;
    }
    
    const results = await fastGlob(pattern, options);
    
    this.globCache.set(cacheKey, {
      results,
      timestamp: Date.now()
    });
    
    return results;
  }
  
  private invalidate(path: string): void {
    this.contentCache.delete(path);
    this.statCache.delete(path);
    
    // Invalidate glob results that might include this file
    for (const [key, entry] of this.globCache) {
      if (this.mightMatch(path, key)) {
        this.globCache.delete(key);
      }
    }
  }
}
```

### Repository Analysis Caching

Code intelligence features require analyzing repository structure, which can be computationally expensive:

```typescript
export class RepositoryAnalysisCache {
  private repoMapCache = new Map<string, RepoMapCache>();
  private dependencyCache = new Map<string, DependencyGraph>();
  
  async getRepoMap(
    rootPath: string,
    options: RepoMapOptions = {}
  ): Promise<RepoMap> {
    const cached = this.repoMapCache.get(rootPath);
    
    if (cached && this.isCacheValid(cached)) {
      return cached.repoMap;
    }
    
    // Generate new repo map
    const repoMap = await this.generateRepoMap(rootPath, options);
    
    // Cache with metadata
    this.repoMapCache.set(rootPath, {
      repoMap,
      timestamp: Date.now(),
      gitCommit: await this.getGitCommit(rootPath),
      fileCount: repoMap.files.length
    });
    
    return repoMap;
  }
  
  private async isCacheValid(cache: RepoMapCache): Promise<boolean> {
    // Invalidate if git commit changed
    const currentCommit = await this.getGitCommit(cache.rootPath);
    if (currentCommit !== cache.gitCommit) {
      return false;
    }
    
    // Invalidate if too old
    const age = Date.now() - cache.timestamp;
    if (age > 300000) { // 5 minutes
      return false;
    }
    
    // Sample a few files to check for changes
    const samplesToCheck = Math.min(10, cache.fileCount);
    const samples = this.selectRandomSamples(cache.repoMap.files, samplesToCheck);
    
    for (const file of samples) {
      try {
        const stats = await fs.stat(file.path);
        if (stats.mtimeMs > cache.timestamp) {
          return false;
        }
      } catch {
        // File deleted
        return false;
      }
    }
    
    return true;
  }
}
```

## Database Optimization

Conversation storage requires careful optimization to handle millions of interactions efficiently:

### Indexed Storage Schema

Efficient conversation storage uses layered database architecture with strategic indexing:

```typescript
class ConversationDatabase {
  private storage: DatabaseAdapter;
  
  async initialize(): Promise<void> {
    await this.storage.connect();
    await this.ensureSchema();
  }
  
  private async ensureSchema(): Promise<void> {
    // Conversation metadata for quick access
    await this.storage.createTable('conversations', {
      id: 'primary_key',
      userId: 'indexed',
      teamId: 'indexed',
      title: 'indexed',
      created: 'indexed',
      lastActivity: 'indexed',
      isShared: 'indexed',
      version: 'indexed'
    });
    
    // Separate table for message content to optimize loading
    await this.storage.createTable('messages', {
      id: 'primary_key',
      conversationId: 'indexed',
      sequence: 'indexed',
      timestamp: 'indexed',
      content: 'blob',
      metadata: 'json'
    });
    
    // Lightweight summary table for listings
    await this.storage.createTable('conversation_summaries', {
      id: 'primary_key',
      title: 'indexed',
      lastMessage: 'text',
      messageCount: 'integer',
      participants: 'json'
    });
  }
  
  async getThread(id: ThreadID): Promise<Thread | null> {
    const transaction = this.db.transaction(['threads', 'messages'], 'readonly');
    const threadStore = transaction.objectStore('threads');
    const messageStore = transaction.objectStore('messages');
    
    // Get thread metadata
    const thread = await this.getFromStore(threadStore, id);
    if (!thread) return null;
    
    // Get messages separately for large threads
    if (thread.messageCount > 100) {
      const messageIndex = messageStore.index('threadId');
      const messages = await this.getAllFromIndex(messageIndex, id);
      thread.messages = messages;
    }
    
    return thread;
  }
  
  async queryThreads(
    query: ThreadQuery
  ): Promise<ThreadMeta[]> {
    const transaction = this.db.transaction(['threadMeta'], 'readonly');
    const metaStore = transaction.objectStore('threadMeta');
    
    let results: ThreadMeta[] = [];
    
    // Use index if available
    if (query.orderBy === 'lastActivity') {
      const index = metaStore.index('lastActivity');
      const range = query.after 
        ? IDBKeyRange.lowerBound(query.after, true)
        : undefined;
      
      results = await this.getCursorResults(
        index.openCursor(range, 'prev'),
        query.limit
      );
    } else {
      // Full table scan with filtering
      results = await this.getAllFromStore(metaStore);
      results = this.applyFilters(results, query);
    }
    
    return results;
  }
}
```

### Write Batching

Frequent small writes can overwhelm storage systems. Batching improves throughput:

```typescript
export class BatchedThreadWriter {
  private writeQueue = new Map<ThreadID, PendingWrite>();
  private flushTimer?: NodeJS.Timeout;
  
  constructor(
    private storage: ThreadStorage,
    private options: BatchOptions = {}
  ) {
    this.options = {
      batchSize: 50,
      flushInterval: 1000,
      maxWaitTime: 5000,
      ...options
    };
  }
  
  async write(thread: Thread): Promise<void> {
    const now = Date.now();
    
    this.writeQueue.set(thread.id, {
      thread,
      queuedAt: now,
      priority: this.calculatePriority(thread)
    });
    
    // Schedule flush
    this.scheduleFlush();
    
    // Immediate flush for high-priority writes
    if (this.shouldFlushImmediately(thread)) {
      await this.flush();
    }
  }
  
  private scheduleFlush(): void {
    if (this.flushTimer) return;
    
    this.flushTimer = setTimeout(() => {
      this.flush().catch(error => 
        logger.error('Batch flush failed:', error)
      );
    }, this.options.flushInterval);
  }
  
  private async flush(): Promise<void> {
    if (this.writeQueue.size === 0) return;
    
    // Clear timer
    if (this.flushTimer) {
      clearTimeout(this.flushTimer);
      this.flushTimer = undefined;
    }
    
    // Sort by priority and age
    const writes = Array.from(this.writeQueue.values())
      .sort((a, b) => {
        if (a.priority !== b.priority) {
          return b.priority - a.priority;
        }
        return a.queuedAt - b.queuedAt;
      });
    
    // Process in batches
    for (let i = 0; i < writes.length; i += this.options.batchSize) {
      const batch = writes.slice(i, i + this.options.batchSize);
      
      try {
        await this.storage.batchWrite(
          batch.map(w => w.thread)
        );
        
        // Remove from queue
        batch.forEach(w => this.writeQueue.delete(w.thread.id));
      } catch (error) {
        logger.error('Batch write failed:', error);
        // Keep in queue for retry
      }
    }
    
    // Schedule next flush if items remain
    if (this.writeQueue.size > 0) {
      this.scheduleFlush();
    }
  }
  
  private calculatePriority(thread: Thread): number {
    let priority = 0;
    
    // Active threads get higher priority
    if (thread.messages.length > 0) {
      const lastMessage = thread.messages[thread.messages.length - 1];
      const age = Date.now() - lastMessage.timestamp;
      if (age < 60000) priority += 10; // Active in last minute
    }
    
    // Shared threads need immediate sync
    if (thread.meta?.shared) priority += 5;
    
    // Larger threads are more important to persist
    priority += Math.min(thread.messages.length / 10, 5);
    
    return priority;
  }
}
```

## CDN and Edge Computing

Static assets and frequently accessed data benefit from edge distribution:

### Asset Optimization

Amp serves static assets through a CDN with aggressive caching:

```typescript
export class AssetOptimizer {
  private assetManifest = new Map<string, AssetEntry>();
  
  async optimizeAssets(buildDir: string): Promise<void> {
    const assets = await this.findAssets(buildDir);
    
    for (const asset of assets) {
      // Generate content hash
      const content = await fs.readFile(asset.path);
      const hash = crypto
        .createHash('sha256')
        .update(content)
        .digest('hex')
        .substring(0, 8);
      
      // Create versioned filename
      const ext = path.extname(asset.path);
      const base = path.basename(asset.path, ext);
      const hashedName = `${base}.${hash}${ext}`;
      
      // Optimize based on type
      const optimized = await this.optimizeAsset(asset, content);
      
      // Write optimized version
      const outputPath = path.join(
        buildDir, 
        'cdn',
        hashedName
      );
      await fs.writeFile(outputPath, optimized.content);
      
      // Update manifest
      this.assetManifest.set(asset.originalPath, {
        cdnPath: `/cdn/${hashedName}`,
        size: optimized.content.length,
        hash,
        headers: this.getCacheHeaders(asset.type)
      });
    }
    
    // Write manifest for runtime
    await this.writeManifest(buildDir);
  }
  
  private getCacheHeaders(type: AssetType): Headers {
    const headers = new Headers();
    
    // Immutable for versioned assets
    headers.set('Cache-Control', 'public, max-age=31536000, immutable');
    
    // Type-specific headers
    switch (type) {
      case 'javascript':
        headers.set('Content-Type', 'application/javascript');
        break;
      case 'css':
        headers.set('Content-Type', 'text/css');
        break;
      case 'wasm':
        headers.set('Content-Type', 'application/wasm');
        break;
    }
    
    // Enable compression
    headers.set('Content-Encoding', 'gzip');
    
    return headers;
  }
}
```

### Edge Function Patterns

Compute at the edge reduces latency for common operations:

```typescript
export class EdgeFunctionRouter {
  // Deployed to Cloudflare Workers or similar
  async handleRequest(request: Request): Promise<Response> {
    const url = new URL(request.url);
    
    // Handle different edge-optimized endpoints
    switch (url.pathname) {
      case '/api/threads/list':
        return this.handleThreadList(request);
        
      case '/api/auth/verify':
        return this.handleAuthVerification(request);
        
      case '/api/assets/repomap':
        return this.handleRepoMapRequest(request);
        
      default:
        // Pass through to origin
        return fetch(request);
    }
  }
  
  private async handleThreadList(
    request: Request
  ): Promise<Response> {
    const cache = caches.default;
    const cacheKey = new Request(request.url, {
      method: 'GET',
      headers: {
        'Authorization': request.headers.get('Authorization') || ''
      }
    });
    
    // Check cache
    const cached = await cache.match(cacheKey);
    if (cached) {
      return cached;
    }
    
    // Fetch from origin
    const response = await fetch(request);
    
    // Cache successful responses
    if (response.ok) {
      const headers = new Headers(response.headers);
      headers.set('Cache-Control', 'private, max-age=60');
      
      const cachedResponse = new Response(response.body, {
        status: response.status,
        statusText: response.statusText,
        headers
      });
      
      await cache.put(cacheKey, cachedResponse.clone());
      return cachedResponse;
    }
    
    return response;
  }
  
  private async handleAuthVerification(
    request: Request
  ): Promise<Response> {
    const token = request.headers.get('Authorization')?.split(' ')[1];
    if (!token) {
      return new Response('Unauthorized', { status: 401 });
    }
    
    // Verify JWT at edge
    try {
      const payload = await this.verifyJWT(token);
      
      // Add user info to request headers
      const headers = new Headers(request.headers);
      headers.set('X-User-Id', payload.sub);
      headers.set('X-User-Email', payload.email);
      
      // Forward to origin with verified user
      return fetch(request, { headers });
      
    } catch (error) {
      return new Response('Invalid token', { status: 401 });
    }
  }
}
```

### Global Thread Sync

Edge presence enables efficient global synchronization:

```typescript
export class GlobalSyncCoordinator {
  private regions = ['us-east', 'eu-west', 'ap-south'];
  
  async syncThread(
    thread: Thread,
    originRegion: string
  ): Promise<void> {
    // Write to origin region first
    await this.writeToRegion(thread, originRegion);
    
    // Fan out to other regions asynchronously
    const otherRegions = this.regions.filter(r => r !== originRegion);
    
    await Promise.all(
      otherRegions.map(region => 
        this.replicateToRegion(thread, region)
          .catch(error => {
            logger.error(`Failed to replicate to ${region}:`, error);
            // Queue for retry
            this.queueReplication(thread.id, region);
          })
      )
    );
  }
  
  private async writeToRegion(
    thread: Thread,
    region: string
  ): Promise<void> {
    const endpoint = this.getRegionalEndpoint(region);
    
    const response = await fetch(`${endpoint}/api/threads/${thread.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-Sync-Version': thread.v.toString(),
        'X-Origin-Region': region
      },
      body: JSON.stringify(thread)
    });
    
    if (!response.ok) {
      throw new Error(`Regional write failed: ${response.status}`);
    }
  }
  
  async readThread(
    threadId: ThreadID,
    userRegion: string
  ): Promise<Thread | null> {
    // Try local region first
    const localThread = await this.readFromRegion(threadId, userRegion);
    if (localThread) {
      return localThread;
    }
    
    // Fall back to other regions
    for (const region of this.regions) {
      if (region === userRegion) continue;
      
      try {
        const thread = await this.readFromRegion(threadId, region);
        if (thread) {
          // Replicate to user's region for next time
          this.replicateToRegion(thread, userRegion)
            .catch(() => {}); // Best effort
          return thread;
        }
      } catch {
        continue;
      }
    }
    
    return null;
  }
}
```

## Load Balancing Patterns

Distributing load across multiple servers requires intelligent routing:

### Session Affinity

AI conversations benefit from session affinity to maximize cache hits:

```typescript
export class SessionAwareLoadBalancer {
  private servers: ServerPool[] = [];
  private sessionMap = new Map<string, string>();
  
  async routeRequest(
    request: Request,
    sessionId: string
  ): Promise<Response> {
    // Check for existing session affinity
    let targetServer = this.sessionMap.get(sessionId);
    
    if (!targetServer || !this.isServerHealthy(targetServer)) {
      // Select new server based on load
      targetServer = await this.selectServer(request);
      this.sessionMap.set(sessionId, targetServer);
    }
    
    // Route to selected server
    return this.forwardRequest(request, targetServer);
  }
  
  private async selectServer(
    request: Request
  ): Promise<string> {
    const healthyServers = this.servers.filter(s => s.healthy);
    
    if (healthyServers.length === 0) {
      throw new Error('No healthy servers available');
    }
    
    // Consider multiple factors
    const scores = await Promise.all(
      healthyServers.map(async server => ({
        server,
        score: await this.calculateServerScore(server, request)
      }))
    );
    
    // Select server with best score
    scores.sort((a, b) => b.score - a.score);
    return scores[0].server.id;
  }
  
  private async calculateServerScore(
    server: ServerPool,
    request: Request
  ): Promise<number> {
    let score = 100;
    
    // Current load (lower is better)
    score -= server.currentConnections / server.maxConnections * 50;
    
    // CPU usage
    score -= server.cpuUsage * 30;
    
    // Memory availability
    score -= (1 - server.memoryAvailable / server.memoryTotal) * 20;
    
    // Geographic proximity (if available)
    const clientRegion = request.headers.get('CF-IPCountry');
    if (clientRegion && server.region === clientRegion) {
      score += 10;
    }
    
    // Specialized capabilities
    if (request.url.includes('/api/code-analysis') && server.hasGPU) {
      score += 15;
    }
    
    return Math.max(0, score);
  }
}
```

### Queue Management

Graceful degradation under load prevents system collapse:

```typescript
export class AdaptiveQueueManager {
  private queues = new Map<Priority, Queue<Task>>();
  private processing = new Map<string, ProcessingTask>();
  
  constructor(
    private options: QueueOptions = {}
  ) {
    this.options = {
      maxConcurrent: 100,
      maxQueueSize: 1000,
      timeoutMs: 30000,
      ...options
    };
    
    // Initialize priority queues
    for (const priority of ['critical', 'high', 'normal', 'low']) {
      this.queues.set(priority as Priority, new Queue());
    }
  }
  
  async enqueue(
    task: Task,
    priority: Priority = 'normal'
  ): Promise<TaskResult> {
    // Check queue capacity
    const queue = this.queues.get(priority)!;
    if (queue.size >= this.options.maxQueueSize) {
      // Shed load for low priority tasks
      if (priority === 'low') {
        throw new Error('System overloaded, please retry later');
      }
      
      // Bump up priority for important tasks
      if (priority === 'normal') {
        return this.enqueue(task, 'high');
      }
    }
    
    // Add to queue
    const promise = new Promise<TaskResult>((resolve, reject) => {
      queue.enqueue({
        task,
        resolve,
        reject,
        enqueuedAt: Date.now()
      });
    });
    
    // Process queue
    this.processQueues();
    
    return promise;
  }
  
  private async processQueues(): Promise<void> {
    if (this.processing.size >= this.options.maxConcurrent) {
      return; // At capacity
    }
    
    // Process in priority order
    for (const [priority, queue] of this.queues) {
      while (
        queue.size > 0 && 
        this.processing.size < this.options.maxConcurrent
      ) {
        const item = queue.dequeue()!;
        
        // Check for timeout
        const waitTime = Date.now() - item.enqueuedAt;
        if (waitTime > this.options.timeoutMs) {
          item.reject(new Error('Task timeout in queue'));
          continue;
        }
        
        // Process task
        this.processTask(item);
      }
    }
  }
  
  private async processTask(item: QueueItem): Promise<void> {
    const taskId = crypto.randomUUID();
    
    this.processing.set(taskId, {
      item,
      startedAt: Date.now()
    });
    
    try {
      const result = await item.task.execute();
      item.resolve(result);
    } catch (error) {
      item.reject(error);
    } finally {
      this.processing.delete(taskId);
      // Process more tasks
      this.processQueues();
    }
  }
}
```

### Resource Pooling

Expensive resources like database connections benefit from pooling:

```typescript
export class ResourcePool<T> {
  private available: T[] = [];
  private inUse = new Map<T, PooledResource<T>>();
  private waiting: ((resource: T) => void)[] = [];
  
  constructor(
    private factory: ResourceFactory<T>,
    private options: PoolOptions = {}
  ) {
    this.options = {
      min: 5,
      max: 20,
      idleTimeoutMs: 300000,
      createTimeoutMs: 5000,
      ...options
    };
    
    // Pre-create minimum resources
    this.ensureMinimum();
  }
  
  async acquire(): Promise<PooledResource<T>> {
    // Return available resource
    while (this.available.length > 0) {
      const resource = this.available.pop()!;
      
      // Validate resource is still good
      if (await this.factory.validate(resource)) {
        const pooled = this.wrapResource(resource);
        this.inUse.set(resource, pooled);
        return pooled;
      } else {
        // Destroy invalid resource
        await this.factory.destroy(resource);
      }
    }
    
    // Create new resource if under max
    if (this.inUse.size < this.options.max) {
      const resource = await this.createResource();
      const pooled = this.wrapResource(resource);
      this.inUse.set(resource, pooled);
      return pooled;
    }
    
    // Wait for available resource
    return new Promise((resolve) => {
      this.waiting.push((resource) => {
        const pooled = this.wrapResource(resource);
        this.inUse.set(resource, pooled);
        resolve(pooled);
      });
    });
  }
  
  private wrapResource(resource: T): PooledResource<T> {
    const pooled = {
      resource,
      acquiredAt: Date.now(),
      release: async () => {
        this.inUse.delete(resource);
        
        // Give to waiting request
        if (this.waiting.length > 0) {
          const waiter = this.waiting.shift()!;
          waiter(resource);
          return;
        }
        
        // Return to available pool
        this.available.push(resource);
        
        // Schedule idle check
        setTimeout(() => {
          this.checkIdle();
        }, this.options.idleTimeoutMs);
      }
    };
    
    return pooled;
  }
  
  private async checkIdle(): Promise<void> {
    while (
      this.available.length > this.options.min &&
      this.waiting.length === 0
    ) {
      const resource = this.available.pop()!;
      await this.factory.destroy(resource);
    }
  }
}

// Example: Database connection pool
const dbPool = new ResourcePool({
  async create() {
    const conn = await pg.connect({
      host: 'localhost',
      database: 'amp',
      // Connection options
    });
    return conn;
  },
  
  async validate(conn) {
    try {
      await conn.query('SELECT 1');
      return true;
    } catch {
      return false;
    }
  },
  
  async destroy(conn) {
    await conn.end();
  }
});
```

## Real-World Performance Gains

These optimization strategies compound to deliver significant performance improvements:

### Latency Reduction

Before optimization:
- Conversation load: 800ms (database query + message fetch)
- Model response: 3-5 seconds
- File operations: 50-200ms per file
- Total interaction: 5-10 seconds

After optimization:
- Conversation load: 50ms (memory cache hit)
- Model response: 100ms (cached) or 2-3s (cache miss)
- File operations: 5-10ms (cached)
- Total interaction: 200ms - 3 seconds

### Throughput Improvements

Single server capacity:
- Before: 10-20 concurrent users
- After: 500-1000 concurrent users

With load balancing:
- 10 servers: 5,000-10,000 concurrent users
- Horizontal scaling: Linear growth with server count

### Resource Efficiency

Model usage optimization:
- 40% reduction through response caching
- 60% reduction in duplicate file reads
- 80% reduction in repository analysis

Infrastructure optimization:
- 70% reduction in database operations
- 50% reduction in bandwidth (CDN caching)
- 30% reduction in compute (edge functions)

## Monitoring and Optimization

Performance requires continuous monitoring and adjustment:

```typescript
export class PerformanceMonitor {
  private metrics = new Map<string, MetricCollector>();
  
  constructor(
    private reporter: MetricReporter
  ) {
    // Core metrics
    this.registerMetric('thread.load.time');
    this.registerMetric('llm.response.time');
    this.registerMetric('cache.hit.rate');
    this.registerMetric('queue.depth');
    this.registerMetric('concurrent.users');
  }
  
  async trackOperation<T>(
    name: string,
    operation: () => Promise<T>
  ): Promise<T> {
    const start = performance.now();
    
    try {
      const result = await operation();
      
      this.recordMetric(name, {
        duration: performance.now() - start,
        success: true
      });
      
      return result;
    } catch (error) {
      this.recordMetric(name, {
        duration: performance.now() - start,
        success: false,
        error: error.message
      });
      
      throw error;
    }
  }
  
  private recordMetric(
    name: string,
    data: MetricData
  ): void {
    const collector = this.metrics.get(name);
    if (!collector) return;
    
    collector.record(data);
    
    // Check for anomalies
    if (this.isAnomalous(name, data)) {
      this.handleAnomaly(name, data);
    }
  }
  
  private isAnomalous(
    name: string,
    data: MetricData
  ): boolean {
    const collector = this.metrics.get(name)!;
    const stats = collector.getStats();
    
    // Detect significant deviations
    if (data.duration) {
      const deviation = Math.abs(data.duration - stats.mean) / stats.stdDev;
      return deviation > 3; // 3 sigma rule
    }
    
    return false;
  }
}
```

## Summary

Performance at scale requires a multi-layered approach combining caching, database optimization, edge computing, and intelligent load balancing. Effective AI coding assistant architectures demonstrate how these patterns work together:

- **Aggressive caching** reduces redundant work at every layer
- **Database optimization** handles millions of conversations efficiently  
- **Edge distribution** brings compute closer to users
- **Load balancing** maintains quality of service under pressure
- **Resource pooling** maximizes hardware utilization
- **Queue management** provides graceful degradation

The key insight is that AI coding assistants have unique performance characteristics—long-running operations, large context windows, and complex tool interactions—that require specialized optimization strategies. By building these patterns into the architecture from the start, systems can scale from proof-of-concept to production without major rewrites.

These performance patterns form the foundation for building AI coding assistants that can serve thousands of developers concurrently while maintaining the responsiveness that makes them useful in real development workflows.

In the next chapter, we'll explore observability and monitoring strategies for understanding and optimizing these complex systems in production.