# Chapter 8: Team Workflow Patterns

When multiple developers work with AI coding assistants, coordination becomes critical. This chapter explores collaboration patterns for AI-assisted development, from concurrent editing strategies to enterprise audit requirements. We'll examine how individual-focused architectures extend naturally to team scenarios.

## The Challenge of Concurrent AI Sessions

Traditional version control handles concurrent human edits through merge strategies. But AI-assisted development introduces new complexities. When two developers prompt their AI assistants to modify the same codebase simultaneously, the challenges multiply:

```typescript
// Developer A's session
"Refactor the authentication module to use JWT tokens"

// Developer B's session (at the same time)
"Add OAuth2 support to the authentication system"
```

Both AI agents begin analyzing the code, generating modifications, and executing file edits. Without coordination, they'll create conflicting changes that are harder to resolve than typical merge conflicts—because each AI's changes might span multiple files with interdependent modifications.

## Building on Amp's Thread Architecture

Amp's thread-based architecture provides a foundation for team coordination. Each developer's conversation exists as a separate thread, with its own state and history. The `ThreadSyncService` already handles synchronization between local and server state:

```typescript
export interface ThreadSyncService {
    sync(): Promise<void>
    updateThreadMeta(threadID: ThreadID, meta: ThreadMeta): Promise<void>
    threadSyncInfo(threadIDs: ThreadID[]): Observable<Record<ThreadID, ThreadSyncInfo>>
}
```

This synchronization mechanism can extend to team awareness. When multiple developers work on related code, their thread metadata could include:

```typescript
interface TeamThreadMeta extends ThreadMeta {
    activeFiles: string[]          // Files being modified
    activeBranch: string           // Git branch context
    teamMembers: string[]          // Other users with access
    lastActivity: number           // Timestamp for presence
    intentSummary?: string         // AI-generated work summary
}
```

## Concurrent Editing Strategies

The key to managing concurrent AI edits lies in early detection and intelligent coordination. Here's how Amp's architecture could handle this:

### File-Level Locking

The simplest approach prevents conflicts by establishing exclusive access:

```typescript
class FileCoordinator {
    private fileLocks = new Map<string, FileLock>()
    
    async acquireLock(
        filePath: string, 
        threadID: ThreadID,
        intent?: string
    ): Promise<LockResult> {
        const existingLock = this.fileLocks.get(filePath)
        
        if (existingLock && !this.isLockExpired(existingLock)) {
            return {
                success: false,
                owner: existingLock.threadID,
                intent: existingLock.intent,
                expiresAt: existingLock.expiresAt
            }
        }
        
        const lock: FileLock = {
            threadID,
            filePath,
            acquiredAt: Date.now(),
            expiresAt: Date.now() + LOCK_DURATION,
            intent
        }
        
        this.fileLocks.set(filePath, lock)
        this.broadcastLockUpdate(filePath, lock)
        
        return { success: true, lock }
    }
}
```

But hard locks frustrate developers. A better approach uses soft coordination with conflict detection:

### Optimistic Concurrency Control

Instead of blocking edits, track them and detect conflicts as they occur:

```typescript
class EditTracker {
    private activeEdits = new Map<string, ActiveEdit[]>()
    
    async proposeEdit(
        filePath: string,
        edit: ProposedEdit
    ): Promise<EditProposal> {
        const concurrent = this.activeEdits.get(filePath) || []
        const conflicts = this.detectConflicts(edit, concurrent)
        
        if (conflicts.length > 0) {
            // AI can attempt to merge changes
            const resolution = await this.aiMergeStrategy(
                edit, 
                conflicts,
                await this.getFileContent(filePath)
            )
            
            if (resolution.success) {
                return {
                    type: 'merged',
                    edit: resolution.mergedEdit,
                    originalConflicts: conflicts
                }
            }
            
            return {
                type: 'conflict',
                conflicts,
                suggestions: resolution.suggestions
            }
        }
        
        // No conflicts, proceed with edit
        this.activeEdits.set(filePath, [...concurrent, {
            ...edit,
            timestamp: Date.now()
        }])
        
        return { type: 'clear', edit }
    }
}
```

### AI-Assisted Merge Resolution

When conflicts occur, the AI can help resolve them by understanding both developers' intents:

```typescript
async function aiMergeStrategy(
    proposedEdit: ProposedEdit,
    conflicts: ActiveEdit[],
    currentContent: string
): Promise<MergeResolution> {
    const prompt = `
        Multiple developers are editing the same file concurrently.
        
        Current file content:
        ${currentContent}
        
        Proposed edit (${proposedEdit.threadID}):
        Intent: ${proposedEdit.intent}
        Changes: ${proposedEdit.changes}
        
        Conflicting edits:
        ${conflicts.map(c => `
            Thread ${c.threadID}:
            Intent: ${c.intent}
            Changes: ${c.changes}
        `).join('\n')}
        
        Can these changes be merged? If so, provide a unified edit.
        If not, explain the conflict and suggest resolution options.
    `
    
    const response = await inferenceService.complete(prompt)
    return parseMergeResolution(response)
}
```

## Presence and Awareness Features

Effective collaboration requires knowing what your teammates are doing. Amp's reactive architecture makes presence features straightforward to implement.

### Active Thread Awareness

The thread view state already tracks what each session is doing:

```typescript
export type ThreadViewState = ThreadWorkerStatus & {
    waitingForUserInput: 'tool-use' | 'user-message-initial' | 'user-message-reply' | false
}
```

This extends naturally to team awareness:

```typescript
interface TeamPresence {
    threadID: ThreadID
    user: string
    status: ThreadViewState
    currentFiles: string[]
    lastHeartbeat: number
    currentPrompt?: string  // Sanitized/summarized
}

class PresenceService {
    private presence = new BehaviorSubject<Map<string, TeamPresence>>(new Map())
    
    broadcastPresence(update: PresenceUpdate): void {
        const current = this.presence.getValue()
        current.set(update.user, {
            ...update,
            lastHeartbeat: Date.now()
        })
        this.presence.next(current)
        
        // Clean up stale presence after timeout
        setTimeout(() => this.cleanupStale(), PRESENCE_TIMEOUT)
    }
    
    getActiveUsersForFile(filePath: string): Observable<TeamPresence[]> {
        return this.presence.pipe(
            map(presenceMap => 
                Array.from(presenceMap.values())
                    .filter(p => p.currentFiles.includes(filePath))
            )
        )
    }
}
```

### Visual Indicators

In the UI, presence appears as subtle indicators:

```typescript
const FilePresenceIndicator: React.FC<{ filePath: string }> = ({ filePath }) => {
    const activeUsers = useActiveUsers(filePath)
    
    if (activeUsers.length === 0) return null
    
    return (
        <div className="presence-indicators">
            {activeUsers.map(user => (
                <Tooltip key={user.user} content={user.currentPrompt || 'Active'}>
                    <Avatar 
                        user={user.user}
                        status={user.status.state}
                        pulse={user.status.state === 'active'}
                    />
                </Tooltip>
            ))}
        </div>
    )
}
```

### Workspace Coordination

Beyond individual files, teams need workspace-level coordination:

```typescript
interface WorkspaceActivity {
    recentThreads: ThreadSummary[]
    activeRefactorings: RefactoringOperation[]
    toolExecutions: ToolExecution[]
    modifiedFiles: FileModification[]
}

class WorkspaceCoordinator {
    async getWorkspaceActivity(
        since: number
    ): Promise<WorkspaceActivity> {
        const [threads, tools, files] = await Promise.all([
            this.getRecentThreads(since),
            this.getActiveTools(since),
            this.getModifiedFiles(since)
        ])
        
        const refactorings = this.detectRefactorings(threads, files)
        
        return {
            recentThreads: threads,
            activeRefactorings: refactorings,
            toolExecutions: tools,
            modifiedFiles: files
        }
    }
    
    private detectRefactorings(
        threads: ThreadSummary[], 
        files: FileModification[]
    ): RefactoringOperation[] {
        // Analyze threads and file changes to detect large-scale refactorings
        // that might affect other developers
        return threads
            .filter(t => this.isRefactoring(t))
            .map(t => ({
                threadID: t.id,
                user: t.user,
                description: t.summary,
                affectedFiles: this.getAffectedFiles(t, files),
                status: this.getRefactoringStatus(t)
            }))
    }
}
```

## Notification Systems

Effective notifications balance awareness with focus. Too many interruptions destroy productivity, while too few leave developers unaware of important changes.

### Intelligent Notification Routing

Not all team activity requires immediate attention:

```typescript
class NotificationRouter {
    private rules: NotificationRule[] = [
        {
            condition: (event) => event.type === 'conflict',
            priority: 'high',
            delivery: 'immediate'
        },
        {
            condition: (event) => event.type === 'refactoring_started' && 
                                  event.affectedFiles.length > 10,
            priority: 'medium',
            delivery: 'batched'
        },
        {
            condition: (event) => event.type === 'file_modified',
            priority: 'low',
            delivery: 'digest'
        }
    ]
    
    async route(event: TeamEvent): Promise<void> {
        const rule = this.rules.find(r => r.condition(event))
        if (!rule) return
        
        const relevantUsers = await this.getRelevantUsers(event)
        
        switch (rule.delivery) {
            case 'immediate':
                await this.sendImmediate(event, relevantUsers)
                break
            case 'batched':
                this.batchQueue.add(event, relevantUsers)
                break
            case 'digest':
                this.digestQueue.add(event, relevantUsers)
                break
        }
    }
    
    private async getRelevantUsers(event: TeamEvent): Promise<string[]> {
        // Determine who needs to know about this event
        const directlyAffected = await this.getUsersWorkingOn(event.affectedFiles)
        const interested = await this.getUsersInterestedIn(event.context)
        
        return [...new Set([...directlyAffected, ...interested])]
    }
}
```

### Context-Aware Notifications

Notifications should provide enough context for quick decision-making:

```typescript
interface RichNotification {
    id: string
    type: NotificationType
    title: string
    summary: string
    context: {
        thread?: ThreadSummary
        files?: FileSummary[]
        conflicts?: ConflictInfo[]
        suggestions?: string[]
    }
    actions: NotificationAction[]
    priority: Priority
    timestamp: number
}

class NotificationBuilder {
    buildConflictNotification(
        conflict: EditConflict
    ): RichNotification {
        const summary = this.generateConflictSummary(conflict)
        const suggestions = this.generateResolutionSuggestions(conflict)
        
        return {
            id: newNotificationID(),
            type: 'conflict',
            title: `Edit conflict in ${conflict.filePath}`,
            summary,
            context: {
                files: [conflict.file],
                conflicts: [conflict],
                suggestions
            },
            actions: [
                {
                    label: 'View Conflict',
                    action: 'open_conflict_view',
                    params: { conflictId: conflict.id }
                },
                {
                    label: 'Auto-merge',
                    action: 'attempt_auto_merge',
                    params: { conflictId: conflict.id },
                    requiresConfirmation: true
                }
            ],
            priority: 'high',
            timestamp: Date.now()
        }
    }
}
```

## Audit Trails and Compliance

Enterprise environments require comprehensive audit trails. Every AI interaction, code modification, and team coordination event needs tracking for compliance and debugging.

### Comprehensive Event Logging

Amp's thread deltas provide a natural audit mechanism:

```typescript
interface AuditEvent {
    id: string
    timestamp: number
    threadID: ThreadID
    user: string
    type: string
    details: Record<string, any>
    hash: string  // For tamper detection
}

class AuditService {
    private auditStore: AuditStore
    
    async logThreadDelta(
        threadID: ThreadID,
        delta: ThreadDelta,
        user: string
    ): Promise<void> {
        const event: AuditEvent = {
            id: newAuditID(),
            timestamp: Date.now(),
            threadID,
            user,
            type: `thread.${delta.type}`,
            details: this.sanitizeDelta(delta),
            hash: this.computeHash(threadID, delta, user)
        }
        
        await this.auditStore.append(event)
        
        // Special handling for sensitive operations
        if (this.isSensitiveOperation(delta)) {
            await this.notifyCompliance(event)
        }
    }
    
    private sanitizeDelta(delta: ThreadDelta): Record<string, any> {
        // Remove sensitive data while preserving audit value
        const sanitized = { ...delta }
        
        if (delta.type === 'tool:data' && delta.data.status === 'success') {
            // Keep metadata but potentially redact output
            sanitized.data = {
                ...delta.data,
                output: this.redactSensitive(delta.data.output)
            }
        }
        
        return sanitized
    }
}
```

### Chain of Custody

For regulated environments, maintaining a clear chain of custody for AI-generated code is crucial:

```typescript
interface CodeProvenance {
    threadID: ThreadID
    messageID: string
    generatedBy: 'human' | 'ai'
    prompt?: string
    model?: string
    timestamp: number
    reviewedBy?: string[]
    approvedBy?: string[]
}

class ProvenanceTracker {
    async trackFileModification(
        filePath: string,
        modification: FileModification,
        source: CodeProvenance
    ): Promise<void> {
        const existing = await this.getFileProvenance(filePath)
        
        const updated = {
            ...existing,
            modifications: [
                ...existing.modifications,
                {
                    ...modification,
                    provenance: source,
                    diff: await this.computeDiff(filePath, modification)
                }
            ]
        }
        
        await this.store.update(filePath, updated)
        
        // Generate compliance report if needed
        if (this.requiresComplianceReview(modification)) {
            await this.triggerComplianceReview(filePath, modification, source)
        }
    }
}
```

### Compliance Reporting

Audit data becomes valuable through accessible reporting:

```typescript
class ComplianceReporter {
    async generateReport(
        timeRange: TimeRange,
        options: ReportOptions
    ): Promise<ComplianceReport> {
        const events = await this.auditService.getEvents(timeRange)
        
        return {
            summary: {
                totalSessions: this.countUniqueSessions(events),
                totalModifications: this.countModifications(events),
                aiGeneratedCode: this.calculateAICodePercentage(events),
                reviewedCode: this.calculateReviewPercentage(events)
            },
            userActivity: this.aggregateByUser(events),
            modelUsage: this.aggregateByModel(events),
            sensitiveOperations: this.extractSensitiveOps(events),
            anomalies: await this.detectAnomalies(events)
        }
    }
    
    private async detectAnomalies(
        events: AuditEvent[]
    ): Promise<Anomaly[]> {
        const anomalies: Anomaly[] = []
        
        // Unusual activity patterns
        const userPatterns = this.analyzeUserPatterns(events)
        anomalies.push(...userPatterns.filter(p => p.isAnomalous))
        
        // Suspicious file access
        const fileAccess = this.analyzeFileAccess(events)
        anomalies.push(...fileAccess.filter(a => a.isSuspicious))
        
        // Model behavior changes
        const modelBehavior = this.analyzeModelBehavior(events)
        anomalies.push(...modelBehavior.filter(b => b.isUnexpected))
        
        return anomalies
    }
}
```

## Implementation Considerations

Implementing team workflows requires balancing collaboration benefits with system complexity:

### Performance at Scale

Team features multiply the data flowing through the system. Batching and debouncing patterns prevent overload while maintaining responsiveness:

```typescript
class TeamDataProcessor {
    private updateQueues = new Map<string, Observable<Set<string>>>()
    
    initializeBatching(): void {
        // Different update types need different batching strategies
        const presenceQueue = new BehaviorSubject<Set<string>>(new Set())
        
        presenceQueue.pipe(
            filter(updates => updates.size > 0),
            debounceTime(3000), // Batch closely-timed changes
            map(updates => Array.from(updates))
        ).subscribe(userIDs => {
            this.processBatchedPresenceUpdates(userIDs)
        })
    }
    
    queuePresenceUpdate(userID: string): void {
        const queue = this.updateQueues.get('presence') as BehaviorSubject<Set<string>>
        const current = queue.value
        current.add(userID)
        queue.next(current)
    }
}
```

This pattern applies to presence updates, notifications, and audit events, ensuring system stability under team collaboration load.

### Security and Privacy

Team features must enforce appropriate boundaries while enabling collaboration:

```typescript
class TeamAccessController {
    async filterTeamData(
        data: TeamData,
        requestingUser: string
    ): Promise<FilteredTeamData> {
        const userContext = await this.getUserContext(requestingUser)
        
        return {
            // User always sees their own work
            ownSessions: data.sessions.filter(s => s.userID === requestingUser),
            
            // Team data based on membership and sharing settings
            teamSessions: data.sessions.filter(session => 
                this.canViewSession(session, userContext)
            ),
            
            // Aggregate metrics without individual details
            teamMetrics: this.aggregateWithPrivacy(data.sessions, userContext),
            
            // Presence data with privacy controls
            teamPresence: this.filterPresenceData(data.presence, userContext)
        }
    }
    
    private canViewSession(
        session: Session,
        userContext: UserContext
    ): boolean {
        // Own sessions
        if (session.userID === userContext.userID) return true
        
        // Explicitly shared
        if (session.sharedWith?.includes(userContext.userID)) return true
        
        // Team visibility with proper membership
        if (session.teamVisible && userContext.teamMemberships.includes(session.teamID)) {
            return true
        }
        
        // Public sessions
        return session.visibility === 'public'
    }
}
```

### Graceful Degradation

Team features should enhance rather than hinder individual productivity:

```typescript
class ResilientTeamFeatures {
    private readonly essentialFeatures = new Set(['core_sync', 'basic_sharing'])
    private readonly optionalFeatures = new Set(['presence', 'notifications', 'analytics'])
    
    async initialize(): Promise<FeatureAvailability> {
        const availability = {
            essential: new Map<string, boolean>(),
            optional: new Map<string, boolean>()
        }
        
        // Essential features must work
        for (const feature of this.essentialFeatures) {
            try {
                await this.enableFeature(feature)
                availability.essential.set(feature, true)
            } catch (error) {
                availability.essential.set(feature, false)
                this.logger.error(`Critical feature ${feature} failed`, error)
            }
        }
        
        // Optional features fail silently
        for (const feature of this.optionalFeatures) {
            try {
                await this.enableFeature(feature)
                availability.optional.set(feature, true)
            } catch (error) {
                availability.optional.set(feature, false)
                this.logger.warn(`Optional feature ${feature} unavailable`, error)
            }
        }
        
        return availability
    }
    
    async adaptToFailure(failedFeature: string): Promise<void> {
        if (this.essentialFeatures.has(failedFeature)) {
            // Find alternative or fallback for essential features
            await this.activateFallback(failedFeature)
        } else {
            // Simply disable optional features
            this.disableFeature(failedFeature)
        }
    }
}
```

## The Human Element

Technology enables collaboration, but human factors determine its success. The best team features feel invisible—they surface information when needed without creating friction.

Consider how developers actually work. They context-switch between tasks, collaborate asynchronously, and need deep focus time. Team features should enhance these natural patterns, not fight them.

The AI assistant becomes a team member itself, one that never forgets context, always follows standards, and can coordinate seamlessly across sessions. But it needs the right infrastructure to fulfill this role.

## Looking Forward

Team workflows in AI-assisted development are still evolving. As models become more capable and developers more comfortable with AI assistance, new patterns will emerge. The foundation Amp provides—reactive architecture, thread-based conversations, and robust synchronization—creates space for this evolution.

The next chapter explores how these team features integrate with existing enterprise systems, from authentication providers to development toolchains. The boundaries between AI assistants and traditional development infrastructure continue to blur, creating new possibilities for how teams build software together.