# system-design

Architectural review covering module boundaries, coupling, scalability, and design clarity.

## When to use

Run this skill when auditing structural changes or doing a design review. Use it before merging code that reorganizes modules, introduces new abstractions, changes data flow, or adds cross-cutting concerns.

## What it does

Reviews the current branch's changes for:

- **Module boundaries**: code in the wrong layer, leaking internal types, circular dependencies
- **Coupling**: tight coupling between unrelated features, dependency direction violations, shared mutable state
- **Abstractions**: leaky abstractions, premature generalization, missing abstraction, over-engineering
- **Error handling**: lost context across boundaries, inconsistent error types, panics in library code
- **Data flow**: unclear ownership, duplicate representations, scattered configuration
- **Scalability**: single points of failure, unbounded growth, synchronous bottlenecks
- **Consistency**: similar operations handled differently, naming inconsistencies, mixed conventions
- **Testability**: untestable code, dependencies that cannot be replaced, business logic tangled with I/O

## Inputs

The diff of the current branch against its base.

## Expected outputs

Severity-rated findings (critical / high / medium / low / informational), each with:

- Exact location (file, module, or boundary)
- The design problem and its concrete impact
- Alternative approach

## Limitations

- Does not enforce a specific architecture style
- Cannot assess runtime performance or resource usage
- Focuses on structural quality, not feature correctness
- Theoretical scalability issues are flagged at lower severity

## Install

```sh
mull plugin install system-design
```
