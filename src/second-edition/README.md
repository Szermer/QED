# Amping Up an Agentic System

Welcome to the second edition of "Building an Agentic System." This book explores the evolution from local-first AI coding assistants to collaborative, server-based systems through deep analysis of Amp—Sourcegraph's multi-user AI development platform.

## What's New in This Edition

While the first edition focused on building single-user AI coding assistants like Claude Code, this edition tackles the challenges of scaling to teams:

- **Server-first architecture** enabling real-time collaboration
- **Multi-user workflows** with presence, permissions, and sharing
- **Enterprise patterns** for authentication, usage tracking, and compliance
- **Production deployment** strategies for thousands of concurrent users
- **Multi-agent orchestration** for complex, distributed tasks

## Who This Book Is For

This book is written for engineers building the next generation of AI development tools:

- Senior engineers architecting production AI systems
- Technical leads implementing collaborative AI workflows
- Platform engineers designing multi-tenant architectures
- Developers transitioning from local-first to cloud-native AI tools

## What You'll Learn

Through practical examples and real code from Amp's implementation, you'll discover:

1. **Architectural patterns** for server-based AI systems
2. **Synchronization strategies** for real-time collaboration
3. **Permission models** supporting team hierarchies
4. **Performance optimization** for LLM-heavy workloads
5. **Enterprise features** from SSO to usage analytics

## How to Read This Book

The book is organized into six parts:

- **Part I: Foundations** - Core concepts and architecture overview
- **Part II: Core Systems** - Threading, sync, and tool execution
- **Part III: Collaboration** - Multi-user features and permissions
- **Part IV: Advanced Patterns** - Orchestration and scale
- **Part V: Implementation** - Building and migrating systems
- **Part VI: Future** - Emerging patterns and ecosystem evolution

Each chapter builds on previous concepts while remaining self-contained enough to serve as a reference.

## Code Examples

All code examples are drawn from Amp's actual implementation, available in the `amp/` directory. Look for these patterns throughout:

```typescript
// Observable-based state management
export class ThreadService {
  private threads$ = new BehaviorSubject<Thread[]>([]);
  
  getThreads(): Observable<Thread[]> {
    return this.threads$.asObservable();
  }
}
```

## Getting Started

Ready to build collaborative AI systems? Let's begin with Chapter 1, where we'll explore the journey from local-first Claude Code to server-based Amp, and why this evolution matters for the future of AI-assisted development.