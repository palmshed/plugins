# security-review

Security-focused code review for injection, authentication, data exposure, and supply-chain risks.

## When to use

Run this skill when auditing a changeset for vulnerabilities or doing a hardening pass. Use it before merging code that touches authentication, handles user input, manages secrets, interacts with databases, or introduces new dependencies.

## What it does

Reviews the current branch's changes for:

- **Injection**: SQL, command, template, LDAP, log injection
- **Authentication and authorization**: broken access control, missing checks, privilege escalation
- **Data exposure**: sensitive data in logs, verbose API responses, PII leakage
- **Cryptography**: weak algorithms, hardcoded keys, improper validation
- **Supply chain**: new dependencies, lock file changes, build pipeline integrity
- **Input validation**: path traversal, SSRF, open redirects, file uploads
- **Error handling**: stack trace leaks, missing rate limiting, race conditions

## Inputs

The diff of the current branch against its base.

## Expected outputs

Severity-rated findings (critical / high / medium / low / informational), each with:

- Exact location (file and line)
- Attack path explanation
- Impact description
- Specific fix

## Limitations

- Does not perform dynamic testing or penetration testing
- Cannot assess runtime behavior or infrastructure configuration
- Focuses on code changes, not the full codebase
- Supply chain analysis is limited to what is visible in the diff

## Install

```sh
mull plugin install security-review
```
