# Chapter 5: Real-Time Synchronization

Building a collaborative AI coding assistant requires keeping multiple clients synchronized in real-time. When one developer makes changes, their teammates need to see updates immediately. But unlike traditional real-time applications, AI assistants face unique challenges: long-running operations, large payloads, unreliable networks, and the need for eventual consistency.

This chapter explores synchronization patterns using polling, observables, and smart batching that prove more reliable than traditional WebSocket approaches for AI systems.

## The Synchronization Challenge

Real-time sync for AI assistants differs from typical collaborative applications:

1. **Large Payloads** - AI responses can be megabytes of text and code
2. **Long Operations** - Tool executions may take minutes to complete
3. **Unreliable Networks** - Developers work from cafes, trains, and flaky WiFi
4. **Cost Sensitivity** - Every sync operation costs money in API calls
5. **Consistency Requirements** - Code changes must apply in the correct order

Traditional WebSocket approaches struggle with these constraints. Amp takes a different path.

## WebSocket Challenges for AI Systems

WebSockets seem ideal for real-time synchronization, but AI systems present unique challenges that make them problematic.

**Recognition Pattern**: WebSockets become problematic when:
- Clients frequently disconnect (mobile networks, laptop sleep)
- Message sizes vary dramatically (small updates vs. large AI responses)
- Operations have long durations (multi-minute tool executions)
- Debugging requires message replay and inspection

**WebSocket Complications**:

- **Stateful connections** require careful lifecycle management
- **Message ordering** must be handled explicitly for correctness
- **Reconnection storms** can overwhelm servers during outages
- **Debugging** is difficult without proper message logging
- **Load balancing** requires sticky sessions or complex routing
- **Firewall issues** in enterprise environments

**Alternative Approach**: Smart polling with observables provides:
- **Stateless interactions** that survive network interruptions
- **Natural batching** that reduces server load
- **Simple debugging** with standard HTTP request logs
- **Easy caching** and CDN compatibility

## Observable-Based Architecture

At the heart of Amp's sync system is a custom Observable implementation:

```typescript
export abstract class Observable<T> {
  abstract subscribe(observer: Observer<T>): Subscription<T>;
  
  pipe<Out>(...operators: Operator[]): Observable<Out> {
    return operators.reduce(
      (source, operator) => operator(source),
      this as Observable<any>
    );
  }
  
  // Convert various sources to Observables
  static from<T>(source: ObservableLike<T>): Observable<T> {
    if (source instanceof Observable) return source;
    
    if (isPromise(source)) {
      return new Observable(observer => {
        source.then(
          value => {
            observer.next(value);
            observer.complete();
          },
          error => observer.error(error)
        );
      });
    }
    
    if (isIterable(source)) {
      return new Observable(observer => {
        for (const value of source) {
          observer.next(value);
        }
        observer.complete();
      });
    }
    
    throw new Error('Invalid source');
  }
}
```

This provides a foundation for reactive data flow throughout the system.

## Subjects for State Broadcasting

Amp uses specialized Subject types for different synchronization needs:

```typescript
// BehaviorSubject maintains current state
export class BehaviorSubject<T> extends Observable<T> {
  constructor(private currentValue: T) {
    super();
  }
  
  getValue(): T {
    return this.currentValue;
  }
  
  next(value: T): void {
    this.currentValue = value;
    this.observers.forEach(observer => observer.next(value));
  }
  
  subscribe(observer: Observer<T>): Subscription<T> {
    // New subscribers immediately receive current value
    observer.next(this.currentValue);
    return super.subscribe(observer);
  }
}

// SetSubject for managing collections
export function createSetSubject<T>(): SetSubject<T> {
  const set = new Set<T>();
  const subject = new BehaviorSubject<Set<T>>(set);
  
  return {
    add(value: T): void {
      set.add(value);
      subject.next(set);
    },
    
    delete(value: T): void {
      set.delete(value);
      subject.next(set);
    },
    
    has(value: T): boolean {
      return set.has(value);
    },
    
    clear(): void {
      set.clear();
      subject.next(set);
    },
    
    get size(): number {
      return set.size;
    },
    
    observable: subject.asObservable()
  };
}
```

These patterns enable efficient state synchronization across components.

## Sync Service Architecture

Amp's synchronization system provides observable streams and queue management:

```typescript
// Core synchronization interface
export interface SyncService {
  // Observable data streams
  observeSyncStatus(threadId: ThreadID): Observable<SyncStatus>;
  observePendingItems(): Observable<Set<ThreadID>>;
  
  // Sync operations
  queueForSync(threadId: ThreadID): void;
  syncImmediately(threadId: ThreadID): Promise<void>;
  
  // Service lifecycle
  start(): void;
  stop(): void;
  dispose(): void;
}

// Factory function creates configured sync service
export function createSyncService(dependencies: {
  threadService: ThreadService;
  cloudAPI: CloudAPIClient;
  configuration: ConfigService;
}): SyncService {
  // Track items waiting for synchronization
  const pendingItems = createSetSubject<ThreadID>();
  
  // Per-thread sync status tracking
  const statusTracking = new Map<ThreadID, BehaviorSubject<SyncStatus>>();
  
  // Failure tracking for exponential backoff
  const failureHistory = new Map<ThreadID, number>();
  
  // Configurable sync parameters
  const SYNC_INTERVAL = 5000;         // 5 seconds
  const RETRY_BACKOFF = 60000;        // 1 minute
  const BATCH_SIZE = 50;              // Items per batch
  
  let syncTimer: NodeJS.Timer | null = null;
  let serviceRunning = false;
  
  return {
    observeSyncStatus(threadId: ThreadID): Observable<SyncStatus> {
      if (!statusTracking.has(threadId)) {
        statusTracking.set(threadId, new BehaviorSubject<SyncStatus>({
          state: 'unknown',
          lastSync: null
        }));
      }
      return statusTracking.get(threadId)!.asObservable();
    },
    
    observePendingItems(): Observable<Set<ThreadID>> {
      return pendingItems.observable;
    },
    
    queueForSync(threadId: ThreadID): void {
      pendingItems.add(threadId);
      updateSyncStatus(threadId, { state: 'pending' });
    },
    
    async syncImmediately(threadId: ThreadID): Promise<void> {
      // Bypass queue for high-priority sync
      await performThreadSync(threadId);
    },
    
    start(): void {
      if (serviceRunning) return;
      serviceRunning = true;
      
      // Begin periodic sync processing
      scheduleSyncLoop();
      
      // Set up reactive change detection
      setupChangeListeners();
    },
    
    stop(): void {
      serviceRunning = false;
      if (syncTimer) {
        clearTimeout(syncTimer);
        syncTimer = null;
      }
    },
    
    dispose(): void {
      this.stop();
      statusTracking.forEach(subject => subject.complete());
      statusTracking.clear();
    }
  };
  
  function scheduleSyncLoop(): void {
    if (!serviceRunning) return;
    
    syncTimer = setTimeout(async () => {
      await processQueuedItems();
      scheduleSyncLoop();
    }, SYNC_INTERVAL);
  }
  
  async function processQueuedItems(): Promise<void> {
    const queuedThreads = Array.from(pendingItems.set);
    if (queuedThreads.length === 0) return;
    
    // Filter items ready for sync (respecting backoff)
    const readyItems = queuedThreads.filter(shouldAttemptSync);
    if (readyItems.length === 0) return;
    
    // Process in manageable batches
    for (let i = 0; i < readyItems.length; i += BATCH_SIZE) {
      const batch = readyItems.slice(i, i + BATCH_SIZE);
      await processBatch(batch);
    }
  }
  
  function shouldAttemptSync(threadId: ThreadID): boolean {
    const lastFailure = failureHistory.get(threadId);
    if (!lastFailure) return true;
    
    const timeSinceFailure = Date.now() - lastFailure;
    return timeSinceFailure >= RETRY_BACKOFF;
  }
}
```

## Adaptive Polling Strategy

Instead of fixed-interval polling, Amp adapts to user activity:

```typescript
// Dynamically adjusts polling frequency based on activity
export class AdaptivePoller {
  private baseInterval = 5000;    // 5 seconds baseline
  private maxInterval = 60000;    // 1 minute maximum
  private currentInterval = this.baseInterval;
  private activityLevel = 0;
  
  constructor(
    private syncService: SyncService,
    private threadService: ThreadService
  ) {
    this.setupActivityMonitoring();
  }
  
  private setupActivityMonitoring(): void {
    // Monitor thread modifications for user activity
    this.threadService.observeActiveThread().pipe(
      pairwise(),
      filter(([previous, current]) => previous?.v !== current?.v),
      tap(() => this.recordUserActivity())
    ).subscribe();
    
    // Monitor sync queue depth to adjust frequency
    this.syncService.observePendingItems().pipe(
      map(pending => pending.size),
      tap(queueDepth => {
        if (queueDepth > 10) this.increaseSyncFrequency();
        if (queueDepth === 0) this.decreaseSyncFrequency();
      })
    ).subscribe();
  }
  
  private recordUserActivity(): void {
    this.activityLevel = Math.min(100, this.activityLevel + 10);
    this.adjustPollingInterval();
  }
  
  private adjustPollingInterval(): void {
    // Higher activity leads to more frequent polling
    const scaleFactor = 1 - (this.activityLevel / 100) * 0.8;
    this.currentInterval = Math.floor(
      this.baseInterval + (this.maxInterval - this.baseInterval) * scaleFactor
    );
    
    // Schedule activity decay for gradual slow-down
    this.scheduleActivityDecay();
  }
  
  private scheduleActivityDecay(): void {
    setTimeout(() => {
      this.activityLevel = Math.max(0, this.activityLevel - 1);
      this.adjustPollingInterval();
    }, 1000);
  }
  
  getCurrentInterval(): number {
    return this.currentInterval;
  }
}
```

## Debouncing and Throttling

Amp implements sophisticated flow control to prevent overwhelming the system:

```typescript
// Debounce rapid changes
export function debounceTime<T>(
  duration: number
): OperatorFunction<T, T> {
  return (source: Observable<T>) => 
    new Observable<T>(observer => {
      let timeoutId: NodeJS.Timeout | null = null;
      let lastValue: T;
      let hasValue = false;
      
      const subscription = source.subscribe({
        next(value: T) {
          lastValue = value;
          hasValue = true;
          
          if (timeoutId) {
            clearTimeout(timeoutId);
          }
          
          timeoutId = setTimeout(() => {
            if (hasValue) {
              observer.next(lastValue);
              hasValue = false;
            }
            timeoutId = null;
          }, duration);
        },
        
        error(err) {
          observer.error(err);
        },
        
        complete() {
          if (timeoutId) {
            clearTimeout(timeoutId);
            if (hasValue) {
              observer.next(lastValue);
            }
          }
          observer.complete();
        }
      });
      
      return () => {
        if (timeoutId) {
          clearTimeout(timeoutId);
        }
        subscription.unsubscribe();
      };
    });
}

// Throttle with leading and trailing edges
export function throttleTime<T>(
  duration: number,
  { leading = true, trailing = true } = {}
): OperatorFunction<T, T> {
  return (source: Observable<T>) =>
    new Observable<T>(observer => {
      let lastEmitTime = 0;
      let trailingTimeout: NodeJS.Timeout | null = null;
      let lastValue: T;
      let hasTrailingValue = false;
      
      const emit = (value: T) => {
        lastEmitTime = Date.now();
        hasTrailingValue = false;
        observer.next(value);
      };
      
      const subscription = source.subscribe({
        next(value: T) {
          const now = Date.now();
          const elapsed = now - lastEmitTime;
          
          lastValue = value;
          
          if (elapsed >= duration) {
            // Enough time has passed
            if (leading) {
              emit(value);
            }
            
            if (trailing && !leading) {
              // Schedule trailing emit
              hasTrailingValue = true;
              trailingTimeout = setTimeout(() => {
                if (hasTrailingValue) {
                  emit(lastValue);
                }
                trailingTimeout = null;
              }, duration);
            }
          } else {
            // Still within throttle window
            if (trailing && !trailingTimeout) {
              hasTrailingValue = true;
              trailingTimeout = setTimeout(() => {
                if (hasTrailingValue) {
                  emit(lastValue);
                }
                trailingTimeout = null;
              }, duration - elapsed);
            }
          }
        }
      });
      
      return () => {
        if (trailingTimeout) {
          clearTimeout(trailingTimeout);
        }
        subscription.unsubscribe();
      };
    });
}
```

## Batch Synchronization

Amp groups sync operations for network efficiency:

```typescript
// Collects individual sync requests into efficient batches
export class BatchSyncOrchestrator {
  private requestQueue = new Map<ThreadID, SyncRequest>();
  private batchTimer: NodeJS.Timeout | null = null;
  
  private readonly BATCH_WINDOW = 100;      // 100ms collection window
  private readonly MAX_BATCH_SIZE = 50;     // Maximum items per batch
  
  constructor(private cloudAPI: CloudAPIClient) {}
  
  queueRequest(threadId: ThreadID, request: SyncRequest): void {
    // Merge with any existing request for same thread
    const existing = this.requestQueue.get(threadId);
    if (existing) {
      request = this.mergeRequests(existing, request);
    }
    
    this.requestQueue.set(threadId, request);
    
    // Start batch timer if not already running
    if (!this.batchTimer) {
      this.batchTimer = setTimeout(() => {
        this.flushBatch();
      }, this.BATCH_WINDOW);
    }
  }
  
  private async flushBatch(): Promise<void> {
    this.batchTimer = null;
    
    if (this.requestQueue.size === 0) return;
    
    // Extract batch of requests up to size limit
    const batchEntries = Array.from(this.requestQueue.entries())
      .slice(0, this.MAX_BATCH_SIZE);
    
    // Remove processed items from queue
    batchEntries.forEach(([id]) => this.requestQueue.delete(id));
    
    // Format batch request for API
    const batchRequest: BatchSyncRequest = {
      items: batchEntries.map(([id, request]) => ({
        threadId: id,
        version: request.version,
        changes: request.operations
      }))
    };
    
    try {
      const response = await this.cloudAPI.syncBatch(batchRequest);
      this.handleBatchResponse(response);
    } catch (error) {
      // Retry failed requests with exponential backoff
      batchEntries.forEach(([id, request]) => {
        request.attempts = (request.attempts || 0) + 1;
        if (request.attempts < 3) {
          this.queueRequest(id, request);
        }
      });
    }
    
    // Continue processing if more items queued
    if (this.requestQueue.size > 0) {
      this.batchTimer = setTimeout(() => {
        this.flushBatch();
      }, this.BATCH_WINDOW);
    }
  }
  
  private mergeRequests(
    existing: SyncRequest,
    incoming: SyncRequest
  ): SyncRequest {
    return {
      version: Math.max(existing.version, incoming.version),
      operations: [...existing.operations, ...incoming.operations],
      attempts: existing.attempts || 0
    };
  }
}
```

## Conflict Resolution

When concurrent edits occur, Amp resolves conflicts intelligently:

```typescript
export class ConflictResolver {
  async resolveConflict(
    local: Thread,
    remote: Thread,
    base?: Thread
  ): Promise<Thread> {
    // Simple case: one side didn't change
    if (!base) {
      return this.resolveWithoutBase(local, remote);
    }
    
    // Three-way merge
    const merged: Thread = {
      id: local.id,
      created: base.created,
      v: Math.max(local.v, remote.v) + 1,
      messages: await this.mergeMessages(
        base.messages,
        local.messages,
        remote.messages
      ),
      title: this.mergeScalar(base.title, local.title, remote.title),
      env: base.env
    };
    
    return merged;
  }
  
  private async mergeMessages(
    base: Message[],
    local: Message[],
    remote: Message[]
  ): Promise<Message[]> {
    // Find divergence point
    let commonIndex = 0;
    while (
      commonIndex < base.length &&
      commonIndex < local.length &&
      commonIndex < remote.length &&
      this.messagesEqual(
        base[commonIndex],
        local[commonIndex],
        remote[commonIndex]
      )
    ) {
      commonIndex++;
    }
    
    // Common prefix
    const merged = base.slice(0, commonIndex);
    
    // Get new messages from each branch
    const localNew = local.slice(commonIndex);
    const remoteNew = remote.slice(commonIndex);
    
    // Merge by timestamp
    const allNew = [...localNew, ...remoteNew].sort(
      (a, b) => a.timestamp - b.timestamp
    );
    
    // Remove duplicates
    const seen = new Set<string>();
    for (const msg of allNew) {
      const key = this.messageKey(msg);
      if (!seen.has(key)) {
        seen.add(key);
        merged.push(msg);
      }
    }
    
    return merged;
  }
  
  private messageKey(msg: Message): string {
    // Create unique key for deduplication
    return `${msg.role}:${msg.timestamp}:${msg.content.slice(0, 50)}`;
  }
  
  private mergeScalar<T>(base: T, local: T, remote: T): T {
    // If both changed to same value, use it
    if (local === remote) return local;
    
    // If only one changed, use the change
    if (local === base) return remote;
    if (remote === base) return local;
    
    // Both changed differently - prefer local
    return local;
  }
}
```

## Network Resilience

Amp handles network failures gracefully:

```typescript
export class ResilientSyncClient {
  private online$ = new BehaviorSubject(navigator.onLine);
  private retryDelays = [1000, 2000, 5000, 10000, 30000]; // Exponential backoff
  
  constructor(private api: ServerAPIClient) {
    // Monitor network status
    window.addEventListener('online', () => this.online$.next(true));
    window.addEventListener('offline', () => this.online$.next(false));
    
    // Test connectivity periodically
    this.startConnectivityCheck();
  }
  
  async syncWithRetry(
    request: SyncRequest,
    attempt = 0
  ): Promise<SyncResponse> {
    try {
      // Wait for network if offline
      await this.waitForNetwork();
      
      // Make request with timeout
      const response = await this.withTimeout(
        this.api.sync(request),
        10000 // 10 second timeout
      );
      
      return response;
      
    } catch (error) {
      if (this.isRetryable(error) && attempt < this.retryDelays.length) {
        const delay = this.retryDelays[attempt];
        
        logger.debug(
          `Sync failed, retrying in ${delay}ms (attempt ${attempt + 1})`
        );
        
        await this.delay(delay);
        return this.syncWithRetry(request, attempt + 1);
      }
      
      throw error;
    }
  }
  
  private async waitForNetwork(): Promise<void> {
    if (this.online$.getValue()) return;
    
    return new Promise(resolve => {
      const sub = this.online$.subscribe(online => {
        if (online) {
          sub.unsubscribe();
          resolve();
        }
      });
    });
  }
  
  private isRetryable(error: unknown): boolean {
    if (error instanceof NetworkError) return true;
    if (error instanceof TimeoutError) return true;
    if (error instanceof HTTPError) {
      return error.status >= 500 || error.status === 429;
    }
    return false;
  }
  
  private async startConnectivityCheck(): Promise<void> {
    while (true) {
      if (!this.online$.getValue()) {
        // Try to ping server
        try {
          await this.api.ping();
          this.online$.next(true);
        } catch {
          // Still offline
        }
      }
      
      await this.delay(30000); // Check every 30 seconds
    }
  }
}
```

## Optimistic Updates

To maintain responsiveness, Amp applies changes optimistically:

```typescript
export class OptimisticSyncManager {
  private pendingUpdates = new Map<string, PendingUpdate>();
  
  async applyOptimisticUpdate<T>(
    key: string,
    currentValue: T,
    update: (value: T) => T,
    persist: (value: T) => Promise<void>
  ): Promise<T> {
    // Apply update locally immediately
    const optimisticValue = update(currentValue);
    
    // Track pending update
    const pendingUpdate: PendingUpdate<T> = {
      key,
      originalValue: currentValue,
      optimisticValue,
      promise: null
    };
    
    this.pendingUpdates.set(key, pendingUpdate);
    
    // Persist asynchronously
    pendingUpdate.promise = persist(optimisticValue)
      .then(() => {
        // Success - remove from pending
        this.pendingUpdates.delete(key);
      })
      .catch(error => {
        // Failure - prepare for rollback
        pendingUpdate.error = error;
        throw error;
      });
    
    return optimisticValue;
  }
  
  async rollback(key: string): Promise<void> {
    const pending = this.pendingUpdates.get(key);
    if (!pending) return;
    
    // Wait for pending operation to complete
    try {
      await pending.promise;
    } catch {
      // Expected to fail
    }
    
    // Rollback if it failed
    if (pending.error) {
      // Notify UI to revert to original value
      this.onRollback?.(key, pending.originalValue);
    }
    
    this.pendingUpdates.delete(key);
  }
  
  hasPendingUpdates(): boolean {
    return this.pendingUpdates.size > 0;
  }
  
  async waitForPendingUpdates(): Promise<void> {
    const promises = Array.from(this.pendingUpdates.values())
      .map(update => update.promise);
    
    await Promise.allSettled(promises);
  }
}
```

## Performance Monitoring

Amp tracks sync performance to optimize behavior:

```typescript
export class SyncPerformanceMonitor {
  private metrics = new Map<string, MetricHistory>();
  
  recordSyncTime(
    threadId: string,
    duration: number,
    size: number
  ): void {
    const history = this.getHistory('sync-time');
    history.add({
      timestamp: Date.now(),
      value: duration,
      metadata: { threadId, size }
    });
    
    // Analyze for anomalies
    if (duration > this.getP95(history)) {
      logger.warn(`Slow sync detected: ${duration}ms for thread ${threadId}`);
    }
  }
  
  recordBatchSize(size: number): void {
    this.getHistory('batch-size').add({
      timestamp: Date.now(),
      value: size
    });
  }
  
  recordConflictRate(hadConflict: boolean): void {
    this.getHistory('conflicts').add({
      timestamp: Date.now(),
      value: hadConflict ? 1 : 0
    });
  }
  
  getOptimalBatchSize(): number {
    const history = this.getHistory('batch-size');
    const recentSizes = history.getRecent(100);
    
    // Find size that minimizes sync time
    const sizeToTime = new Map<number, number[]>();
    
    for (const entry of this.getHistory('sync-time').getRecent(100)) {
      const size = entry.metadata?.size || 1;
      if (!sizeToTime.has(size)) {
        sizeToTime.set(size, []);
      }
      sizeToTime.get(size)!.push(entry.value);
    }
    
    // Calculate average time per size
    let optimalSize = 50;
    let minAvgTime = Infinity;
    
    for (const [size, times] of sizeToTime) {
      const avgTime = times.reduce((a, b) => a + b) / times.length;
      if (avgTime < minAvgTime) {
        minAvgTime = avgTime;
        optimalSize = size;
      }
    }
    
    return Math.max(10, Math.min(100, optimalSize));
  }
  
  private getP95(history: MetricHistory): number {
    const values = history.getRecent(100)
      .map(entry => entry.value)
      .sort((a, b) => a - b);
    
    const index = Math.floor(values.length * 0.95);
    return values[index] || 0;
  }
}
```

## Testing Synchronization

Amp includes comprehensive sync testing utilities:

```typescript
export class SyncTestHarness {
  private mockServer = new MockSyncServer();
  private clients: TestClient[] = [];
  
  async testConcurrentEdits(): Promise<void> {
    // Create multiple clients
    const client1 = this.createClient('user1');
    const client2 = this.createClient('user2');
    
    // Both edit same thread
    const threadId = 'test-thread';
    
    await Promise.all([
      client1.addMessage(threadId, 'Hello from user 1'),
      client2.addMessage(threadId, 'Hello from user 2')
    ]);
    
    // Let sync complete
    await this.waitForSync();
    
    // Both clients should have both messages
    const thread1 = await client1.getThread(threadId);
    const thread2 = await client2.getThread(threadId);
    
    assert.equal(thread1.messages.length, 2);
    assert.equal(thread2.messages.length, 2);
    assert.deepEqual(thread1, thread2);
  }
  
  async testNetworkPartition(): Promise<void> {
    const client = this.createClient('user1');
    
    // Make changes while online
    await client.addMessage('thread1', 'Online message');
    
    // Go offline
    this.mockServer.disconnect(client);
    
    // Make offline changes
    await client.addMessage('thread1', 'Offline message 1');
    await client.addMessage('thread1', 'Offline message 2');
    
    // Verify changes are queued
    assert.equal(client.getPendingSyncCount(), 1);
    
    // Reconnect
    this.mockServer.connect(client);
    
    // Wait for sync
    await this.waitForSync();
    
    // Verify all changes synced
    assert.equal(client.getPendingSyncCount(), 0);
    
    const serverThread = this.mockServer.getThread('thread1');
    assert.equal(serverThread.messages.length, 3);
  }
  
  async testSyncPerformance(): Promise<void> {
    const client = this.createClient('user1');
    const messageCount = 1000;
    
    // Add many messages
    const startTime = Date.now();
    
    for (let i = 0; i < messageCount; i++) {
      await client.addMessage('perf-thread', `Message ${i}`);
    }
    
    await this.waitForSync();
    
    const duration = Date.now() - startTime;
    const throughput = messageCount / (duration / 1000);
    
    console.log(`Synced ${messageCount} messages in ${duration}ms`);
    console.log(`Throughput: ${throughput.toFixed(2)} messages/second`);
    
    // Should sync within reasonable time
    assert(throughput > 100, 'Sync throughput too low');
  }
}
```

## Summary

This chapter demonstrated that real-time synchronization doesn't require WebSockets:

- **Adaptive polling** adjusts frequency based on activity patterns
- **Observable architectures** provide reactive local state management
- **Intelligent batching** optimizes network efficiency
- **Optimistic updates** maintain responsive user interfaces
- **Resilient retry logic** handles network failures gracefully
- **Conflict resolution strategies** ensure eventual consistency

This approach proves more reliable and debuggable than traditional WebSocket solutions while maintaining real-time user experience. The key insight: for AI systems, eventual consistency with intelligent conflict resolution often outperforms complex real-time protocols.

The next chapter explores tool system architecture for distributed execution with safety and performance at scale.