# Chapter 9: Enterprise Integration Patterns

Enterprise adoption of AI coding assistants brings unique challenges. Organizations need centralized control over access, usage monitoring for cost management, compliance with security policies, and integration with existing infrastructure. This chapter explores patterns for scaling AI coding assistants from individual developers to enterprise deployments serving thousands of users.

## The Enterprise Challenge

When AI coding assistants move from individual adoption to enterprise deployment, new requirements emerge:

1. **Identity Federation** - Integrate with corporate SSO systems
2. **Usage Visibility** - Track costs across teams and projects
3. **Access Control** - Manage permissions at organizational scale
4. **Compliance** - Meet security and regulatory requirements
5. **Cost Management** - Control spend and allocate budgets
6. **Performance** - Handle thousands of concurrent users

Traditional SaaS patterns don't directly apply. Unlike web applications where users interact through browsers, AI assistants operate across terminals, IDEs, and CI/CD pipelines. Usage patterns are bursty—a single code review might generate thousands of API calls in seconds.

## Enterprise Authentication Patterns

Enterprise SSO adds complexity beyond individual OAuth flows. Organizations need identity federation that maps corporate identities to AI assistant accounts while maintaining security and compliance.

### SAML Integration Patterns

SAML remains dominant for enterprise authentication. Here's a typical implementation pattern:

```typescript
class EnterpriseAuthService {
    constructor(
        private identityProvider: IdentityProvider,
        private userManager: UserManager,
        private accessController: AccessController
    ) {}
    
    async handleSSORequest(
        request: AuthRequest
    ): Promise<SSOAuthRequest> {
        // Extract organization context
        const orgContext = this.extractOrgContext(request)
        const ssoConfig = await this.getOrgConfig(orgContext.orgID)
        
        // Build authentication request
        const authRequest = {
            id: crypto.randomUUID(),
            timestamp: Date.now(),
            destination: ssoConfig.providerURL,
            issuer: this.config.entityID,
            
            // Secure state for post-auth handling
            state: this.buildSecureState({
                returnTo: request.returnTo || '/workspace',
                orgID: orgContext.orgID,
                requestID: request.id
            })
        }
        
        return {
            redirectURL: this.buildAuthURL(authRequest, ssoConfig),
            state: authRequest.state
        }
    }
    
    async processSSOResponse(
        response: SSOResponse
    ): Promise<AuthResult> {
        // Validate response integrity
        await this.validateResponse(response)
        
        // Extract user identity
        const identity = this.extractIdentity(response)
        
        // Provision or update user
        const user = await this.provisionUser(identity)
        
        // Generate access credentials
        const credentials = await this.generateCredentials(user)
        
        return {
            user,
            credentials,
            permissions: await this.resolvePermissions(user)
        }
    }
    
    private async provisionUser(
        identity: UserIdentity
    ): Promise<User> {
        const existingUser = await this.userManager.findByExternalID(
            identity.externalID
        )
        
        if (existingUser) {
            // Update existing user attributes
            return this.userManager.update(existingUser.id, {
                email: identity.email,
                displayName: identity.displayName,
                groups: identity.groups,
                lastLogin: Date.now()
            })
        } else {
            // Create new user with proper defaults
            return this.userManager.create({
                externalID: identity.externalID,
                email: identity.email,
                displayName: identity.displayName,
                organizationID: identity.organizationID,
                groups: identity.groups,
                status: 'active'
            })
        }
    }
    
    async syncMemberships(
        user: User,
        externalGroups: string[]
    ): Promise<void> {
        // Get organization's group mappings
        const mappings = await this.accessController.getGroupMappings(
            user.organizationID
        )
        
        // Calculate desired team memberships
        const desiredTeams = externalGroups
            .map(group => mappings.get(group))
            .filter(Boolean)
        
        // Sync team memberships
        await this.accessController.syncUserTeams(
            user.id,
            desiredTeams
        )
    }
}
```

### Automated User Provisioning

Large enterprises need automated user lifecycle management. SCIM (System for Cross-domain Identity Management) provides standardized provisioning:

```typescript
class UserProvisioningService {
    async handleProvisioningRequest(
        request: ProvisioningRequest
    ): Promise<ProvisioningResponse> {
        switch (request.operation) {
            case 'create':
                return this.createUser(request.userData)
            case 'update':
                return this.updateUser(request.userID, request.updates)
            case 'delete':
                return this.deactivateUser(request.userID)
            case 'sync':
                return this.syncUserData(request.userID, request.userData)
        }
    }
    
    private async createUser(
        userData: ExternalUserData
    ): Promise<ProvisioningResponse> {
        // Validate user data
        await this.validateUserData(userData)
        
        // Create user account
        const user = await this.userManager.create({
            externalID: userData.id,
            email: userData.email,
            displayName: this.buildDisplayName(userData),
            organizationID: userData.organizationID,
            groups: userData.groups || [],
            permissions: await this.calculatePermissions(userData),
            status: userData.active ? 'active' : 'suspended'
        })
        
        // Set up initial workspace
        await this.workspaceManager.createUserWorkspace(user.id)
        
        return {
            success: true,
            userID: user.id,
            externalID: user.externalID,
            created: user.createdAt
        }
    }
    
    private async updateUser(
        userID: string,
        updates: UserUpdates
    ): Promise<ProvisioningResponse> {
        const user = await this.userManager.get(userID)
        if (!user) {
            throw new Error('User not found')
        }
        
        // Apply updates selectively
        const updatedUser = await this.userManager.update(userID, {
            ...(updates.email && { email: updates.email }),
            ...(updates.displayName && { displayName: updates.displayName }),
            ...(updates.groups && { groups: updates.groups }),
            ...(updates.status && { status: updates.status }),
            lastModified: Date.now()
        })
        
        // Sync group memberships if changed
        if (updates.groups) {
            await this.syncGroupMemberships(userID, updates.groups)
        }
        
        return {
            success: true,
            userID: updatedUser.id,
            lastModified: updatedUser.lastModified
        }
    }
    
    private async syncGroupMemberships(
        userID: string,
        externalGroups: string[]
    ): Promise<void> {
        const user = await this.userManager.get(userID)
        const mappings = await this.getGroupMappings(user.organizationID)
        
        // Calculate target team memberships
        const targetTeams = externalGroups
            .map(group => mappings.internalGroups.get(group))
            .filter(Boolean)
        
        // Get current memberships
        const currentTeams = await this.teamManager.getUserTeams(userID)
        
        // Add to new teams
        for (const teamID of targetTeams) {
            if (!currentTeams.includes(teamID)) {
                await this.teamManager.addMember(teamID, userID)
            }
        }
        
        // Remove from old teams
        for (const teamID of currentTeams) {
            if (!targetTeams.includes(teamID)) {
                await this.teamManager.removeMember(teamID, userID)
            }
        }
    }
}
```

## Usage Analytics and Cost Management

Enterprise deployments need comprehensive usage analytics for cost management and resource allocation. This requires tracking both aggregate metrics and detailed usage patterns.

### Comprehensive Usage Tracking

Track all AI interactions for accurate cost attribution and optimization:

```typescript
class EnterpriseUsageTracker {
    constructor(
        private analyticsService: AnalyticsService,
        private costCalculator: CostCalculator,
        private quotaManager: QuotaManager
    ) {}
    
    async recordUsage(
        request: AIRequest,
        response: AIResponse,
        context: UsageContext
    ): Promise<void> {
        const usageRecord = {
            timestamp: Date.now(),
            
            // User and org context
            userID: context.userID,
            teamID: context.teamID,
            organizationID: context.organizationID,
            
            // Request characteristics
            model: request.model,
            provider: this.getProviderType(request.model),
            requestType: request.type, // completion, embedding, etc.
            
            // Usage metrics
            inputTokens: response.usage.input_tokens,
            outputTokens: response.usage.output_tokens,
            totalTokens: response.usage.total_tokens,
            latency: response.latency,
            
            // Cost attribution
            estimatedCost: this.costCalculator.calculate(
                request.model,
                response.usage
            ),
            
            // Context for analysis
            tool: context.toolName,
            sessionID: context.sessionID,
            workspaceID: context.workspaceID,
            
            // Privacy and compliance
            dataClassification: context.dataClassification,
            containsSensitiveData: await this.detectSensitiveData(request)
        }
        
        // Store for analytics
        await this.analyticsService.record(usageRecord)
        
        // Update quota tracking
        await this.updateQuotaUsage(usageRecord)
        
        // Check for quota violations
        await this.enforceQuotas(usageRecord)
    }
    
    private async updateQuotaUsage(
        record: UsageRecord
    ): Promise<void> {
        // Update at different hierarchy levels
        const updates = [
            this.quotaManager.increment('user', record.userID, record.totalTokens),
            this.quotaManager.increment('team', record.teamID, record.totalTokens),
            this.quotaManager.increment('org', record.organizationID, record.totalTokens)
        ]
        
        await Promise.all(updates)
    }
    
    private async enforceQuotas(
        record: UsageRecord
    ): Promise<void> {
        // Check quotas at different levels
        const quotaChecks = [
            this.quotaManager.checkQuota('user', record.userID),
            this.quotaManager.checkQuota('team', record.teamID),
            this.quotaManager.checkQuota('org', record.organizationID)
        ]
        
        const results = await Promise.all(quotaChecks)
        
        // Find the most restrictive violation
        const violation = results.find(result => result.exceeded)
        
        if (violation) {
            throw new QuotaExceededException({
                level: violation.level,
                entityID: violation.entityID,
                usage: violation.currentUsage,
                limit: violation.limit,
                resetTime: violation.resetTime
            })
        }
    }
    
    async generateUsageAnalytics(
        organizationID: string,
        timeRange: TimeRange
    ): Promise<UsageAnalytics> {
        const records = await this.analyticsService.query({
            organizationID,
            timestamp: { gte: timeRange.start, lte: timeRange.end }
        })
        
        return {
            summary: {
                totalRequests: records.length,
                totalTokens: records.reduce((sum, r) => sum + r.totalTokens, 0),
                totalCost: records.reduce((sum, r) => sum + r.estimatedCost, 0),
                uniqueUsers: new Set(records.map(r => r.userID)).size
            },
            
            breakdown: {
                byUser: this.aggregateByUser(records),
                byTeam: this.aggregateByTeam(records),
                byModel: this.aggregateByModel(records),
                byTool: this.aggregateByTool(records)
            },
            
            trends: {
                dailyUsage: this.calculateDailyTrends(records),
                peakHours: this.identifyPeakUsage(records),
                growthRate: this.calculateGrowthRate(records)
            },
            
            optimization: {
                costSavingsOpportunities: this.identifyCostSavings(records),
                unusedQuotas: await this.findUnusedQuotas(organizationID),
                recommendedLimits: this.recommendQuotaAdjustments(records)
            }
        }
    }
}
```

### Usage Analytics and Insights

Transform raw usage data into actionable business intelligence:

```typescript
class UsageInsightsEngine {
    async generateAnalytics(
        organizationID: string,
        period: AnalysisPeriod
    ): Promise<UsageInsights> {
        const timeRange = this.expandPeriod(period)
        
        // Fetch usage data
        const currentUsage = await this.analyticsService.query({
            organizationID,
            timeRange
        })
        
        const previousUsage = await this.analyticsService.query({
            organizationID,
            timeRange: this.getPreviousPeriod(timeRange)
        })
        
        // Generate comprehensive insights
        return {
            summary: this.buildSummary(currentUsage),
            trends: this.analyzeTrends(currentUsage, previousUsage),
            segmentation: this.analyzeSegmentation(currentUsage),
            optimization: this.identifyOptimizations(currentUsage),
            forecasting: this.generateForecasts(currentUsage),
            anomalies: this.detectAnomalies(currentUsage, previousUsage)
        }
    }
    
    private analyzeSegmentation(
        usage: UsageRecord[]
    ): SegmentationAnalysis {
        return {
            byUser: this.segmentByUser(usage),
            byTeam: this.segmentByTeam(usage),
            byApplication: this.segmentByApplication(usage),
            byTimeOfDay: this.segmentByTimeOfDay(usage),
            byComplexity: this.segmentByComplexity(usage)
        }
    }
    
    private identifyOptimizations(
        usage: UsageRecord[]
    ): OptimizationOpportunities {
        const opportunities: OptimizationOpportunity[] = []
        
        // Model efficiency analysis
        const modelEfficiency = this.analyzeModelEfficiency(usage)
        if (modelEfficiency.hasInefficiencies) {
            opportunities.push({
                type: 'model_optimization',
                impact: 'medium',
                description: 'Switch to more cost-effective models for routine tasks',
                potentialSavings: modelEfficiency.potentialSavings,
                actions: [
                    'Use smaller models for simple tasks',
                    'Implement request routing based on complexity',
                    'Cache frequent responses'
                ]
            })
        }
        
        // Usage pattern optimization
        const patterns = this.analyzeUsagePatterns(usage)
        if (patterns.hasInefficiencies) {
            opportunities.push({
                type: 'usage_patterns',
                impact: 'high',
                description: 'Optimize request patterns and batching',
                potentialSavings: patterns.potentialSavings,
                actions: [
                    'Implement request batching',
                    'Reduce redundant requests',
                    'Optimize prompt engineering'
                ]
            })
        }
        
        // Quota optimization
        const quotaAnalysis = this.analyzeQuotaUtilization(usage)
        if (quotaAnalysis.hasWaste) {
            opportunities.push({
                type: 'quota_optimization',
                impact: 'low',
                description: 'Adjust quotas based on actual usage patterns',
                potentialSavings: quotaAnalysis.wastedBudget,
                actions: [
                    'Redistribute unused quotas',
                    'Implement dynamic quota allocation',
                    'Set up usage alerts'
                ]
            })
        }
        
        return {
            opportunities,
            totalPotentialSavings: opportunities.reduce(
                (sum, opp) => sum + opp.potentialSavings, 0
            ),
            prioritizedActions: this.prioritizeActions(opportunities)
        }
    }
    
    private detectAnomalies(
        current: UsageRecord[],
        previous: UsageRecord[]
    ): UsageAnomaly[] {
        const anomalies: UsageAnomaly[] = []
        
        // Usage spike detection
        const currentByUser = this.aggregateByUser(current)
        const previousByUser = this.aggregateByUser(previous)
        
        for (const [userID, currentUsage] of currentByUser) {
            const previousUsage = previousByUser.get(userID)
            if (!previousUsage) continue
            
            const changeRatio = currentUsage.totalCost / previousUsage.totalCost
            
            if (changeRatio > 2.5) { // 250% increase
                anomalies.push({
                    type: 'usage_spike',
                    severity: changeRatio > 5 ? 'critical' : 'high',
                    entityID: userID,
                    entityType: 'user',
                    description: `Usage increased ${Math.round(changeRatio * 100)}%`,
                    metrics: {
                        currentCost: currentUsage.totalCost,
                        previousCost: previousUsage.totalCost,
                        changeRatio
                    },
                    recommendations: [
                        'Review recent activity for unusual patterns',
                        'Check for automated scripts or bulk operations',
                        'Consider implementing usage limits'
                    ]
                })
            }
        }
        
        // Unusual timing patterns
        const hourlyDistribution = this.analyzeHourlyDistribution(current)
        for (const [hour, usage] of hourlyDistribution) {
            if (this.isOffHours(hour) && usage.intensity > this.getBaselineIntensity()) {
                anomalies.push({
                    type: 'off_hours_activity',
                    severity: 'medium',
                    description: `Unusual activity at ${hour}:00`,
                    metrics: {
                        hour,
                        requestCount: usage.requests,
                        intensity: usage.intensity
                    },
                    recommendations: [
                        'Verify legitimate business need',
                        'Check for automated processes',
                        'Consider rate limiting during off-hours'
                    ]
                })
            }
        }
        
        // Model usage anomalies
        const modelAnomalies = this.detectModelAnomalies(current, previous)
        anomalies.push(...modelAnomalies)
        
        return anomalies
    }
}
```

## Administrative Dashboards

Enterprise administrators need comprehensive dashboards for managing AI assistant deployments. These provide real-time visibility and operational control.

### Organization Overview

The main admin dashboard aggregates key metrics:

```typescript
export class AdminDashboard {
  async getOrganizationOverview(
    orgId: string
  ): Promise<OrganizationOverview> {
    // Fetch current stats
    const [
      userStats,
      usageStats,
      costStats,
      healthStatus
    ] = await Promise.all([
      this.getUserStatistics(orgId),
      this.getUsageStatistics(orgId),
      this.getCostStatistics(orgId),
      this.getHealthStatus(orgId)
    ]);
    
    return {
      organization: await this.orgService.get(orgId),
      
      users: {
        total: userStats.total,
        active: userStats.activeLastWeek,
        pending: userStats.pendingInvites,
        growth: userStats.growthRate
      },
      
      usage: {
        tokensToday: usageStats.today.tokens,
        requestsToday: usageStats.today.requests,
        tokensThisMonth: usageStats.month.tokens,
        requestsThisMonth: usageStats.month.requests,
        
        // Breakdown by model
        modelUsage: usageStats.byModel,
        
        // Peak usage times
        peakHours: usageStats.peakHours,
        
        // Usage trends
        dailyTrend: usageStats.dailyTrend
      },
      
      costs: {
        today: costStats.today,
        monthToDate: costStats.monthToDate,
        projected: costStats.projectedMonthly,
        budget: costStats.budget,
        budgetRemaining: costStats.budget - costStats.monthToDate,
        
        // Cost breakdown
        byTeam: costStats.byTeam,
        byModel: costStats.byModel
      },
      
      health: {
        status: healthStatus.overall,
        apiLatency: healthStatus.apiLatency,
        errorRate: healthStatus.errorRate,
        quotaUtilization: healthStatus.quotaUtilization,
        
        // Recent incidents
        incidents: healthStatus.recentIncidents
      }
    };
  }

  async getTeamManagement(
    orgId: string
  ): Promise<TeamManagementView> {
    const teams = await this.teamService.getByOrganization(orgId);
    
    const teamDetails = await Promise.all(
      teams.map(async team => ({
        team,
        members: await this.teamService.getMembers(team.id),
        usage: await this.usageService.getTeamUsage(team.id),
        settings: await this.teamService.getSettings(team.id),
        
        // Access patterns
        activeHours: await this.getActiveHours(team.id),
        topTools: await this.getTopTools(team.id),
        
        // Compliance
        dataAccess: await this.auditService.getDataAccess(team.id)
      }))
    );
    
    return {
      teams: teamDetails,
      
      // Org-wide team analytics
      crossTeamCollaboration: await this.analyzeCrossTeamUsage(orgId),
      sharedResources: await this.getSharedResources(orgId)
    };
  }
}
```

### User Management

Administrators need fine-grained control over user access:

```typescript
export class UserManagementService {
  async getUserDetails(
    userId: string,
    orgId: string
  ): Promise<UserDetails> {
    const user = await this.userService.get(userId);
    
    // Verify user belongs to organization
    if (user.organizationId !== orgId) {
      throw new Error('User not in organization');
    }
    
    const [
      teams,
      usage,
      activity,
      permissions,
      devices
    ] = await Promise.all([
      this.teamService.getUserTeams(userId),
      this.usageService.getUserUsage(userId),
      this.activityService.getUserActivity(userId),
      this.permissionService.getUserPermissions(userId),
      this.deviceService.getUserDevices(userId)
    ]);
    
    return {
      user,
      teams,
      usage: {
        current: usage.current,
        history: usage.history,
        quotas: usage.quotas
      },
      activity: {
        lastActive: activity.lastActive,
        sessionsToday: activity.sessionsToday,
        primaryTools: activity.topTools,
        activityHeatmap: activity.hourlyActivity
      },
      permissions,
      devices: devices.map(d => ({
        id: d.id,
        type: d.type,
        lastSeen: d.lastSeen,
        platform: d.platform,
        ipAddress: d.ipAddress
      })),
      
      // Compliance and security
      dataAccess: await this.getDataAccessLog(userId),
      securityEvents: await this.getSecurityEvents(userId)
    };
  }

  async updateUserAccess(
    userId: string,
    updates: UserAccessUpdate
  ): Promise<void> {
    // Validate admin permissions
    await this.validateAdminPermissions(updates.adminId);
    
    // Apply updates
    if (updates.teams) {
      await this.updateTeamMemberships(userId, updates.teams);
    }
    
    if (updates.permissions) {
      await this.updatePermissions(userId, updates.permissions);
    }
    
    if (updates.quotas) {
      await this.updateQuotas(userId, updates.quotas);
    }
    
    if (updates.status) {
      await this.updateUserStatus(userId, updates.status);
    }
    
    // Audit log
    await this.auditService.log({
      action: 'user.access.update',
      adminId: updates.adminId,
      targetUserId: userId,
      changes: updates,
      timestamp: new Date()
    });
  }

  async bulkUserOperations(
    operation: BulkOperation
  ): Promise<BulkOperationResult> {
    const results = {
      successful: 0,
      failed: 0,
      errors: [] as Error[]
    };
    
    // Process in batches to avoid overwhelming the system
    const batches = this.chunk(operation.userIds, 50);
    
    for (const batch of batches) {
      const batchResults = await Promise.allSettled(
        batch.map(userId => 
          this.applyOperation(userId, operation)
        )
      );
      
      for (const result of batchResults) {
        if (result.status === 'fulfilled') {
          results.successful++;
        } else {
          results.failed++;
          results.errors.push(result.reason);
        }
      }
    }
    
    return results;
  }
}
```

## API Rate Limiting

At enterprise scale, rate limiting becomes critical for both cost control and system stability. Enterprise AI systems implement multi-layer rate limiting:

### Token Bucket Implementation

Rate limiting uses token buckets for flexible burst handling:

```typescript
export class RateLimiter {
  private buckets = new Map<string, TokenBucket>();
  
  constructor(
    private redis: Redis,
    private config: RateLimitConfig
  ) {}

  async checkLimit(
    key: string,
    cost: number = 1
  ): Promise<RateLimitResult> {
    const bucket = await this.getBucket(key);
    const now = Date.now();
    
    // Refill tokens based on time elapsed
    const elapsed = now - bucket.lastRefill;
    const tokensToAdd = (elapsed / 1000) * bucket.refillRate;
    bucket.tokens = Math.min(
      bucket.capacity,
      bucket.tokens + tokensToAdd
    );
    bucket.lastRefill = now;
    
    // Check if request can proceed
    if (bucket.tokens >= cost) {
      bucket.tokens -= cost;
      await this.saveBucket(key, bucket);
      
      return {
        allowed: true,
        remaining: Math.floor(bucket.tokens),
        reset: this.calculateReset(bucket)
      };
    }
    
    // Calculate when tokens will be available
    const tokensNeeded = cost - bucket.tokens;
    const timeToWait = (tokensNeeded / bucket.refillRate) * 1000;
    
    return {
      allowed: false,
      remaining: Math.floor(bucket.tokens),
      reset: now + timeToWait,
      retryAfter: Math.ceil(timeToWait / 1000)
    };
  }

  private async getBucket(key: string): Promise<TokenBucket> {
    // Try to get from Redis
    const cached = await this.redis.get(`ratelimit:${key}`);
    if (cached) {
      return JSON.parse(cached);
    }
    
    // Create new bucket based on key type
    const config = this.getConfigForKey(key);
    const bucket: TokenBucket = {
      tokens: config.capacity,
      capacity: config.capacity,
      refillRate: config.refillRate,
      lastRefill: Date.now()
    };
    
    await this.saveBucket(key, bucket);
    return bucket;
  }

  private getConfigForKey(key: string): BucketConfig {
    // User-level limits
    if (key.startsWith('user:')) {
      return this.config.userLimits;
    }
    
    // Team-level limits
    if (key.startsWith('team:')) {
      return this.config.teamLimits;
    }
    
    // Organization-level limits
    if (key.startsWith('org:')) {
      return this.config.orgLimits;
    }
    
    // API key specific limits
    if (key.startsWith('apikey:')) {
      return this.config.apiKeyLimits;
    }
    
    // Default limits
    return this.config.defaultLimits;
  }
}
```

### Hierarchical Rate Limiting

Enterprise deployments need rate limiting at multiple levels:

```typescript
export class HierarchicalRateLimiter {
  constructor(
    private rateLimiter: RateLimiter,
    private quotaService: QuotaService
  ) {}

  async checkAllLimits(
    context: RequestContext
  ): Promise<RateLimitResult> {
    const limits = [
      // User level
      this.rateLimiter.checkLimit(
        `user:${context.userId}`,
        context.estimatedCost
      ),
      
      // Team level (if applicable)
      context.teamId ? 
        this.rateLimiter.checkLimit(
          `team:${context.teamId}`,
          context.estimatedCost
        ) : Promise.resolve({ allowed: true }),
      
      // Organization level
      this.rateLimiter.checkLimit(
        `org:${context.orgId}`,
        context.estimatedCost
      ),
      
      // API key level
      this.rateLimiter.checkLimit(
        `apikey:${context.apiKeyId}`,
        context.estimatedCost
      ),
      
      // Model-specific limits
      this.rateLimiter.checkLimit(
        `model:${context.orgId}:${context.model}`,
        context.estimatedCost
      )
    ];
    
    const results = await Promise.all(limits);
    
    // Find the most restrictive limit
    const blocked = results.find(r => !r.allowed);
    if (blocked) {
      return blocked;
    }
    
    // Check quota limits (different from rate limits)
    const quotaCheck = await this.checkQuotas(context);
    if (!quotaCheck.allowed) {
      return quotaCheck;
    }
    
    // All limits passed
    return {
      allowed: true,
      remaining: Math.min(...results.map(r => r.remaining || Infinity))
    };
  }

  private async checkQuotas(
    context: RequestContext
  ): Promise<RateLimitResult> {
    // Check monthly token quota
    const monthlyQuota = await this.quotaService.getMonthlyQuota(
      context.orgId
    );
    
    const used = await this.quotaService.getMonthlyUsage(
      context.orgId
    );
    
    const remaining = monthlyQuota - used;
    
    if (remaining < context.estimatedTokens) {
      return {
        allowed: false,
        reason: 'Monthly quota exceeded',
        quotaRemaining: remaining,
        quotaReset: this.getMonthlyReset()
      };
    }
    
    // Check daily operation limits
    const dailyOps = await this.quotaService.getDailyOperations(
      context.orgId,
      context.operation
    );
    
    if (dailyOps.used >= dailyOps.limit) {
      return {
        allowed: false,
        reason: `Daily ${context.operation} limit exceeded`,
        opsRemaining: 0,
        opsReset: this.getDailyReset()
      };
    }
    
    return { allowed: true };
  }
}
```

### Adaptive Rate Limiting

Smart rate limiting adjusts based on system load:

```typescript
export class AdaptiveRateLimiter {
  private loadMultiplier = 1.0;
  
  constructor(
    private metricsService: MetricsService,
    private rateLimiter: RateLimiter
  ) {
    // Periodically adjust based on system load
    setInterval(() => this.adjustLimits(), 60000);
  }

  async adjustLimits(): Promise<void> {
    const metrics = await this.metricsService.getSystemMetrics();
    
    // Calculate load factor
    const cpuLoad = metrics.cpu.usage / metrics.cpu.target;
    const memoryLoad = metrics.memory.usage / metrics.memory.target;
    const queueDepth = metrics.queue.depth / metrics.queue.target;
    
    const loadFactor = Math.max(cpuLoad, memoryLoad, queueDepth);
    
    // Adjust multiplier
    if (loadFactor > 1.2) {
      // System overloaded, reduce limits
      this.loadMultiplier = Math.max(0.5, this.loadMultiplier * 0.9);
    } else if (loadFactor < 0.8) {
      // System has capacity, increase limits
      this.loadMultiplier = Math.min(1.5, this.loadMultiplier * 1.1);
    }
    
    // Apply multiplier to rate limits
    await this.rateLimiter.setMultiplier(this.loadMultiplier);
    
    // Log adjustment
    await this.metricsService.recordAdjustment({
      timestamp: new Date(),
      loadFactor,
      multiplier: this.loadMultiplier,
      metrics
    });
  }

  async checkLimitWithBackpressure(
    key: string,
    cost: number
  ): Promise<RateLimitResult> {
    // Apply load multiplier to cost
    const adjustedCost = cost / this.loadMultiplier;
    
    const result = await this.rateLimiter.checkLimit(
      key,
      adjustedCost
    );
    
    // Add queue position if rate limited
    if (!result.allowed) {
      const queuePosition = await this.getQueuePosition(key);
      result.queuePosition = queuePosition;
      result.estimatedWait = this.estimateWaitTime(queuePosition);
    }
    
    return result;
  }
}
```

## Cost Optimization Strategies

Enterprise customers need tools to optimize their AI spend. AI assistant platforms provide several mechanisms:

### Model Routing

Route requests to the most cost-effective model:

```typescript
export class ModelRouter {
  constructor(
    private modelService: ModelService,
    private costCalculator: CostCalculator
  ) {}

  async selectModel(
    request: ModelRequest,
    constraints: ModelConstraints
  ): Promise<ModelSelection> {
    // Get available models
    const models = await this.modelService.getAvailable();
    
    // Filter by capabilities
    const capable = models.filter(m => 
      this.meetsRequirements(m, request)
    );
    
    // Score models based on constraints
    const scored = capable.map(model => ({
      model,
      score: this.scoreModel(model, request, constraints)
    }));
    
    // Sort by score
    scored.sort((a, b) => b.score - a.score);
    
    const selected = scored[0];
    
    return {
      model: selected.model,
      reasoning: this.explainSelection(selected, constraints),
      estimatedCost: this.costCalculator.estimate(
        selected.model,
        request
      ),
      alternatives: scored.slice(1, 4).map(s => ({
        model: s.model.name,
        costDifference: this.calculateCostDifference(
          selected.model,
          s.model,
          request
        )
      }))
    };
  }

  private scoreModel(
    model: Model,
    request: ModelRequest,
    constraints: ModelConstraints
  ): number {
    let score = 100;
    
    // Cost weight (typically highest priority)
    const costScore = this.calculateCostScore(model, request);
    score += costScore * (constraints.costWeight || 0.5);
    
    // Performance weight
    const perfScore = this.calculatePerformanceScore(model);
    score += perfScore * (constraints.performanceWeight || 0.3);
    
    // Quality weight
    const qualityScore = this.calculateQualityScore(model, request);
    score += qualityScore * (constraints.qualityWeight || 0.2);
    
    // Penalties
    if (model.latencyP95 > constraints.maxLatency) {
      score *= 0.5; // Heavily penalize slow models
    }
    
    if (model.contextWindow < request.estimatedContext) {
      score = 0; // Disqualify if context too small
    }
    
    return score;
  }

  async implementCaching(
    request: CachedRequest
  ): Promise<CachedResponse | null> {
    // Generate cache key
    const key = this.generateCacheKey(request);
    
    // Check cache
    const cached = await this.cache.get(key);
    if (cached && !this.isStale(cached)) {
      return {
        response: cached.response,
        source: 'cache',
        savedCost: this.calculateSavedCost(request)
      };
    }
    
    return null;
  }
}
```

### Usage Policies

Implement policies to control costs:

```typescript
export class UsagePolicyEngine {
  async evaluateRequest(
    request: PolicyRequest
  ): Promise<PolicyDecision> {
    // Load applicable policies
    const policies = await this.loadPolicies(
      request.organizationId,
      request.teamId,
      request.userId
    );
    
    // Evaluate each policy
    const results = await Promise.all(
      policies.map(p => this.evaluatePolicy(p, request))
    );
    
    // Combine results
    const denied = results.find(r => r.action === 'deny');
    if (denied) {
      return denied;
    }
    
    const modified = results.filter(r => r.action === 'modify');
    if (modified.length > 0) {
      return this.combineModifications(modified, request);
    }
    
    return { action: 'allow' };
  }

  private async evaluatePolicy(
    policy: UsagePolicy,
    request: PolicyRequest
  ): Promise<PolicyResult> {
    // Time-based restrictions
    if (policy.timeRestrictions) {
      const allowed = this.checkTimeRestrictions(
        policy.timeRestrictions
      );
      if (!allowed) {
        return {
          action: 'deny',
          reason: 'Outside allowed hours',
          policy: policy.name
        };
      }
    }
    
    // Model restrictions
    if (policy.modelRestrictions) {
      if (!policy.modelRestrictions.includes(request.model)) {
        // Try to find alternative
        const alternative = this.findAllowedModel(
          policy.modelRestrictions,
          request
        );
        
        if (alternative) {
          return {
            action: 'modify',
            modifications: { model: alternative },
            reason: `Using ${alternative} per policy`,
            policy: policy.name
          };
        } else {
          return {
            action: 'deny',
            reason: 'Model not allowed by policy',
            policy: policy.name
          };
        }
      }
    }
    
    // Cost thresholds
    if (policy.costThresholds) {
      const estimatedCost = await this.estimateCost(request);
      
      if (estimatedCost > policy.costThresholds.perRequest) {
        return {
          action: 'deny',
          reason: 'Request exceeds cost threshold',
          policy: policy.name,
          details: {
            estimated: estimatedCost,
            limit: policy.costThresholds.perRequest
          }
        };
      }
    }
    
    // Context size limits
    if (policy.contextLimits) {
      if (request.contextSize > policy.contextLimits.max) {
        return {
          action: 'modify',
          modifications: {
            contextSize: policy.contextLimits.max,
            truncationStrategy: 'tail'
          },
          reason: 'Context truncated per policy',
          policy: policy.name
        };
      }
    }
    
    return { action: 'allow' };
  }
}
```

## Security and Compliance

Enterprise deployments must meet strict security requirements:

### Data Loss Prevention

Prevent sensitive data from leaving the organization:

```typescript
export class DLPEngine {
  constructor(
    private patterns: DLPPatternService,
    private classifier: DataClassifier
  ) {}

  async scanRequest(
    request: CompletionRequest
  ): Promise<DLPScanResult> {
    const findings: DLPFinding[] = [];
    
    // Scan for pattern matches
    for (const message of request.messages) {
      const patternMatches = await this.patterns.scan(
        message.content
      );
      
      findings.push(...patternMatches.map(match => ({
        type: 'pattern',
        severity: match.severity,
        pattern: match.pattern.name,
        location: {
          messageIndex: request.messages.indexOf(message),
          start: match.start,
          end: match.end
        }
      })));
    }
    
    // Classify data sensitivity
    const classification = await this.classifier.classify(
      request.messages.map(m => m.content).join('\n')
    );
    
    if (classification.sensitivity > 0.8) {
      findings.push({
        type: 'classification',
        severity: 'high',
        classification: classification.label,
        confidence: classification.confidence
      });
    }
    
    // Determine action
    const action = this.determineAction(findings);
    
    return {
      findings,
      action,
      redactedRequest: action === 'redact' ? 
        await this.redactRequest(request, findings) : null
    };
  }

  private async redactRequest(
    request: CompletionRequest,
    findings: DLPFinding[]
  ): Promise<CompletionRequest> {
    const redacted = JSON.parse(JSON.stringify(request));
    
    // Sort findings by position (reverse order)
    const sorted = findings
      .filter(f => f.location)
      .sort((a, b) => b.location!.start - a.location!.start);
    
    for (const finding of sorted) {
      const message = redacted.messages[finding.location!.messageIndex];
      
      // Replace with redaction marker
      const before = message.content.substring(0, finding.location!.start);
      const after = message.content.substring(finding.location!.end);
      const redactionMarker = `[REDACTED:${finding.pattern || finding.classification}]`;
      
      message.content = before + redactionMarker + after;
    }
    
    return redacted;
  }
}
```

### Audit Logging

Comprehensive audit trails for compliance:

```typescript
export class AuditLogger {
  async logAPICall(
    request: Request,
    response: Response,
    context: RequestContext
  ): Promise<void> {
    const entry: AuditEntry = {
      id: crypto.randomUUID(),
      timestamp: new Date(),
      
      // User context
      userId: context.userId,
      userName: context.user.name,
      userEmail: context.user.email,
      teamId: context.teamId,
      organizationId: context.organizationId,
      
      // Request details
      method: request.method,
      path: request.path,
      model: request.body?.model,
      toolName: context.toolName,
      
      // Response details
      statusCode: response.statusCode,
      duration: response.duration,
      tokensUsed: response.usage?.total_tokens,
      cost: response.usage?.cost,
      
      // Security context
      ipAddress: request.ip,
      userAgent: request.headers['user-agent'],
      apiKeyId: context.apiKeyId,
      sessionId: context.sessionId,
      
      // Compliance metadata
      dataClassification: context.dataClassification,
      dlpFindings: context.dlpFindings?.length || 0,
      policyViolations: context.policyViolations
    };
    
    // Store in append-only audit log
    await this.auditStore.append(entry);
    
    // Index for searching
    await this.auditIndex.index(entry);
    
    // Stream to SIEM if configured
    if (this.siemIntegration) {
      await this.siemIntegration.send(entry);
    }
  }

  async generateComplianceReport(
    organizationId: string,
    period: DateRange
  ): Promise<ComplianceReport> {
    const entries = await this.auditStore.query({
      organizationId,
      timestamp: { $gte: period.start, $lte: period.end }
    });
    
    return {
      period,
      summary: {
        totalRequests: entries.length,
        uniqueUsers: new Set(entries.map(e => e.userId)).size,
        
        // Data access patterns
        dataAccess: this.analyzeDataAccess(entries),
        
        // Policy compliance
        policyViolations: entries.filter(e => 
          e.policyViolations && e.policyViolations.length > 0
        ),
        
        // Security events
        securityEvents: this.identifySecurityEvents(entries),
        
        // Cost summary
        totalCost: entries.reduce((sum, e) => 
          sum + (e.cost || 0), 0
        )
      },
      
      // Detailed breakdowns
      userActivity: this.generateUserActivityReport(entries),
      dataFlows: this.analyzeDataFlows(entries),
      anomalies: this.detectAnomalies(entries)
    };
  }
}
```

## Integration Patterns

Enterprise AI assistant deployments integrate with existing infrastructure:

### LDAP Synchronization

Keep user directories in sync:

```typescript
export class LDAPSync {
  async syncUsers(): Promise<SyncResult> {
    const ldapUsers = await this.ldapClient.search({
      base: this.config.baseDN,
      filter: '(objectClass=user)',
      attributes: ['uid', 'mail', 'cn', 'memberOf']
    });
    
    const results = {
      created: 0,
      updated: 0,
      disabled: 0,
      errors: [] as Error[]
    };
    
    // Process each LDAP user
    for (const ldapUser of ldapUsers) {
      try {
        const assistantUser = await this.mapLDAPUser(ldapUser);
        
        const existing = await this.userService.findByExternalId(
          assistantUser.externalId
        );
        
        if (existing) {
          // Update existing user
          await this.updateUser(existing, assistantUser);
          results.updated++;
        } else {
          // Create new user
          await this.createUser(assistantUser);
          results.created++;
        }
      } catch (error) {
        results.errors.push(error);
      }
    }
    
    // Disable users not in LDAP
    const assistantUsers = await this.userService.getByOrganization(
      this.organizationId
    );
    
    const ldapIds = new Set(ldapUsers.map(u => u.uid));
    
    for (const user of assistantUsers) {
      if (!ldapIds.has(user.externalId)) {
        await this.userService.disable(user.id);
        results.disabled++;
      }
    }
    
    return results;
  }
}
```

### Webhook Integration

Real-time event notifications:

```typescript
export class WebhookService {
  async dispatch(
    event: WebhookEvent
  ): Promise<void> {
    // Get configured webhooks for this event type
    const webhooks = await this.getWebhooks(
      event.organizationId,
      event.type
    );
    
    // Dispatch to each endpoint
    const dispatches = webhooks.map(webhook => 
      this.sendWebhook(webhook, event)
    );
    
    await Promise.allSettled(dispatches);
  }

  private async sendWebhook(
    webhook: Webhook,
    event: WebhookEvent
  ): Promise<void> {
    const payload = {
      id: event.id,
      type: event.type,
      timestamp: event.timestamp,
      organizationId: event.organizationId,
      data: event.data,
      
      // Signature for verification
      signature: await this.signPayload(
        event,
        webhook.secret
      )
    };
    
    const response = await fetch(webhook.url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Amp-Event': event.type,
        'X-Amp-Signature': payload.signature
      },
      body: JSON.stringify(payload),
      
      // Timeout after 30 seconds
      signal: AbortSignal.timeout(30000)
    });
    
    // Record delivery attempt
    await this.recordDelivery({
      webhookId: webhook.id,
      eventId: event.id,
      attemptedAt: new Date(),
      responseStatus: response.status,
      success: response.ok
    });
    
    // Retry if failed
    if (!response.ok) {
      await this.scheduleRetry(webhook, event);
    }
  }
}
```

## Implementation Principles

Enterprise AI assistant integration requires balancing organizational control with developer productivity. Key patterns include:

### Foundational Patterns
- **Identity federation** through SAML/OIDC enables seamless authentication while maintaining security
- **Usage analytics** provide cost visibility and optimization opportunities
- **Administrative controls** offer centralized management without blocking individual productivity
- **Rate limiting** ensures fair resource distribution and system stability
- **Compliance features** meet regulatory and security requirements

### Design Philosophy
The challenge lies in balancing enterprise requirements with user experience. Excessive control frustrates developers; insufficient oversight concerns IT departments. Successful implementations provide:

1. **Sensible defaults** that work immediately while allowing customization
2. **Progressive disclosure** of advanced features based on organizational maturity
3. **Graceful degradation** when enterprise services are unavailable
4. **Clear feedback** on policies and constraints
5. **Escape hatches** for exceptional circumstances

### Technology Integration
Enterprise AI assistants must integrate with existing infrastructure:
- Identity providers (Active Directory, Okta, etc.)
- Development toolchains (Git, CI/CD, monitoring)
- Security systems (SIEM, DLP, vulnerability scanners)
- Business systems (project management, time tracking)

### Success Metrics
Measure enterprise integration success through:
- **Adoption rate** across the organization
- **Time to productivity** for new users
- **Support ticket volume** and resolution time
- **Security incident rate** and response effectiveness
- **Cost predictability** and optimization achievements

The next evolution involves multi-agent orchestration—coordinating multiple AI capabilities to handle complex tasks that exceed individual model capabilities. This represents the frontier of AI-assisted development, where systems become true collaborative partners in software creation.