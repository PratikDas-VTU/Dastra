# Dastra Architecture

Dastra follows a strict **Screen → Controller → Service → Storage** architectural pattern. This ensures a clean separation of concerns, highly testable code, and scalable logic across different form factors (Desktop vs. Mobile).

## Core Architecture Flow

```mermaid
graph TD
    A[Screen / UI Layer] -->|Reads State & Dispatches Events| B(Controller Layer)
    B -->|Calls Business Logic| C{Service Layer}
    C -->|Reads/Writes Data| D[(Storage / Repository Layer)]
    
    classDef ui fill:#3B82F6,stroke:#1E40AF,stroke-width:2px,color:#fff;
    classDef controller fill:#8B5CF6,stroke:#5B21B6,stroke-width:2px,color:#fff;
    classDef service fill:#10B981,stroke:#047857,stroke-width:2px,color:#fff;
    classDef storage fill:#F59E0B,stroke:#B45309,stroke-width:2px,color:#fff;
    
    class A ui;
    class B controller;
    class C service;
    class D storage;
```

### 1. Screen (UI Layer)
Located in `presentation/`. This layer strictly renders UI components and is entirely stateless. It watches the controller (via `Provider`) and reacts to state changes.

### 2. Controller (State Layer)
Located in `presentation/controller/` or `controller/`. Controllers extend `ChangeNotifier`. They hold the view state, handle user input, and coordinate with the service layer. Controllers contain **no hardcoded business logic**.

### 3. Service Layer (Business Logic)
Located in `domain/` or `services/`. Services perform the actual logic (e.g., executing a PDF conversion, communicating with Python scripts via the Desktop Runtime).

### 4. Storage / Repository Layer
Located in `domain/` or `data/`. Interfaces with SQLite, SharedPreferences, or the local file system.

## Screen Navigation Flow

Dastra uses `go_router` for deep linking and predictable navigation.

```mermaid
graph LR
    Splash[/Splash Screen/] --> Dashboard
    Dashboard --> Tool[Specific Tool Screen]
    Dashboard --> Workspace[Workspace Screen]
    Dashboard --> Settings[Settings Screen]
    
    Tool --> Dashboard
    Workspace --> Tool
```

## Module Architecture

Every feature in Dastra is modularized inside the `lib/modules/` directory:

- `dashboard/`: The entry point and tool catalog.
- `workspace/`: The productivity center (history and recent files).
- `settings/`: Application preferences, theming, and about page.
- `document/`: PDF and Document processing tools.
- `image/`: Image processing tools.
- `security/`: Password generators and security tools.

This modular structure allows new tool categories to be dropped into the codebase without affecting existing architecture.
