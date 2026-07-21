# api-review

Review API design for consistency, ergonomics, backward compatibility, and documentation quality.

## When to use

Run this skill when designing a new API or reviewing changes to an existing one. Use it before merging endpoints, request/response shapes, or authentication changes. Particularly valuable for public APIs where mistakes are expensive to fix.

## What it does

Reviews the current branch's changes for:

- **Consistency**: naming conventions, parameter ordering, return types, error formats
- **Ergonomics**: unnecessary required parameters, overly nested structures, boolean traps
- **Backward compatibility**: renamed fields, removed endpoints, changed response shapes
- **Error design**: wrong status codes, generic messages, missing error codes, leaking internals
- **Documentation**: undocumented parameters, missing examples, missing edge case docs
- **Security**: missing validation, IDOR risks, sensitive data in logs, missing rate limiting
- **Versioning**: no versioning strategy, missing deprecation headers, no sunset policy
- **Pagination**: missing pagination, inconsistent styles, missing sort/filter options

## Inputs

The diff of the current branch against its base.

## Expected outputs

Severity-rated findings (critical / high / medium / low / informational), each with:

- Exact location (endpoint, file, line)
- The design problem and who it affects
- Specific fix or migration path

## Limitations

- Does not test API behavior at runtime
- Cannot assess whether the API meets business requirements
- Focuses on design quality, not performance
- Does not validate OpenAPI/AsyncAPI specs automatically

## Install

```sh
mull plugin install api-review
```
