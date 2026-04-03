import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/theme/theme_service.dart';

class ThemeSwitcher extends StatelessWidget {
  final Color? iconColor;

  const ThemeSwitcher({super.key, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return IconButton(
          icon: Icon(
            themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            themeService.toggleTheme();
          },
          tooltip: 'Toggle Theme',
        );
      },
    );
  }
}


