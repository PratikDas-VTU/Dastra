# Tool Development Guide

This guide outlines how to build a new tool inside Dastra.

## 1. Directory Structure

Place your tool in the corresponding module directory:
`lib/modules/[category]/[tool_name]/`

Example: `lib/modules/document/pdf_to_word/`

Inside this folder, you should have:
- `pdf_to_word_screen.dart` (UI)
- `controller/pdf_to_word_controller.dart` (State)
- `widgets/` (Tool-specific widgets)
- `engine/` (The actual conversion logic / bindings)

## 2. UI Guidelines

Every tool must use `AdaptiveScaffold` to ensure it works on both desktop and mobile.

- **Desktop Layout**: Typically uses a split view (Options on the left, Dropzone/Preview on the right).
- **Mobile Layout**: Typically uses a single column scrollable view.

Reference the `tool-ui-guidelines.md` for exact specifications.

## 3. Controller Guidelines

- Maintain state (selected files, output paths, processing status).
- Handle file picking (using `file_picker`).
- Handle Desktop Drop (using `desktop_drop`).
- Execute the engine logic.
- Register the conversion in the `WorkspaceRepository` upon success.

## 4. Engine Guidelines

If the tool requires native bindings (e.g., Python on Windows):
- Ensure it gracefully fails if the runtime is missing.
- Write fallback logic if possible (e.g., using a pure Dart library as a fallback).
- Refer to `desktop-runtime.md` for interacting with Python/COM.
