# Chapter 7: Sharing and Permissions Patterns

When building collaborative AI coding assistants, one of the trickiest aspects isn't the AI itself—it's figuring out how to let people share their work without accidentally exposing something they shouldn't. This chapter explores patterns for implementing sharing and permissions that balance security, usability, and implementation complexity.

## The Three-Tier Sharing Model

A common pattern for collaborative AI assistants is a three-tier sharing model. This approach balances simplicity with flexibility, using two boolean flags—`private` and `public`—to create three distinct states:

```typescript
interface ShareableResource {
    private: boolean
    public: boolean
}

// Three sharing states:
// 1. Private (private: true, public: false) - Only creator access
// 2. Team (private: false, public: false) - Shared with team members  
// 3. Public (private: false, public: true) - Anyone with URL can access

async updateSharingState(
    resourceID: string,
    meta: Pick<ShareableResource, 'private' | 'public'>
): Promise<void> {
    // Validate state transition
    if (meta.private && meta.public) {
        throw new Error('Invalid state: cannot be both private and public')
    }
    
    // Optimistic update for UI responsiveness
    this.updateLocalState(resourceID, meta)
    
    try {
        // Sync with server
        await this.syncToServer(resourceID, meta)
    } catch (error) {
        // Rollback on failure
        this.revertLocalState(resourceID)
        throw error
    }
}
```

This design choice uses two booleans instead of an enum for several reasons:
- State transitions become more explicit
- Prevents accidental visibility changes through single field updates
- Creates an invalid fourth state that can be detected and rejected
- Maps naturally to user interface controls

## Permission Inheritance Patterns

When designing permission systems for hierarchical resources, you face a fundamental choice: inheritance versus independence. Complex permission inheritance can lead to unexpected exposure when parent permissions change. A simpler approach treats each resource independently.

```typescript
interface HierarchicalResource {
    id: string
    parentID?: string
    childIDs: string[]
    permissions: ResourcePermissions
}

// Independent permissions - each resource manages its own access
class IndependentPermissionModel {
    async updatePermissions(
        resourceID: string, 
        newPermissions: ResourcePermissions
    ): Promise<void> {
        // Only affects this specific resource
        await this.permissionStore.update(resourceID, newPermissions)
        
        // No cascading to children or parents
        // Users must explicitly manage each resource
    }
    
    async getEffectivePermissions(
        resourceID: string, 
        userID: string
    ): Promise<EffectivePermissions> {
        // Only check the resource itself
        const resource = await this.getResource(resourceID)
        return this.evaluatePermissions(resource.permissions, userID)
    }
}

// When syncing resources, treat each independently
for (const resource of resourcesToSync) {
    if (processed.has(resource.id)) {
        continue
    }
    processed.add(resource.id)
    
    // Each resource carries its own permission metadata
    syncRequest.resources.push({
        id: resource.id,
        permissions: resource.permissions,
        // No inheritance from parents
    })
}
```

This approach keeps the permission model simple and predictable. Users understand exactly what happens when they change sharing settings without worrying about cascading effects.

## URL-Based Sharing Implementation

URL-based sharing creates a capability system where knowledge of the URL grants access. This pattern is widely used in modern applications.

```typescript
// Generate unguessable resource identifiers
type ResourceID = `R-${string}`

function generateResourceID(): ResourceID {
    return `R-${crypto.randomUUID()}`
}

function buildResourceURL(baseURL: URL, resourceID: ResourceID): URL {
    return new URL(`/shared/${resourceID}`, baseURL)
}

// Security considerations for URL-based sharing
class URLSharingService {
    async createShareableLink(
        resourceID: ResourceID,
        permissions: SharePermissions
    ): Promise<ShareableLink> {
        // Generate unguessable token
        const shareToken = crypto.randomUUID()
        
        // Store mapping with expiration
        await this.shareStore.create({
            token: shareToken,
            resourceID,
            permissions,
            expiresAt: new Date(Date.now() + permissions.validForMs),
            createdBy: permissions.creatorID
        })
        
        return {
            url: new URL(`/share/${shareToken}`, this.baseURL),
            expiresAt: new Date(Date.now() + permissions.validForMs),
            permissions
        }
    }
    
    async validateShareAccess(
        shareToken: string,
        requesterID: string
    ): Promise<AccessResult> {
        const share = await this.shareStore.get(shareToken)
        
        if (!share || share.expiresAt < new Date()) {
            return { allowed: false, reason: 'Link expired or invalid' }
        }
        
        // Check if additional authentication is required
        if (share.permissions.requiresAuth && !requesterID) {
            return { allowed: false, reason: 'Authentication required' }
        }
        
        return { 
            allowed: true, 
            resourceID: share.resourceID,
            effectivePermissions: share.permissions
        }
    }
}

// Defense in depth: URL capability + authentication
class SecureAPIClient {
    async makeRequest(endpoint: string, options: RequestOptions): Promise<Response> {
        return fetch(new URL(endpoint, this.baseURL), {
            ...options,
            headers: {
                ...options.headers,
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${this.apiKey}`,
                'X-Client-ID': this.clientID,
            },
        })
    }
}
```

This dual approach provides defense in depth: the URL grants capability, but authentication verifies identity. Even if someone discovers a shared URL, they still need valid credentials for sensitive operations.

## Security Considerations

Implementing secure sharing requires several defensive patterns:

### Optimistic Updates with Rollback

For responsive UIs, optimistic updates show changes immediately while syncing in the background:

```typescript
class SecurePermissionService {
    async updatePermissions(
        resourceID: string, 
        newPermissions: ResourcePermissions
    ): Promise<void> {
        // Capture current state for rollback
        const previousState = this.localState.get(resourceID)
        
        try {
            // Optimistic update for immediate UI feedback
            this.localState.set(resourceID, {
                status: 'syncing',
                permissions: newPermissions,
                lastUpdated: Date.now()
            })
            this.notifyStateChange(resourceID)
            
            // Sync with server
            await this.syncToServer(resourceID, newPermissions)
            
            // Mark as synced
            this.localState.set(resourceID, {
                status: 'synced',
                permissions: newPermissions,
                lastUpdated: Date.now()
            })
            
        } catch (error) {
            // Rollback on failure
            if (previousState) {
                this.localState.set(resourceID, previousState)
            } else {
                this.localState.delete(resourceID)
            }
            this.notifyStateChange(resourceID)
            throw error
        }
    }
}
```

### Intelligent Retry Logic

Network failures shouldn't result in permanent inconsistency:

```typescript
class ResilientSyncService {
    private readonly RETRY_BACKOFF_MS = 60000 // 1 minute
    private failedAttempts = new Map<string, number>()
    
    shouldRetrySync(resourceID: string): boolean {
        const lastFailed = this.failedAttempts.get(resourceID)
        if (!lastFailed) {
            return true // Never failed, okay to try
        }
        
        const elapsed = Date.now() - lastFailed
        return elapsed >= this.RETRY_BACKOFF_MS
    }
    
    async attemptSync(resourceID: string): Promise<void> {
        try {
            await this.performSync(resourceID)
            // Clear failure record on success
            this.failedAttempts.delete(resourceID)
        } catch (error) {
            // Record failure time
            this.failedAttempts.set(resourceID, Date.now())
            throw error
        }
    }
}
```

### Support Access Patterns

Separate mechanisms for support access maintain clear boundaries:

```typescript
class SupportAccessService {
    async grantSupportAccess(
        resourceID: string,
        userID: string,
        reason: string
    ): Promise<SupportAccessGrant> {
        // Validate user can grant support access
        const resource = await this.getResource(resourceID)
        if (!this.canGrantSupportAccess(resource, userID)) {
            throw new Error('Insufficient permissions to grant support access')
        }
        
        // Create time-limited support access
        const grant: SupportAccessGrant = {
            id: crypto.randomUUID(),
            resourceID,
            grantedBy: userID,
            reason,
            expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 hours
            permissions: { read: true, debug: true }
        }
        
        await this.supportAccessStore.create(grant)
        
        // Audit log
        await this.auditLogger.log({
            action: 'support_access_granted',
            resourceID,
            grantedBy: userID,
            grantID: grant.id,
            reason
        })
        
        return grant
    }
}
```

These patterns provide multiple layers of protection while maintaining usability and supporting legitimate operational needs.

## Real-World Implementation Details

Production systems require pragmatic solutions for common challenges:

### API Versioning and Fallbacks

When evolving APIs, graceful degradation ensures system reliability:

```typescript
class VersionedAPIClient {
    private useNewAPI: boolean = true
    
    async updateResource(
        resourceID: string, 
        updates: ResourceUpdates
    ): Promise<void> {
        let newAPISucceeded = false
        
        if (this.useNewAPI) {
            try {
                const response = await this.callNewAPI(resourceID, updates)
                if (response.ok) {
                    newAPISucceeded = true
                }
            } catch (error) {
                // Log but don't fail - will try fallback
                this.logAPIError('new_api_failed', error)
            }
        }
        
        if (!newAPISucceeded) {
            // Fallback to older API format
            await this.callLegacyAPI(resourceID, this.transformToLegacy(updates))
        }
    }
    
    private transformToLegacy(updates: ResourceUpdates): LegacyUpdates {
        // Transform new format to legacy API expectations
        return {
            private: updates.visibility === 'private',
            public: updates.visibility === 'public',
            // Map other fields...
        }
    }
}
```

### Avoiding Empty State Sync

Don't synchronize resources that provide no value:

```typescript
class IntelligentSyncService {
    shouldSyncResource(resource: SyncableResource): boolean {
        // Skip empty or placeholder resources
        if (this.isEmpty(resource)) {
            return false
        }
        
        // Skip resources that haven't been meaningfully used
        if (this.isUnused(resource)) {
            return false
        }
        
        // Skip resources with only metadata
        if (this.hasOnlyMetadata(resource)) {
            return false
        }
        
        return true
    }
    
    private isEmpty(resource: SyncableResource): boolean {
        return (
            !resource.content?.length &&
            !resource.interactions?.length &&
            !resource.modifications?.length
        )
    }
    
    private isUnused(resource: SyncableResource): boolean {
        const timeSinceCreation = Date.now() - resource.createdAt
        const hasMinimalUsage = resource.interactionCount < 3
        
        // Created recently but barely used
        return timeSinceCreation < 5 * 60 * 1000 && hasMinimalUsage
    }
}
```

### Configuration-Driven Behavior

Use feature flags for gradual rollouts and emergency rollbacks:

```typescript
interface FeatureFlags {
    enableNewPermissionSystem: boolean
    strictPermissionValidation: boolean
    allowCrossTeamSharing: boolean
    enableAuditLogging: boolean
}

class ConfigurablePermissionService {
    constructor(
        private config: FeatureFlags,
        private legacyService: LegacyPermissionService,
        private newService: NewPermissionService
    ) {}
    
    async checkPermissions(
        resourceID: string, 
        userID: string
    ): Promise<PermissionResult> {
        if (this.config.enableNewPermissionSystem) {
            const result = await this.newService.check(resourceID, userID)
            
            if (this.config.strictPermissionValidation) {
                // Also validate with legacy system for comparison
                const legacyResult = await this.legacyService.check(resourceID, userID)
                this.compareResults(result, legacyResult, resourceID, userID)
            }
            
            return result
        } else {
            return this.legacyService.check(resourceID, userID)
        }
    }
}
```

These patterns acknowledge that production systems evolve gradually and need mechanisms for safe transitions.

## Performance Optimizations

Permission systems can become performance bottlenecks without careful optimization:

### Batching and Debouncing

Group rapid changes to reduce server load:

```typescript
class OptimizedSyncService {
    private pendingUpdates = new BehaviorSubject<Set<string>>(new Set())
    
    constructor() {
        // Batch updates with debouncing
        this.pendingUpdates.pipe(
            filter(updates => updates.size > 0),
            debounceTime(3000), // Wait 3 seconds for additional changes
            map(updates => Array.from(updates))
        ).subscribe(resourceIDs => {
            this.processBatch(resourceIDs).catch(error => {
                this.logger.error('Batch sync failed:', error)
            })
        })
    }
    
    queueUpdate(resourceID: string): void {
        const current = this.pendingUpdates.value
        current.add(resourceID)
        this.pendingUpdates.next(current)
    }
    
    private async processBatch(resourceIDs: string[]): Promise<void> {
        // Batch API call instead of individual requests
        const updates = await this.gatherUpdates(resourceIDs)
        await this.apiClient.batchUpdate(updates)
        
        // Clear processed items
        const remaining = this.pendingUpdates.value
        resourceIDs.forEach(id => remaining.delete(id))
        this.pendingUpdates.next(remaining)
    }
}
```

### Local Caching Strategy

Cache permission state locally for immediate UI responses:

```typescript
class CachedPermissionService {
    private permissionCache = new Map<string, CachedPermission>()
    private readonly CACHE_TTL = 5 * 60 * 1000 // 5 minutes
    
    async checkPermission(
        resourceID: string, 
        userID: string
    ): Promise<PermissionResult> {
        const cacheKey = `${resourceID}:${userID}`
        const cached = this.permissionCache.get(cacheKey)
        
        // Return cached result if fresh
        if (cached && this.isFresh(cached)) {
            return cached.result
        }
        
        // Fetch from server
        const result = await this.fetchPermission(resourceID, userID)
        
        // Cache for future use
        this.permissionCache.set(cacheKey, {
            result,
            timestamp: Date.now()
        })
        
        return result
    }
    
    private isFresh(cached: CachedPermission): boolean {
        return Date.now() - cached.timestamp < this.CACHE_TTL
    }
    
    // Invalidate cache when permissions change
    invalidateUser(userID: string): void {
        for (const [key, _] of this.permissionCache) {
            if (key.endsWith(`:${userID}`)) {
                this.permissionCache.delete(key)
            }
        }
    }
    
    invalidateResource(resourceID: string): void {
        for (const [key, _] of this.permissionCache) {
            if (key.startsWith(`${resourceID}:`)) {
                this.permissionCache.delete(key)
            }
        }
    }
}
```

### Preemptive Permission Loading

Load permissions for likely-needed resources:

```typescript
class PreemptivePermissionLoader {
    async preloadPermissions(context: UserContext): Promise<void> {
        // Load permissions for recently accessed resources
        const recentResources = await this.getRecentResources(context.userID)
        
        // Load permissions for team resources
        const teamResources = await this.getTeamResources(context.teamIDs)
        
        // Batch load to minimize API calls
        const allResources = [...recentResources, ...teamResources]
        const permissions = await this.batchLoadPermissions(
            allResources, 
            context.userID
        )
        
        // Populate cache
        permissions.forEach(perm => {
            this.cache.set(`${perm.resourceID}:${context.userID}`, {
                result: perm,
                timestamp: Date.now()
            })
        })
    }
}
```

These optimizations ensure that permission checks don't become a user experience bottleneck while maintaining security guarantees.

## Design Trade-offs

The implementation reveals several interesting trade-offs:

**Simplicity vs. Flexibility**: The three-tier model is simple to understand and implement but doesn't support fine-grained permissions like "share with specific users" or "read-only access." This is probably the right choice for a tool focused on individual developers and small teams.

**Security vs. Convenience**: URL-based sharing makes it easy to share threads (just send a link!) but means anyone with the URL can access public threads. The UUID randomness provides security, but it's still a capability-based model.

**Consistency vs. Performance**: The optimistic updates make the UI feel responsive, but they create a window where the local state might not match the server state. The implementation handles this gracefully with rollbacks, but it's added complexity.

**Backward Compatibility vs. Clean Code**: The fallback API mechanism adds code complexity but ensures smooth deployments and rollbacks. This is the kind of pragmatic decision that production systems require.

## Implementation Principles

When building sharing systems for collaborative AI tools, consider these key principles:

### 1. Start Simple
The three-tier model (private/team/public) covers most use cases without complex ACL systems. You can always add complexity later if needed.

### 2. Make State Transitions Explicit
Using separate flags rather than enums makes permission changes more intentional and prevents accidental exposure.

### 3. Design for Failure
Implement optimistic updates with rollback, retry logic with backoff, and graceful degradation patterns.

### 4. Cache Strategically
Local caching prevents permission checks from blocking UI interactions while maintaining security.

### 5. Support Operational Needs
Plan for support workflows, debugging access, and administrative overrides from the beginning.

### 6. Optimize for Common Patterns
Most developers follow predictable sharing patterns:
- Private work during development
- Team sharing for code review
- Public sharing for teaching or documentation

Design your system around these natural workflows rather than trying to support every possible permission combination.

### 7. Maintain Audit Trails
Track permission changes for debugging, compliance, and security analysis.

```typescript
interface PermissionAuditEvent {
    timestamp: Date
    resourceID: string
    userID: string
    action: 'granted' | 'revoked' | 'modified'
    previousState?: PermissionState
    newState: PermissionState
    reason?: string
}
```

### 8. Consider Privacy by Design
Default to private sharing and require explicit action to increase visibility. Make the implications of each sharing level clear to users.

The most important insight is that effective permission systems align with human trust patterns and workflows. Technical complexity should serve user needs, not create barriers to collaboration.