import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/widgets/gsap_motion.dart';
import 'package:it_helpdesk_client/shared/widgets/liquid_glass_panel.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String category; // 'sla' | 'case' | 'ai' | 'system'
  final bool isRead;
  final String? caseId;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.category,
    this.isRead = false,
    this.caseId,
  });
}

/// NextAssist Glass Slide-In Notification Panel
/// Strictly adheres to `Design.md` Section 10:
/// - Glass container (uses Section 5 rules)
/// - Slide + fade animation
/// - Categorized (SLA, Case, AI)
/// - Actionable links
class NotificationPanel extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(String caseId)? onSelectCase;

  const NotificationPanel({
    super.key,
    required this.onClose,
    this.onSelectCase,
  });

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  String _activeCategory = 'all';

  final List<NotificationItem> _notifications = const [
    NotificationItem(
      id: '1',
      title: 'SLA Warning: P1 VPN Outage',
      message: 'Case INC-2026-000042 is at 80% SLA threshold (18m remaining).',
      timeAgo: '4m ago',
      category: 'sla',
      isRead: false,
      caseId: 'INC-2026-000042',
    ),
    NotificationItem(
      id: '2',
      title: 'AI Triage Copilot Match',
      message: 'Automated remediation SOP found for "CrowdStrike Sensor failure".',
      timeAgo: '12m ago',
      category: 'ai',
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'New Case Assigned',
      message: 'Operator assignment: SR-2026-000019 (Workstation Provisioning).',
      timeAgo: '45m ago',
      category: 'case',
      isRead: true,
      caseId: 'SR-2026-000019',
    ),
    NotificationItem(
      id: '4',
      title: 'Background Sweep Completed',
      message: '14 active cases verified against operational targets. Zero breaches.',
      timeAgo: '1h ago',
      category: 'system',
      isRead: true,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_activeCategory == 'all') return _notifications;
    return _notifications.where((n) => n.category == _activeCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GSAPFadeSlide(
      direction: SlideDirection.left,
      duration: const Duration(milliseconds: 260),
      child: Container(
        width: 380,
        height: double.infinity,
        margin: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
        child: LiquidGlassPanel(
          blur: 16,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          backgroundColor: isDark ? AppColors.glassSurfaceDark : AppColors.glassSurfaceLight,
          borderColor: isDark ? AppColors.glassBorderDarkAccent : AppColors.glassBorderLightAccent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Notifications',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 19,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.hairlineBorder),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All (4)'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildFilterChip('sla', 'SLA Alerts'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildFilterChip('ai', 'AI Insights'),
                      const SizedBox(width: AppSpacing.xs),
                      _buildFilterChip('case', 'Cases'),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.hairlineBorder),

              // Notification List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: _filteredNotifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.hairlineBorder),
                  itemBuilder: (context, index) {
                    final item = _filteredNotifications[index];
                    return _buildNotificationRow(item, isDark);
                  },
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Auto-sync with Sweep',
                        style: GoogleFonts.publicSans(
                          fontSize: 11,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                      child: Text(
                        'Mark all read',
                        style: GoogleFonts.publicSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _activeCategory == key;
    return InkWell(
      onTap: () => setState(() => _activeCategory = key),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.hairlineBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationRow(NotificationItem item, bool isDark) {
    Color iconColor;
    IconData iconData;
    Color iconBg;

    switch (item.category) {
      case 'sla':
        iconColor = AppColors.dangerRose;
        iconBg = AppColors.dangerTint;
        iconData = Icons.timer_outlined;
        break;
      case 'ai':
        iconColor = AppColors.purple;
        iconBg = AppColors.purpleTint;
        iconData = Icons.auto_awesome_rounded;
        break;
      case 'case':
        iconColor = AppColors.secondary;
        iconBg = AppColors.secondaryTint;
        iconData = Icons.inbox_rounded;
        break;
      default:
        iconColor = AppColors.primary;
        iconBg = AppColors.primaryTint;
        iconData = Icons.info_outline_rounded;
    }

    return InkWell(
      onTap: () {
        if (item.caseId != null && widget.onSelectCase != null) {
          widget.onSelectCase!(item.caseId!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        color: item.isRead ? Colors.transparent : AppColors.primaryTint.withValues(alpha: 0.3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(iconData, size: 16, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.publicSans(
                            fontSize: 12,
                            fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        item.timeAgo,
                        style: GoogleFonts.publicSans(fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.message,
                    style: GoogleFonts.publicSans(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
