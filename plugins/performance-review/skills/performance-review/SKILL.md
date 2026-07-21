---
name: performance-review
description: Run a performance-focused code review for regressions, allocations, I/O waste, and algorithmic issues. Use when auditing a changeset for speed or doing a hardening pass.
disable-model-invocation: true
---

# Performance Code Review

Use this skill for a performance review of the current branch's changes. The goal is to catch regressions and waste — not to micro-optimize clean code, but to prevent shipping slow code.

## Core Prompt

> Perform a performance audit of the current branch's changes.
> Identify concrete slowdowns, not theoretical inefficiencies.
> For each finding, explain the cost, the context, and the fix.
> Distinguish real bottlenecks from cosmetic concerns.

## Review Categories

### 1. Algorithmic Complexity

- Quadratic or worse loops over unbounded input
- Nested iterations where a single pass or hash lookup would do
- Sorting where a partial sort or heap would be faster
- Repeated computation that could be cached or memoized
- String concatenation in loops instead of buffering

### 2. Memory and Allocations

- Unnecessary heap allocations in hot paths
- Collecting into a Vec when an iterator would suffice
- Cloning large structures instead of borrowing or Arc
- Leaking memory through unbounded caches or maps
- Frequent allocation/deallocation in tight loops (use arena or pre-allocation)

### 3. I/O and Network

- Synchronous I/O in async context
- Sequential network requests that could be parallelized
- Missing batching for database queries or API calls
- Unbounded reads (reading entire files when streaming is possible)
- Redundant reads or writes to the same resource
- Missing connection pooling or reuse

### 4. Database

- N+1 query patterns: looping queries instead of joins or bulk fetches
- Missing indexes for common query patterns
- Selecting columns that are not needed (SELECT *)
- Transactions held open longer than necessary
- Missing pagination on unbounded result sets
- Unbatched inserts or updates

### 5. Concurrency

- Contention on shared locks that could be partitioned
- Blocking the async runtime with CPU-bound or synchronous work
- Missing parallelization for independent tasks
- Unnecessary synchronization: Mutex where RwLock or lock-free would do
- Deadlock-prone lock ordering

### 6. Caching

- Repeated computation of identical results without memoization
- Over-caching with no eviction, leading to memory growth
- Cache keys that are too broad or too narrow
- Missing cache for expensive I/O or computation
- Cache invalidation bugs that serve stale data

### 7. Serialization and Parsing

- Deserializing entire payloads when only a subset is needed
- Using JSON where a more efficient format (bincode, protobuf) is warranted
- Parsing the same input multiple times
- Allocating large buffers for small payloads

### 8. Hot Path Hygiene

- Logging in hot paths (especially at info/debug level)
- Formatting strings that are never used
- Unnecessary clones or copies in tight loops
- Type conversions or trait object dispatch where monomorphization would be cheaper
- Branch misprediction patterns (rare branches in hot loops)

## Severity Levels

**Critical** — Measurable regression on a hot path, blocks deployment.
**High** — Noticeable slowdown under realistic load.
**Medium** — Inefficiency that matters at scale but not today.
**Low** — Hardening opportunity, not currently impactful.
**Informational** — Style preference or minor improvement.

## What to Flag Aggressively

- Synchronous I/O in async code
- N+1 query patterns
- Unbounded loops over user-controlled input
- Quadratic algorithms on growing data
- Missing pagination
- Large allocations in request handlers
- Blocking the event loop with CPU work
- Redundant network or disk I/O
- Unnecessary cloning of large structures

## What Not to Over-Index On

- Micro-optimizations in cold paths
- Premature optimization before measuring
- Performance of test code
- Stylistic preferences disguised as perf issues
- Minor allocations that the allocator handles efficiently
- Theoretical scalability problems with no realistic data volume

## Finding Format

For each finding, provide:

1. **Location**: file and line or function
2. **Category**: algorithm, allocation, I/O, database, concurrency, caching
3. **Severity**: critical / high / medium / low / informational
4. **Cost**: concrete estimate (e.g. "O(n²) over unbounded user input", "synchronous disk read per request")
5. **Context**: when this matters (under load, at scale, always)
6. **Fix**: specific change, not just "optimize this"

## Review Tone

Be direct and specific. Quantify the cost when possible.
Do not hedge with "might be slow" when the issue is clear.
Do not flag theoretical issues in code that runs once at startup.

Good phrases:

- `this loops O(n²) over unbounded input — quadratic blowup`
- `this clones the entire config per request — allocation pressure`
- `this does a synchronous disk read in the request handler — blocks the runtime`
- `this issues one query per iteration — N+1 pattern`
- `this reads the entire file into memory — streaming would avoid the allocation`
- `this logs at info level on every request — hot path noise`
- `this holds a mutex across an await point — can block the runtime`

## Approval Bar

A performance review should not approve when:

- A critical or high severity regression is unfixed
- A synchronous blocking call is in an async hot path
- An unbounded loop runs over user-controlled input
- An N+1 query pattern is introduced in a request path
- Memory usage grows without bound

Medium and low findings should be noted but do not block approval.
