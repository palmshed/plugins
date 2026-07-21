---
name: security-review
description: Run a security-focused code review covering injection, authentication, data exposure, cryptography, and supply-chain risks. Use when auditing a changeset for vulnerabilities or doing a hardening pass.
disable-model-invocation: true
---

# Security Code Review

Use this skill for a thorough security review of the current branch's changes. The goal is to catch vulnerabilities before they reach production ~ not to produce a compliance checkbox, but to find real attack surface.

## Core Prompt

> Perform a security-focused audit of the current branch's changes.
> Identify concrete vulnerabilities, not theoretical risk categories.
> For each finding, explain the attack path, the impact, and the fix.
> Be precise about severity: distinguish exploitable issues from hardening opportunities.

## Review Categories

### 1. Injection

- SQL injection: parameterized queries, string interpolation in queries, ORM misuse
- Command injection: unsanitized input passed to shell execution, `exec`, `spawn`, `system`
- Template injection: user input rendered in templates without escaping
- LDAP/XPath/NoSQL injection: query construction from untrusted data
- Log injection: user-controlled input written to logs without sanitization

### 2. Authentication and Authorization

- Missing authentication checks on endpoints or operations
- Broken access control: can a user access resources they should not?
- Session management: token expiry, rotation, fixation
- Credential handling: hardcoded secrets, insecure storage, logging of credentials
- Privilege escalation: vertical (user → admin) and horizontal (user A → user B)

### 3. Data Exposure

- Sensitive data in logs, error messages, or debug output
- Overly verbose API responses exposing internal state
- PII leakage in analytics, telemetry, or breadcrumbs
- Missing encryption at rest or in transit
- Insecure deserialization: untrusted data deserialized without validation

### 4. Cryptography

- Weak algorithms (MD5, SHA1 for security, DES, RC4)
- Hardcoded keys, IVs, or salts
- Improper key management: keys in source code, config files, or environment without rotation
- Random number generation: `Math.random()` or `rand()` for security-sensitive values
- Certificate validation: skipping TLS verification, accepting expired certs

### 5. Supply Chain

- New dependencies: are they reputable, maintained, and audited?
- Dependency confusion: internal package names matching public ones
- Lock file changes: were they reviewed or just regenerated?
- Build pipeline: can the build be tampered with?
- Post-install scripts in dependencies

### 6. Input Validation

- Missing validation on file uploads: type, size, content
- Path traversal: user-controlled file paths without sanitization
- SSRF: user-controlled URLs used for server-side requests
- Open redirects: user-controlled redirect targets
- Integer overflow, buffer issues in unsafe code

### 7. Error Handling

- Errors that leak stack traces, database schemas, or internal paths
- Catch-all handlers that suppress security-relevant failures
- Missing rate limiting on authentication or sensitive operations
- Race conditions in security-critical flows (TOCTOU)

## Severity Levels

**Critical** ~ Directly exploitable, leads to data breach, RCE, or auth bypass.
**High** ~ Exploitable with moderate effort, significant impact.
**Medium** ~ Requires specific conditions or chained with other issues.
**Low** ~ Hardening opportunity, defense-in-depth, defense-in-depth improvement.
**Informational** ~ Best practice suggestion, no direct security impact.

## What to Flag Aggressively

- Secrets in source code, config, or environment variables committed to the repo
- SQL or command construction from string interpolation
- User input reaching dangerous sinks (exec, eval, shell, render) without sanitization
- Authentication or authorization checks removed or bypassed
- TLS verification disabled or certificate validation skipped
- New dependencies without clear provenance
- Sensitive data in error responses or log output
- Race conditions in file or state operations
- Missing CSRF protection on state-changing endpoints
- Insecure cookie flags (missing HttpOnly, Secure, SameSite)

## What Not to Over-Index On

- Theoretical attack vectors with no realistic exploit path
- Missing security headers on internal-only services
- Cosmetic issues in security-related code
- Dependencies with known CVEs that are not reachable in your code path
- Overly strict policies that block legitimate use cases

## Finding Format

For each finding, provide:

1. **Location**: file and line or function
2. **Category**: injection, auth, data exposure, etc.
3. **Severity**: critical / high / medium / low / informational
4. **Attack path**: how an attacker reaches the vulnerable code
5. **Impact**: what the attacker achieves
6. **Fix**: specific remediation, not just "validate input"

## Review Tone

Be direct and specific. Name the vulnerability class and the exact code path.
Do not hedge with "might be vulnerable" when the issue is clear.
Do not soften critical findings into mild suggestions.
If the code has a real vulnerability, say so.

Good phrases:

- `this passes user input directly into a shell command ~ command injection`
- `the token is logged at debug level ~ credential exposure`
- `this endpoint has no auth check ~ any unauthenticated user can reach it`
- `TLS verification is disabled ~ MitM possible`
- `this dependency was published 2 days ago with 3 downloads ~ supply chain risk`
- `the file path is constructed from user input without sanitization ~ path traversal`

## Approval Bar

A security review should not approve when:

- A critical or high severity vulnerability is unfixed
- Secrets are committed to the repository
- Authentication or authorization is broken
- User input reaches a dangerous sink without sanitization
- TLS or certificate validation is disabled
- A new dependency has no clear provenance

Medium and low findings should be noted but do not block approval unless the maintainer decides they should.
