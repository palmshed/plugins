# performance-review

Identify performance regressions, slow code paths, and resource waste in your changes.

## When to use

Run this skill when auditing a changeset for speed or doing a hardening pass. Use it before merging code that touches hot paths, handles high throughput, manages large data, or interacts with databases and external services.

## What it does

Reviews the current branch's changes for:

- **Algorithmic complexity**: quadratic loops, unnecessary sorting, repeated computation
- **Memory and allocations**: heap pressure in hot paths, cloning large structures, unbounded growth
- **I/O and network**: synchronous blocking in async code, missing batching, redundant reads
- **Database**: N+1 queries, missing indexes, SELECT *, long-held transactions
- **Concurrency**: lock contention, blocking the event loop, missing parallelization
- **Caching**: missing cache, over-caching, cache key issues
- **Hot path hygiene**: logging in tight loops, unnecessary formatting, type conversions

## Inputs

The diff of the current branch against its base.

## Expected outputs

Severity-rated findings (critical / high / medium / low / informational), each with:

- Exact location (file and line)
- Concrete cost estimate (e.g. "O(n²) over unbounded input")
- Context for when it matters
- Specific fix

## Limitations

- Does not perform actual profiling or benchmarking
- Cannot determine real-world throughput without measurement
- Focuses on code patterns, not runtime behavior
- Theoretical issues in cold paths are flagged at lower severity

## Install

```sh
mull plugin install performance-review
```
