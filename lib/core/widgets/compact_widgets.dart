import 'package:flutter/material.dart';
import 'package:smc/core/theme/universal_theme.dart';

/// A space-efficient card with optional title and icon.
class CompactCard extends StatelessWidget {
  final String? title;
  final IconData? titleIcon;
  final List<Widget> children;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const CompactCard({
    super.key,
    this.title,
    this.titleIcon,
    required this.children,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Padding(
      padding: padding ??
          EdgeInsets.all(
            UniversalTheme.getSpacing(context, SpacingSize.md),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (titleIcon != null) ...[
                  Icon(
                    titleIcon,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(
                      width:
                          UniversalTheme.getSpacing(context, SpacingSize.sm)),
                ],
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontSize: UniversalTheme.getFontSize(
                          context, FontSize.subtitle),
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(
                height: UniversalTheme.getSpacing(context, SpacingSize.sm)),
          ],
          ...children,
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: content,
    );
  }
}

/// A compact info row that saves vertical space.
class CompactInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const CompactInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: UniversalTheme.getSpacing(context, SpacingSize.xs),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            SizedBox(width: UniversalTheme.getSpacing(context, SpacingSize.sm)),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: UniversalTheme.getFontSize(context, FontSize.caption),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: UniversalTheme.getFontSize(context, FontSize.body),
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// An adaptive grid that adjusts columns based on screen width.
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int crossAxisCount;
        double effectiveAspectRatio = childAspectRatio;

        if (width < 350) {
          crossAxisCount = 1;
          effectiveAspectRatio = childAspectRatio * 1.5; // Taller for single col
        } else if (width < 600) {
          crossAxisCount = 2;
        } else if (width < 900) {
          crossAxisCount = 3;
        } else if (width < 1200) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 6;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          childAspectRatio: effectiveAspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: mainAxisSpacing ??
              UniversalTheme.getSpacing(context, SpacingSize.sm),
          crossAxisSpacing: crossAxisSpacing ??
              UniversalTheme.getSpacing(context, SpacingSize.sm),
          children: children,
        );
      },
    );
  }
}


