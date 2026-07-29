# Design System

Dastra utilizes a custom implementation of Material 3 design principles tailored specifically for productivity and offline performance. 

## Philosophy

1. **Information Density**: As a productivity application, spacing must be deliberate. Avoid overly sparse designs that require excessive scrolling.
2. **Visual Hierarchy**: Use typography and color (e.g., `accentBlue` for primary actions, `success` for completion) to guide the user's eye.
3. **Glassmorphism & Depth**: Dastra employs subtle transparency, blurs, and layered shadows (`AppShadows.cardShadow`) to establish elevation rather than relying purely on solid colors.

## Core Components

All UI components in Dastra are centralized in `lib/core/widgets/`.

- `DastraButton`: The standard interactive button (solid, outline, text).
- `DastraCard`: The standard container with consistent borders and shadows.
- `DastraTextField`: Standardized input fields.
- `AdaptiveScaffold`: The top-level layout wrapper that responds to screen sizes.

## Avoiding Ad-Hoc Styling

Never hardcode `Colors.red` or `TextStyle(...)` directly in UI files. Always read from the `BuildContext` extensions:

```dart
// Correct
color: context.colors.primary,
style: context.typography.bodyMedium,

// Incorrect
color: Colors.blue,
style: TextStyle(fontSize: 14),
```
