---
name: api-review
description: Review API design for consistency, ergonomics, backward compatibility, and documentation quality. Use when designing a new API or reviewing changes to an existing one.
disable-model-invocation: true
---

# API Design Review

Use this skill for a thorough review of API design. The goal is to ensure APIs are consistent, ergonomic, well-documented, and backward compatible ~ not to enforce a single style, but to catch design problems before they become permanent.

## Core Prompt

> Review the API design in the current branch's changes.
> Identify concrete design issues, not theoretical preferences.
> For each finding, explain the problem, who it affects, and the fix.
> Be practical: focus on changes that affect API consumers.

## Review Categories

### 1. Consistency

- Naming conventions: camelCase vs snake_case mixed in same API
- Parameter ordering: inconsistent argument order across similar endpoints
- Return types: some endpoints return data, others wrap in envelope
- Error formats: different error structures across endpoints
- Boolean parameters: mixed true/false, yes/no, enable/disable patterns
- Date/time formats: inconsistent ISO 8601 handling

### 2. Ergonomics

- Required parameters that should have defaults
- Overly nested request/response structures
- Requiring callers to construct IDs that the server could generate
- Missing convenience methods for common operations
- Inconsistent null handling: some fields null, others absent
- Boolean traps: parameters that are unclear without reading docs

### 3. Backward Compatibility

- Renamed fields without deprecation period
- Removed endpoints without migration path
- Changed response shapes without versioning
- Tightened validation that breaks existing clients
- Changed error codes for existing failure modes
- Removed or renamed enum values

### 4. Error Design

- HTTP status codes that do not match the error type
- Generic error messages without actionable detail
- Missing error codes for programmatic handling
- Leaking internal state in error responses
- Inconsistent error response shapes
- Missing validation errors for bad input

### 5. Documentation

- Undocumented parameters or response fields
- Missing examples for non-trivial requests
- Undocumented edge cases or limitations
- Missing rate limit documentation
- Undocumented authentication requirements
- Missing changelog entries for API changes

### 6. Security

- Missing input validation on user-controlled parameters
- Overly permissive CORS or access patterns
- Sensitive data in URL parameters or logs
- Missing rate limiting on expensive operations
- IDOR risks: predictable resource identifiers
- Missing authentication on state-changing endpoints

### 7. Versioning

- No versioning strategy for breaking changes
- Version embedded in URL vs header inconsistency
- Missing deprecation headers or timeline
- No sunset policy for old versions
- Version negotiation complexity

### 8. Pagination and Filtering

- Inconsistent pagination styles (offset vs cursor)
- Missing pagination on list endpoints
- Filtering that does not match the data model
- Missing sort options on ordered results
- No way to request specific fields (sparse fieldsets)
- Missing total count for paginated responses

## Severity Levels

**Critical** ~ Breaking change without versioning, security hole, or data loss risk.
**High** ~ Ergonomic issue that affects most consumers, missing documentation for critical paths.
**Medium** ~ Inconsistency, minor compatibility concern, missing edge case docs.
**Low** ~ Style preference, minor improvement opportunity.
**Informational** ~ Suggestion that would improve the API without urgency.

## What to Flag Aggressively

- Breaking changes shipped without versioning or deprecation
- Inconsistent response shapes across similar endpoints
- Missing error documentation for failure modes
- Sensitive data in logs or error responses
- Missing input validation on user-controlled parameters
- Undocumented parameters or response fields
- Pagination missing on list endpoints
- Generic error messages without actionable detail

## What Not to Over-Index On

- Naming preferences that are consistent within the API
- Theoretical edge cases with no realistic caller
- Style differences between internal and public APIs
- Missing features that are not yet required by consumers
- Theoretical security issues with no realistic exploit path

## Finding Format

For each finding, provide:

1. **Location**: file, endpoint, or function
2. **Category**: consistency, ergonomics, compatibility, errors, docs, security, versioning, pagination
3. **Severity**: critical / high / medium / low / informational
4. **Problem**: what is wrong with the API design
5. **Who it affects**: consumers, operators, maintainers
6. **Fix**: specific change or migration path

## Approval Bar

An API review should not approve when:

- A breaking change is shipped without versioning or deprecation
- A security issue is present in the API surface
- Error responses are undocumented and inconsistent
- List endpoints have no pagination
- Authentication is missing on state-changing endpoints

Medium and low findings should be noted but do not block approval.
