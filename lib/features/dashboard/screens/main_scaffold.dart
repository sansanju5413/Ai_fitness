import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:ui'; // For BackdropFilter

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for floating nav bar
      body: child,
      bottomNavigationBar: const _FloatingPillNavBar(),
    );
  }
}

class _FloatingPillNavBar extends StatelessWidget {
  const _FloatingPillNavBar();

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), // Float from bottom
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavBarItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: location == '/home' || location == '/',
                  onTap: () => context.go('/home'),
                ),
                _NavBarItem(
                  icon: Icons.fitness_center_rounded,
                  label: 'Workouts',
                  isSelected: location.startsWith('/workouts'),
                  onTap: () => context.go('/workouts'),
                ),
                _NavBarItem(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Diet',
                  isSelected: location.startsWith('/diet'),
                  onTap: () => context.go('/diet'),
                ),
                _NavBarItem(
                  icon: Icons.analytics_rounded,
                  label: 'Progress',
                  isSelected: location.startsWith('/progress'),
                  onTap: () => context.go('/progress'),
                ),
                _NavBarItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: location.startsWith('/settings') || location.startsWith('/profile'),
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : AppColors.textSecondary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
