# Runtime Capabilities Flow

Dastra utilizes different runtimes depending on the target platform. Because Dastra is 100% offline, it relies entirely on local compute.

## Cross-Platform Runtime Architecture

```mermaid
graph TD
    A[Flutter Engine] --> B{Platform?}
    
    B -->|Windows| C[Desktop Runtime]
    B -->|Android/iOS| D[Mobile Runtime]
    B -->|macOS/Linux| E[Unix Runtime]
    
    C --> F[Pure Dart / C++ FFI]
    C --> G[Python Executables]
    C --> H[COM Automation]
    
    D --> I[Pure Dart / Java JNI]
    D --> J[Method Channels]
```

## How It Works
When a tool executes (e.g., PDF to Word), the Controller checks `Platform.isWindows`. If true, it invokes the Desktop Engine (which uses Python `pdf2docx`). If on Android, it might use a native Method Channel or fall back to a Dart implementation.

This ensures maximum performance on desktops while maintaining compatibility on mobile devices.
