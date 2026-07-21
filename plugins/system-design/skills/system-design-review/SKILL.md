---
name: system-design-review
description: Architectural review covering module boundaries, coupling, scalability, and design clarity. Use when auditing structural changes or doing a design review.
disable-model-invocation: true
---

# System Design Review

Use this skill for an architectural review of the current branch's changes. The goal is to catch design problems — not to enforce a single architecture, but to ensure changes are consistent with the project's structure and do not introduce coupling, ambiguity, or scalability issues.

## Core Prompt

> Perform an architectural review of the current branch's changes.
> Identify concrete design issues, not theoretical preferences.
> For each finding, explain the problem, the impact, and the alternative.
> Be practical: focus on changes that affect maintainability, scalability, or clarity.

## Review Categories

### 1. Module Boundaries

- Code placed in the wrong module or layer
- Leaking internal types across module boundaries
- Circular dependencies between modules
- Modules that do too much (god modules)
- Modules that do too little (unnecessary indirection)
- Public API surface larger than necessary

### 2. Coupling

- Tight coupling between unrelated features
- Changes in one module requiring changes in many others
- Dependency direction violations: high-level modules depending on low-level ones
- Shared mutable state across module boundaries
- Global singletons that prevent testing and reuse
- Configuration passed through layers that do not use it

### 3. Abstractions

- Leaky abstractions: details of the implementation visible at the boundary
- Premature abstraction: generalizing before the pattern is clear
- Missing abstraction: raw logic where a concept would clarify intent
- Over-abstraction: indirection that adds complexity without value
- Interface segregation: interfaces that force implementers to depend on things they do not use

### 4. Error Handling

- Errors that lose context across module boundaries
- Inconsistent error types across similar operations
- Catch-all error types that hide the nature of failures
- Missing error context for operations that need it
- Error handling that hides bugs rather than surfacing them
- Panics in library code that should return errors

### 5. Data Flow

- Shared mutable state that makes data flow unclear
- Data transformation spread across multiple layers
- Duplicate representations of the same concept
- Missing or unclear ownership of data
- Configuration scattered across multiple sources without clear precedence

### 6. Scalability

- Single points of failure in critical paths
- Unbounded growth: collections, queues, caches without limits
- Synchronous bottlenecks in async systems
- Missing rate limiting on external calls
- Resource exhaustion under load: file descriptors, memory, connections

### 7. Consistency

- Similar operations handled differently without reason
- Naming inconsistencies across modules
- Different patterns for the same problem in different parts of the codebase
- Inconsistent configuration formats or API styles
- Mixed conventions for error handling, logging, or metadata

### 8. Testability

- Code that cannot be tested without starting the entire system
- Dependencies that cannot be mocked or replaced
- Global state that prevents test isolation
- Business logic tangled with I/O in ways that prevent unit testing
- Test infrastructure that duplicates production logic

## Severity Levels

**Critical** — Architectural decision that causes data loss, security issues, or prevents the system from scaling to meet requirements.
**High** — Design problem that significantly increases maintenance burden or blocks future development.
**Medium** — Structural inconsistency that makes the codebase harder to navigate or modify.
**Low** — Minor organizational improvement that would help clarity.
**Informational** — Style or preference that does not affect correctness or maintainability.

## What to Flag Aggressively

- Code placed in the wrong layer or module
- Leaking internal types across boundaries
- New global state or singletons
- Business logic mixed with I/O in ways that prevent testing
- Unbounded growth in collections or caches
- Circular dependencies
- Abstractions that add complexity without value
- Inconsistent patterns for the same problem
- Missing error context across module boundaries
- Dependency direction violations

## What Not to Over-Index On

- Style preferences that do not affect maintainability
- Theoretical scalability issues with no realistic data volume
- Minor naming differences that are consistent within their module
- Implementation details hidden behind clean interfaces
- Patterns that differ between modules for good reasons

## Finding Format

For each finding, provide:

1. **Location**: file, module, or boundary
2. **Category**: boundaries, coupling, abstractions, error handling, data flow, scalability, consistency, testability
3. **Severity**: critical / high / medium / low / informational
4. **Problem**: what is wrong with the design
5. **Impact**: how this affects maintainability, scalability, or testing
6. **Alternative**: what the design should be instead

## Review Tone

Be direct and specific. Name the design problem and its concrete impact.

Good phrases:

- `this module now depends on three unrelated modules — high coupling`
- `this internal type leaks across the public API — abstraction boundary broken`
- `this global configuration is modified in two places — unclear ownership`
- `this business logic is tangled with the HTTP handler — untestable`
- `this collection grows without bound — will exhaust memory under load`
- `this error is caught and re-thrown as a generic error — context lost`
- `these two modules handle the same problem differently — inconsistency`
- `this module does too much — should be split`
- `this abstraction adds indirection without clarifying intent — over-designed`
- `the dependency direction is inverted — high-level module depends on low-level detail`

## Approval Bar

A design review should not approve when:

- A critical or high severity design problem is unfixed
- Internal types leak across module boundaries
- Business logic is mixed with I/O in a way that prevents testing
- New global state is introduced without clear ownership
- Circular dependencies are introduced
- Unbounded growth is introduced in a critical path

Medium and low findings should be noted but do not block approval.
