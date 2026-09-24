import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/features/auth/auth_controller.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  void _onNavigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/cases');
        break;
      case 2:
        context.go('/knowledge');
        break;
      case 3:
        context.go('/reports');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < AppBreakpoints.mobile;
    final isTablet = width >= AppBreakpoints.mobile && width < AppBreakpoints.tablet;
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    // --- MOBILE SHELL ---
    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          titleSpacing: AppSpacing.lg,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.hairlineBorder),
                ),
                child: const Icon(Icons.support_agent_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'NexAssist',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 19, color: AppColors.textSecondary),
              tooltip: 'Sign out',
              onPressed: () => auth.logout(),
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(color: AppColors.hairlineBorder, height: 1),
          ),
        ),
        body: child,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.hairlineBorder, width: 1)),
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => _onNavigate(context, index),
              backgroundColor: AppColors.surface,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedLabelStyle: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w400),
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 20),
                  activeIcon: Icon(Icons.home_rounded, size: 20),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inbox_outlined, size: 20),
                  activeIcon: Icon(Icons.inbox_rounded, size: 20),
                  label: 'Cases',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_outlined, size: 20),
                  activeIcon: Icon(Icons.menu_book_rounded, size: 20),
                  label: 'Knowledge',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.insights_outlined, size: 20),
                  activeIcon: Icon(Icons.insights_rounded, size: 20),
                  label: 'Insights',
                ),
              ],
            ),
          ),
        ),
      );
    }

    // --- TABLET SHELL (Adaptive Navigation Rail) ---
    if (isTablet) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            Container(
              width: 72,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(right: BorderSide(color: AppColors.hairlineBorder, width: 1)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.hairlineBorder),
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _RailItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => _onNavigate(context, 0),
                  ),
                  _RailItem(
                    icon: Icons.inbox_outlined,
                    activeIcon: Icons.inbox_rounded,
                    label: 'Cases',
                    isSelected: currentIndex == 1,
                    onTap: () => _onNavigate(context, 1),
                  ),
                  _RailItem(
                    icon: Icons.menu_book_outlined,
                    activeIcon: Icons.menu_book_rounded,
                    label: 'Knowledge',
                    isSelected: currentIndex == 2,
                    onTap: () => _onNavigate(context, 2),
                  ),
                  _RailItem(
                    icon: Icons.insights_outlined,
                    activeIcon: Icons.insights_rounded,
                    label: 'Insights',
                    isSelected: currentIndex == 3,
                    onTap: () => _onNavigate(context, 3),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.textSecondary),
                    tooltip: 'Sign out',
                    onPressed: () => auth.logout(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    // --- DESKTOP & WEB SHELL (Spacious Sidebar) ---
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Fluid Sidebar
          Container(
            width: 250,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.hairlineBorder, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.hairlineBorder),
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NexAssist',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Operations Workspace',
                            style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.hairlineBorder, height: 1),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
                    children: [
                      _SidebarItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        title: 'Home / Queue',
                        isSelected: currentIndex == 0,
                        onTap: () => _onNavigate(context, 0),
                      ),
                      _SidebarItem(
                        icon: Icons.inbox_outlined,
                        activeIcon: Icons.inbox_rounded,
                        title: 'Case Ledger',
                        isSelected: currentIndex == 1,
                        onTap: () => _onNavigate(context, 1),
                      ),
                      _SidebarItem(
                        icon: Icons.menu_book_outlined,
                        activeIcon: Icons.menu_book_rounded,
                        title: 'Knowledge Base',
                        isSelected: currentIndex == 2,
                        onTap: () => _onNavigate(context, 2),
                      ),
                      _SidebarItem(
                        icon: Icons.insights_outlined,
                        activeIcon: Icons.insights_rounded,
                        title: 'Operational Insights',
                        isSelected: currentIndex == 3,
                        onTap: () => _onNavigate(context, 3),
                      ),
                    ],
                  ),
                ),

                // User Profile & Sign Out Footer
                const Divider(color: AppColors.hairlineBorder, height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.hairlineBorder),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (user?.fullName ?? user?.email ?? 'U')[0].toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? user?.email ?? 'User',
                              style: GoogleFonts.publicSans(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user?.role ?? '',
                              style: GoogleFonts.publicSans(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textSecondary),
                        tooltip: 'Sign out',
                        onPressed: () => auth.logout(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content View
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryTint : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: isSelected ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryTint : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: isSelected ? Border.all(color: AppColors.primary.withValues(alpha: 0.25)) : null,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 19,
        ),
        title: Text(
          title,
          style: GoogleFonts.publicSans(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        onTap: onTap,
      ),
    );
  }
}
