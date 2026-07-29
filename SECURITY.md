# Security Policy

## Supported Versions

We currently support the latest stable release of Dastra. Due to the offline nature of the application, security patches are delivered via standard application updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

Dastra is a privacy-first, 100% offline application. It does not communicate with external servers or cloud services. Therefore, security vulnerabilities typically relate to:

- Local privilege escalation
- Unsafe file parsing (e.g., PDF or Image exploits)
- Local data exposure in the SQLite workspace database
- Cryptographic weaknesses in the Password Generator

If you discover a vulnerability, **do not open a public issue.**

Please report any security vulnerabilities by emailing the core maintainer directly (Pratik Das). We take all reports seriously and will work with you to understand the issue, provide a patch, and disclose the vulnerability responsibly once it has been resolved.

Please include:
1. A clear description of the vulnerability.
2. Steps to reproduce the issue.
3. Your operating system and environment.
4. Any potential impact on users.
