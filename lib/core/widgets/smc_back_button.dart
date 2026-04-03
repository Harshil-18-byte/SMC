import 'package:flutter/material.dart';

/// A premium, consistent back button widget used across all screens.
/// Provides a well-styled, visible back arrow with a subtle background
/// and hover/press animation for a polished UX.
class SMCBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;

  const SMCBackButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIconColor = iconColor ??
        (isDark ? Colors.white : Theme.of(context).colorScheme.onSurface);
    final defaultBgColor = backgroundColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06));

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(12),
          splashColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          highlightColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: defaultBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: defaultIconColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// A pre-configured AppBar with the SMCBackButton built in.
/// Use this as a drop-in replacement for AppBar when you need a back button.
class SMCAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? bottom;
  final double? elevation;

  const SMCAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.bottom,
    this.elevation,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(bottom != null ? kToolbarHeight + 48 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      leading: (showBackButton && canPop)
          ? SMCBackButton(onPressed: onBackPressed)
          : null,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: actions,
      elevation: elevation,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: bottom!,
            )
          : null,
    );
  }
}
