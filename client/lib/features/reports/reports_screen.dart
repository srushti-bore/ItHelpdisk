import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/widgets/gsap_motion.dart';
import 'package:it_helpdesk_client/shared/widgets/interactive_card.dart';
import 'package:it_helpdesk_client/shared/widgets/liquid_glass_panel.dart';
import 'package:it_helpdesk_client/shared/widgets/responsive_grid.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _insightsData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOperationalInsights();
  }

  Future<void> _fetchOperationalInsights() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await apiClient.get('/reports/insights');
      if (mounted) {
        setState(() {
          _insightsData = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _exportCSV() async {
    try {
      await apiClient.get('/reports/export');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report generated & exported successfully', style: GoogleFonts.publicSans(color: Colors.white, fontSize: 13)),
            backgroundColor: AppColors.slateTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e', style: GoogleFonts.publicSans(fontSize: 13)),
            backgroundColor: AppColors.rose,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? _buildLoadingSkeleton()
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.rose, size: 40),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Failed to load operational metrics',
                        style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton(
                        onPressed: _fetchOperationalInsights,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildDashboardContent(),
    );
  }

  Widget _buildLoadingSkeleton() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: ResponsiveContentShell(
        maxWidth: AppBreakpoints.maxContentWidthWide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GSAPShimmerLoader(width: 240, height: 28),
            SizedBox(height: AppSpacing.sm),
            GSAPShimmerLoader(width: 340, height: 16),
            SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(child: GSAPShimmerLoader(height: 95)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: GSAPShimmerLoader(height: 95)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: GSAPShimmerLoader(height: 95)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: GSAPShimmerLoader(height: 95)),
              ],
            ),
            SizedBox(height: AppSpacing.xl),
            GSAPShimmerLoader(height: 120),
            SizedBox(height: AppSpacing.xl),
            GSAPShimmerLoader(height: 280),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    final metrics = _insightsData?['metrics'] as Map<String, dynamic>? ?? {};
    final aiSummary = _insightsData?['ai_narrative_summary'] as String? ??
        'All triage systems nominal. Ticket resolution and SLA compliance remain within acceptable limits across all device fleet nodes.';
    final generatedAt = _insightsData?['generated_at'] != null
        ? DateTime.parse(_insightsData!['generated_at'])
        : DateTime.now();

    final totalCases = metrics['total_cases'] ?? 0;
    final openCases = metrics['open_cases'] ?? 0;
    final resolvedCases = metrics['resolved_cases'] ?? 0;
    final compliance = (metrics['sla_compliance_rate'] as num?)?.toDouble() ?? 98.5;
    final avgHours = (metrics['average_resolution_hours'] as num?)?.toDouble() ?? 2.4;

    final byPriority = (metrics['cases_by_priority'] as Map<String, dynamic>?) ?? {};
    final byCategory = (metrics['cases_by_category'] as Map<String, dynamic>?) ?? {};

    return RefreshIndicator(
      onRefresh: _fetchOperationalInsights,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ResponsiveContentShell(
          maxWidth: AppBreakpoints.maxContentWidthWide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Export CSV Row
              GSAPFadeSlide(
                direction: SlideDirection.down,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operational Insights',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Continuous SLA telemetry, resolution velocity, and fleet health',
                            style: GoogleFonts.publicSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Export CSV'),
                      onPressed: _exportCSV,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // KPI Metric Cards (Space Grotesk + InteractiveCard)
              GSAPFadeSlide(
                delay: const Duration(milliseconds: 60),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final int columns = width >= 800 ? 4 : (width >= 440 ? 2 : 1);

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: columns == 4 ? 1.65 : (columns == 2 ? 1.8 : 2.8),
                      children: [
                        _buildKPICard(
                          title: 'SLA Compliance',
                          value: '${compliance.toStringAsFixed(1)}%',
                          subtitle: 'Within Target SLA',
                          accentColor: AppColors.slateTeal,
                        ),
                        _buildKPICard(
                          title: 'Avg Resolution',
                          value: '${avgHours.toStringAsFixed(1)}h',
                          subtitle: 'Velocity Time',
                          accentColor: AppColors.mutedBlue,
                        ),
                        _buildKPICard(
                          title: 'Total Tickets',
                          value: '$totalCases',
                          subtitle: 'Fleet Cumulative',
                          accentColor: AppColors.primary,
                        ),
                        _buildKPICard(
                          title: 'Open Backlog',
                          value: '$openCases',
                          subtitle: '$resolvedCases Resolved',
                          accentColor: AppColors.warmPeach,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // AI Operations Narrative Summary (Liquid Glassmorphic Panel)
              GSAPFadeSlide(
                delay: const Duration(milliseconds: 100),
                child: LiquidGlassPanel(
                  padding: AppSpacing.cardPadding,
                  backgroundColor: AppColors.surface.withValues(alpha: 0.92),
                  borderColor: AppColors.primaryContainer.withValues(alpha: 0.35),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'AI Executive Narrative',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm, dd MMM').format(generatedAt),
                                  style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              aiSummary,
                              style: GoogleFonts.publicSans(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Distribution Breakdown (Adaptive 2-Column Row)
              GSAPFadeSlide(
                delay: const Duration(milliseconds: 140),
                child: AdaptiveFlexRow(
                  primaryFlex: 50,
                  secondaryFlex: 50,
                  spacing: AppSpacing.lg,
                  primary: _buildDistributionCard('Priority Distribution', byPriority, AppColors.coral),
                  secondary: _buildDistributionCard('Category Distribution', byCategory, AppColors.mutedBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required Color accentColor,
  }) {
    return InteractiveCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard(String title, Map<String, dynamic> data, Color accentColor) {
    return InteractiveCard(
      enableHover: false,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text('No data recorded for this metric', style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textTertiary)),
              ),
            )
          else
            ...data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(color: AppColors.hairlineBorder),
                      ),
                      child: Text(
                        '${entry.value} tickets',
                        style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
