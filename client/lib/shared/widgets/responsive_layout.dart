import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/features/auth/auth_controller.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_constants.dart';
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
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.mobileBreakpoint;
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    if (!isDesktop) {
      // Mobile Shell with Calmdesk Top App Bar and Bottom Dock Navigation
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          titleSpacing: 16,
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.support_agent_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                'Desk',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textSecondary),
              tooltip: 'Sign out',
              onPressed: () => auth.logout(),
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(color: AppColors.border, height: 1),
          ),
        ),
        body: child,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
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
      );
    }

    // Desktop / Web Shell with Calmdesk Side Drawer
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(right: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NexAssist',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Operations Desk',
                            style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border, height: 1),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                        title: 'Case ledger',
                        isSelected: currentIndex == 1,
                        onTap: () => _onNavigate(context, 1),
                      ),
                      _SidebarItem(
                        icon: Icons.menu_book_outlined,
                        activeIcon: Icons.menu_book_rounded,
                        title: 'Knowledge base',
                        isSelected: currentIndex == 2,
                        onTap: () => _onNavigate(context, 2),
                      ),
                      _SidebarItem(
                        icon: Icons.insights_outlined,
                        activeIcon: Icons.insights_rounded,
                        title: 'Operational insights',
                        isSelected: currentIndex == 3,
                        onTap: () => _onNavigate(context, 3),
                      ),
                    ],
                  ),
                ),

                // User Profile & Sign Out Footer
                const Divider(color: AppColors.border, height: 1),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          (user?.fullName ?? user?.email ?? 'U')[0].toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 10),
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

          // Main Content
          Expanded(child: child),
        ],
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
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.35) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: isSelected ? Border.all(color: AppColors.primary.withValues(alpha: 0.4)) : null,
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 18,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        onTap: onTap,
      ),
    );
  }
}
