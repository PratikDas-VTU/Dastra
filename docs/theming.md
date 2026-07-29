# Theming

Dastra supports Dynamic Light and Dark modes. The theming system is implemented using Flutter's `ThemeExtension`, ensuring strong type safety and centralized color definitions.

## Theme Architecture

```mermaid
graph TD
    A[AppTheme] -->|Generates| B[ThemeData Light]
    A -->|Generates| C[ThemeData Dark]
    
    B --> D[DastraColors Light]
    B --> E[DastraTypography]
    
    C --> F[DastraColors Dark]
    C --> E[DastraTypography]
    
    D -.->|Injected via Context| G[UI Components]
    F -.->|Injected via Context| G
    E -.->|Injected via Context| G
```

## How to Add New Colors

1. Open `lib/core/theme/dastra_colors.dart`.
2. Add the new color property to the `DastraColors` class.
3. Update the `lerp` method (required for smooth theme transitions).
4. Update `AppTheme.lightColors` and `AppTheme.darkColors` in `app_theme.dart`.

## Best Practices

- Always test your UI in both Light and Dark mode.
- Avoid low-contrast text. Use `textPrimary`, `textSecondary`, and `textTertiary` appropriately.
- For gradients, use the predefined gradients (e.g., `splashGradient`, `documentGradient`) defined in `DastraColors`.
