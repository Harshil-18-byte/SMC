import 'package:flutter/material.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/widgets/universal_drawer.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget compactBody; // Phone
  final Widget? mediumBody; // Small tablet
  final Widget? expandedBody; // Large tablet
  final Widget? largeBody; // Desktop

  const AdaptiveLayout({
    super.key,
    required this.compactBody,
    this.mediumBody,
    this.expandedBody,
    this.largeBody,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Automatically select appropriate layout
        if (width >= 1200 && largeBody != null) {
          return _DesktopLayout(child: largeBody!);
        } else if (width >= 840 && expandedBody != null) {
          return _TabletLandscapeLayout(child: expandedBody!);
        } else if (width >= 600 && mediumBody != null) {
          return _TabletPortraitLayout(child: mediumBody!);
        } else {
          return _PhoneLayout(child: compactBody);
        }
      },
    );
  }
}

// Phone Layout (Single column)
class _PhoneLayout extends StatelessWidget {
  final Widget child;

  const _PhoneLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

// Tablet Portrait (Two column, side nav)
class _TabletPortraitLayout extends StatelessWidget {
  final Widget child;

  const _TabletPortraitLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: false,
            destinations: _getNavDestinations(context),
            selectedIndex: 0,
            onDestinationSelected: (index) {
              // Handle navigation
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// Tablet Landscape (Three column with persistent drawer)
class _TabletLandscapeLayout extends StatelessWidget {
  final Widget child;

  const _TabletLandscapeLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Permanent navigation drawer
          const SizedBox(
            width: 280,
            child: UniversalDrawer(isPermanent: true),
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // Main content
          Expanded(
            flex: 2,
            child: child,
          ),

          // Optional side panel for details
          if (_shouldShowSidePanel(context)) ...[
            const VerticalDivider(thickness: 1, width: 1),
            const SizedBox(
              width: 320,
              child: _DetailPanel(),
            ),
          ],
        ],
      ),
    );
  }
}

// Desktop Layout (Multi-column with floating panels)
class _DesktopLayout extends StatelessWidget {
  final Widget child;

  const _DesktopLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Permanent extended navigation
          SizedBox(
            width: 240,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  _buildAppLogo(context),
                  const Expanded(child: UniversalDrawer(isPermanent: true)),
                ],
              ),
            ),
          ),

          // Main workspace
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

// Helper methods/widgets

List<NavigationRailDestination> _getNavDestinations(BuildContext context) {
  return [
    NavigationRailDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home),
      label: Text(AppLocalizations.of(context).home),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.analytics_outlined),
      selectedIcon: const Icon(Icons.analytics),
      label: Text(AppLocalizations.of(context).analytics),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.notifications_outlined),
      selectedIcon: const Icon(Icons.notifications),
      label: Text(AppLocalizations.of(context).alerts),
    ),
  ];
}

bool _shouldShowSidePanel(BuildContext context) {
  return MediaQuery.of(context).size.width > 1200;
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      child: Center(
        child: Text(
          AppLocalizations.of(context).selectDetails,
          style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}

Widget _buildAppLogo(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Text(
      'SMC',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: -2,
      ),
    ),
  );
}


