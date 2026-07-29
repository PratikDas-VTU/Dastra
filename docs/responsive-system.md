# Responsive System

Dastra is designed to run natively on Desktop (Windows, macOS, Linux) and Mobile (Android, iOS). Instead of writing separate UI codebases, Dastra uses an adaptive layout system that scales gracefully.

## The Adaptive Builder

The core of Dastra's responsiveness is the `AdaptiveBuilder` component (`lib/core/widgets/adaptive_builder.dart`).

It defines the following breakpoints:
- `compact`: < 600px (Mobile Phones)
- `largePhone`: 600px - 839px (Large Phones / Small Tablets)
- `tablet`: 840px - 1199px (Tablets)
- `smallDesktop`: 1200px - 1599px (Laptops)
- `desktop`: 1600px - 1919px (Standard Monitors)
- `ultrawide`: > 1920px (Ultrawide Monitors)

## Usage Guidelines

1. **Avoid Hardcoded Widths**: Never use `width: 800`. Use percentages, `Flexible`, or `constraints` (`BoxConstraints(maxWidth: ...)`).
2. **Use Wrap over Row**: For lists of chips or buttons, prefer `Wrap` so items automatically flow to the next line on narrow screens.
3. **Adaptive Extensions**: Use `context.spacing.md`, `context.layout.isMobile`, etc., rather than querying `MediaQuery` directly.

```dart
final isMobile = Adaptive.of(context) == ScreenSize.compact;

return isMobile ? _buildMobileLayout() : _buildDesktopLayout();
```
