import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/features/auth/auth_controller.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/widgets/liquid_aurora_background.dart';
import 'package:it_helpdesk_client/shared/widgets/liquid_glass_panel.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- MOBILE SHELL ---
    if (isMobile) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.background,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.glassSurfaceDark : AppColors.glassSurface,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.glassBorder, width: 1),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.support_agent_rounded, size: 19, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'NexAssist',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.logout_rounded,
                          size: 19,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                        tooltip: 'Sign out',
                        onPressed: () => auth.logout(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: LiquidAuroraBackground(
          child: SafeArea(
            child: child,
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
            child: LiquidGlassPanel(
              blur: 24,
              borderRadius: BorderRadius.circular(30),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MobileNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => _onNavigate(context, 0),
                  ),
                  _MobileNavItem(
                    icon: Icons.inbox_outlined,
                    activeIcon: Icons.inbox_rounded,
                    label: 'Cases',
                    isSelected: currentIndex == 1,
                    onTap: () => _onNavigate(context, 1),
                  ),
                  _MobileNavItem(
                    icon: Icons.menu_book_outlined,
                    activeIcon: Icons.menu_book_rounded,
                    label: 'Knowledge',
                    isSelected: currentIndex == 2,
                    onTap: () => _onNavigate(context, 2),
                  ),
                  _MobileNavItem(
                    icon: Icons.insights_outlined,
                    activeIcon: Icons.insights_rounded,
                    label: 'Insights',
                    isSelected: currentIndex == 3,
                    onTap: () => _onNavigate(context, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // --- TABLET SHELL (Adaptive Navigation Rail) ---
    if (isTablet) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.background,
        body: LiquidAuroraBackground(
          child: Row(
            children: [
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 76,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.glassSurfaceDark : AppColors.glassSurface,
                      border: const Border(
                        right: BorderSide(color: AppColors.glassBorder, width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
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
                          icon: Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                          tooltip: 'Sign out',
                          onPressed: () => auth.logout(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    // --- DESKTOP & WEB SHELL (Spacious Frosted Sidebar) ---
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.background,
      body: LiquidAuroraBackground(
        child: Row(
          children: [
            // Frosted Glass Sidebar
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.glassSurfaceDark : AppColors.glassSurface,
                    border: const Border(
                      right: BorderSide(color: AppColors.glassBorder, width: 1),
                    ),
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
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NexAssist',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  'Operations Workspace',
                                  style: GoogleFonts.publicSans(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppColors.glassBorder, height: 1),

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
                      const Divider(color: AppColors.glassBorder, height: 1),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: LiquidGlassPanel(
                          blur: 16,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  (user?.fullName ?? user?.email ?? 'U')[0].toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.fullName ?? user?.email ?? 'User',
                                      style: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      user?.role ?? '',
                                      style: GoogleFonts.publicSans(
                                        fontSize: 10,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                                tooltip: 'Sign out',
                                onPressed: () => auth.logout(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content View
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTint : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppColors.glassBorderSubtle) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.publicSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryTint : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: isSelected
                  ? Border.all(color: AppColors.glassBorderSubtle, width: 1.5)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 21,
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
        border: isSelected
            ? Border.all(color: AppColors.glassBorderSubtle, width: 1.2)
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 20,
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
