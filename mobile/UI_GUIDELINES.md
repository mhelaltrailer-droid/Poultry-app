# UI guidelines — DAY TO DAY (Flutter)

This document describes how responsive layout, spacing, and overflow prevention are handled in `mobile/lib/`. It complements the Cursor rule `.cursor/rules/flutter-ui-responsive.mdc`.

## Breakpoints (width-based)

Defined in `lib/core/responsive/app_breakpoints.dart`:

| Tier     | Width        | Typical use                          |
|----------|--------------|--------------------------------------|
| Mobile   | `< 600`      | Bottom navigation, tighter padding   |
| Tablet   | `600 – 1023` | Side rail from 600px (`railCompact`) |
| Desktop  | `≥ 1024`     | Wider content, more grid columns    |

Additional shell constants:

- **`railCompact` (600)** — Show `NavigationRail` instead of bottom bar (customer `MainShell`, admin `AdminShell`).
- **`railExtended` (900)** — Use extended rail (labels beside icons). With Material 3.41+, when `extended: true`, set `labelType` to `null` or `NavigationRailLabelType.none` only.

Access in code:

```dart
import 'package:daytoday_app/core/responsive/responsive.dart';

// Extension on BuildContext
context.breakpointTier;   // mobile | tablet | desktop
context.screenWidth;
context.isTabletOrWider;
```

## Spacing

Use **`AppSpacing`** (`lib/core/responsive/app_spacing.dart`), not raw numbers, for padding and gaps:

| Token   | Value |
|---------|-------|
| `xxs`   | 4     |
| `xs`    | 8     |
| `sm`    | 12    |
| `md`    | 16    |
| `lg`    | 20    |
| `xl`    | 24    |
| `xxl`   | 32    |
| `xxxl`  | 40    |

Horizontal page inset:

```dart
AppSpacing.pagePaddingX(MediaQuery.sizeOf(context).width)
```

## Typography scaling

For headlines that should scale slightly with viewport width:

```dart
AppTextScale.fontSize(context, 26)
```

Respects a reference width (default 390) with clamped scale factors. System text scaling (`MediaQuery.textScaler`) should still be honored where accessibility matters (e.g. `textScaler` on `Text`).

## Layout — avoid overflow

1. **Scroll** — Any screen that can grow beyond the viewport should use `ListView`, `CustomScrollView`, or `SingleChildScrollView` (often with `AlwaysScrollableScrollPhysics` when using `RefreshIndicator`).
2. **Flex** — In `Row` / `Column`, give growing children `Expanded` or `Flexible`; use `Wrap` for chips or action groups that may wrap.
3. **List tiles** — Avoid a wide `trailing` `Row` (e.g. multiple `IconButton`s). Prefer `PopupMenuButton`, `OverflowBar`, or a custom layout with `Expanded` and `TextOverflow.ellipsis`.
4. **Dialogs / sheets** — Do not hardcode a large dialog width. Use:

   ```dart
   dialogContentMaxWidth(context)  // responsive_layout.dart
   ```

## Reusable building blocks

| Widget / API | File | Purpose |
|--------------|------|---------|
| `ResponsiveProductSliverGrid` | `lib/widgets/responsive_sliver_grid.dart` | Product grid with dynamic column count |
| `productGridCrossAxisCount`, `productGridAspectRatio` | `lib/core/responsive/responsive_layout.dart` | Same logic without the sliver wrapper |
| `ResponsiveRow` | `lib/widgets/responsive_row.dart` | Row above breakpoint, column below |
| `AppScrollablePage` | `lib/core/responsive/responsive_layout.dart` | Scroll + optional max content width |
| `AppMaxWidthBody` | `lib/core/responsive/responsive_layout.dart` | Centered column with max width |

Barrel import (optional):

```dart
import 'package:daytoday_app/core/responsive/responsive.dart';
```

## Theme

`lib/core/app_theme.dart` uses **`AppSpacing`** for shared component padding (e.g. filled buttons). Brand colors (`gold`, `cream`, `black`) stay defined there.

## Checklist for new screens

- [ ] Page padding via `AppSpacing.pagePaddingX` or `AppSpacing` tokens.
- [ ] No unbounded vertical lists inside non-scroll parents.
- [ ] Long labels use `maxLines` + `overflow: TextOverflow.ellipsis` where appropriate.
- [ ] Dialogs constrained with `dialogContentMaxWidth` (or equivalent).
- [ ] `NavigationRail`: if `extended: true`, `labelType` is `null` or `none`.

## Related files

- Cursor agent rule: `../.cursor/rules/flutter-ui-responsive.mdc` (repo root)
- Responsive sources: `lib/core/responsive/`
