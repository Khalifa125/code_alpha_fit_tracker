// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class FitTrackShell extends ConsumerStatefulWidget {
  final Widget? child;
  
  const FitTrackShell({super.key, this.child});

  @override
  ConsumerState<FitTrackShell> createState() => _FitTrackShellState();
}

class _FitTrackShellState extends ConsumerState<FitTrackShell> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', path: '/home'),
    _NavItem(icon: Icons.fitness_center_rounded, label: 'Workout', path: '/workout'),
    _NavItem(icon: Icons.directions_run_rounded, label: 'Activity', path: '/activity'),
    _NavItem(icon: Icons.restaurant_rounded, label: 'Nutrition', path: '/nutrition'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
  ];

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      context.go(_navItems[index].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.path;
    final index = _navItems.indexWhere((item) => item.path == currentPath);
    if (index != -1 && index != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = index);
      });
    }

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      body: widget.child,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: (isDark ? FitColors.surfaceDark : Colors.white).withValues(alpha: 0.7),
              border: Border(
                top: BorderSide(color: (isDark ? FitColors.borderDark : FitColors.borderLight).withValues(alpha: 0.3)),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _navItems.asMap().entries.map((entry) {
                    final item = entry.value;
                    final isSelected = entry.key == _currentIndex;
                    return _NavBarItem(
                      icon: item.icon,
                      label: item.label,
                      isSelected: isSelected,
                      onTap: () => _onTabTapped(entry.key),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;

  _NavItem({required this.icon, required this.label, required this.path});
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? FitColors.neonGreen.withValues(alpha: 0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? FitColors.neonGreen : unselectedColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? FitColors.neonGreen : unselectedColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
