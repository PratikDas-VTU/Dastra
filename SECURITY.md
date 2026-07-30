# Security Policy

## Supported Versions
Dastra is committed to providing a secure and offline experience.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Architecture Security
Dastra operates as an offline-first application. It does not phone home, use telemetry, or upload your documents to the cloud. All PDF parsing, image manipulation, OCR, and workspace storage happens locally using embedded DLLs and SQLite.

### Data Storage Policy
To ensure complete isolation between environments:
- **Community Edition** stores its data securely in `%LOCALAPPDATA%\Dastra`
- **Developer Edition** stores its data securely in `%LOCALAPPDATA%\DastraDeveloper`

By keeping these namespaces separate, we ensure that experimental Developer data can never inadvertently pollute or corrupt your stable production workspace.

## Reporting a Vulnerability
If you discover a vulnerability or a flaw in how Dastra handles local documents, please DO NOT report it via public GitHub issues. Instead, please report it directly to the repository maintainer privately. 

We will acknowledge your report within 48 hours.
