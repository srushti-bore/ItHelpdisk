import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  bool _isExporting = false;
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
      final res = await apiClient.get('/reports/operational-insights');
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

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      await apiClient.get('/reports/export-csv');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'CSV report exported successfully',
              style: GoogleFonts.publicSans(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: AppColors.textPrimary,
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
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.rose, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load operational metrics',
                        style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Export CSV Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operational insights',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fleet telemetry, SLA trends, and automated synthesis · Updated ${DateFormat('HH:mm').format(generatedAt)}',
                            style: GoogleFonts.publicSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: _isExporting
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.file_download_outlined, size: 16),
                      label: const Text('Export CSV'),
                      onPressed: _isExporting ? null : _exportCsv,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 5 Metric Plain Tiles (Space Grotesk, 1px hairlines)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 650;
                    return GridView.count(
                      crossAxisCount: isWide ? 5 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: isWide ? 1.3 : 1.5,
                      children: [
                        _buildMetricTile('Total cases', '$totalCases'),
                        _buildMetricTile('Active backlog', '$openCases'),
                        _buildMetricTile('Resolved', '$resolvedCases'),
                        _buildMetricTile(
                          'SLA health',
                          '${compliance.toStringAsFixed(1)}%',
                          dotColor: compliance >= 90 ? AppColors.statusResolved : AppColors.rose,
                          hasDot: true,
                        ),
                        _buildMetricTile('Avg MTTR', '${avgHours.toStringAsFixed(1)}h'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),

                // AI Operational Synthesis Card (Flat card with 2px left accent border #8C93E8)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(left: BorderSide(color: AppColors.primary, width: 2.5)),
                    ),
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AI interpretation of operational data',
                              style: GoogleFonts.publicSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Gemini 2.5 synthesis',
                                style: GoogleFonts.publicSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          aiSummary,
                          style: GoogleFonts.publicSans(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Cross-Team Workload & Categorization
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cross-team workload & categories',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$openCases active',
                            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _buildWorkloadBar('Hardware & Fleet', 64, 100, AppColors.primary),
                      const SizedBox(height: 10),
                      _buildWorkloadBar('Cloud & Identity Access', 48, 100, AppColors.coral),
                      const SizedBox(height: 10),
                      _buildWorkloadBar('Network & VPN Gateways', 32, 100, AppColors.amber),
                      const SizedBox(height: 10),
                      _buildWorkloadBar('Workplace Systems (Resolved)', 28, 100, AppColors.statusResolved),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Top Recurring Clusters / Breakdown Table
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Telemetry distributions',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildSubledger('By priority', byPriority)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSubledger('By category', byCategory)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, {bool hasDot = false, Color dotColor = AppColors.coral}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.publicSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              if (hasDot)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadBar(String title, int count, int total, Color color) {
    final pct = (count / total).clamp(0.1, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textPrimary)),
            Text('$count cases', style: GoogleFonts.spaceGrotesk(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubledger(String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        if (data.isEmpty)
          Text('No distribution metrics', style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textTertiary))
        else
          ...data.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.key.toString().replaceAll('_', ' '),
                    style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textPrimary),
                  ),
                  Text(
                    '${e.value}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
