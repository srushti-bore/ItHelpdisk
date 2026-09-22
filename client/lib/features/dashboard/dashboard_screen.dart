import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:it_helpdesk_client/features/auth/auth_controller.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/models/case_model.dart';
import 'package:it_helpdesk_client/shared/widgets/priority_badge.dart';
import 'package:it_helpdesk_client/shared/widgets/status_badge.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  List<CaseModel> _cases = [];
  int _totalCases = 0;
  int _openCases = 0;
  int _resolvedCases = 0;
  int _atRiskCases = 0;
  String _selectedTab = 'all';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final res = await apiClient.get('/cases', queryParams: {'page': 1, 'page_size': 20});
      final items = (res['items'] as List).map((i) => CaseModel.fromJson(i)).toList();

      if (mounted) {
        setState(() {
          _cases = items;
          _totalCases = res['total'] ?? items.length;
          _openCases = items.where((c) => c.status != 'resolved' && c.status != 'closed').length;
          _resolvedCases = items.where((c) => c.status == 'resolved' || c.status == 'closed').length;
          _atRiskCases = items.where((c) => c.slaBreached || c.priority == 'P1').length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<CaseModel> get _filteredCases {
    switch (_selectedTab) {
      case 'attention':
        return _cases.where((c) => c.status == 'awaiting_requester' || c.status == 'in_assessment' || c.slaBreached).toList();
      case 'open':
        return _cases.where((c) => c.status != 'resolved' && c.status != 'closed').toList();
      case 'resolved':
        return _cases.where((c) => c.status == 'resolved' || c.status == 'closed').toList();
      case 'all':
      default:
        return _cases;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final isOperatorOrAdmin = user?.role == 'operator' || user?.role == 'team_lead' || user?.role == 'admin' || user?.role == 'manager';

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
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
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
                        // Header Greeting & Context
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOperatorOrAdmin ? 'Operator queue' : 'IT service desk',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isOperatorOrAdmin
                                        ? 'Active fleet triage and ticket SLA orchestration'
                                        : 'Assistance, equipment, and automated operations',
                                    style: GoogleFonts.publicSans(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('New ticket'),
                              onPressed: () => context.go('/cases/create'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action Cards (Quick Creation shortcuts)
                        if (!isOperatorOrAdmin) ...[
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 500;
                              return isWide
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: _buildActionCard(
                                            title: 'Report an issue',
                                            badge: 'Incident',
                                            description: 'Hardware, software, or outage disruptions',
                                            onTap: () => context.go('/cases/create'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildActionCard(
                                            title: 'Request a service',
                                            badge: 'Request',
                                            description: 'New equipment, software access, or accounts',
                                            onTap: () => context.go('/cases/create'),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildActionCard(
                                          title: 'Report an issue',
                                          badge: 'Incident',
                                          description: 'Hardware, software, or outage disruptions',
                                          onTap: () => context.go('/cases/create'),
                                        ),
                                        const SizedBox(height: 10),
                                        _buildActionCard(
                                          title: 'Request a service',
                                          badge: 'Request',
                                          description: 'New equipment, software access, or accounts',
                                          onTap: () => context.go('/cases/create'),
                                        ),
                                      ],
                                    );
                            },
                          ),
                          const SizedBox(height: 18),
                        ],

                        // 4 Metric Plain Stat Tiles (Space Grotesk, 1px hairlines)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 600;
                            return GridView.count(
                              crossAxisCount: isWide ? 4 : 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: isWide ? 1.6 : 1.5,
                              children: [
                                _buildMetricTile(
                                  label: isOperatorOrAdmin ? 'Assigned to me' : 'Your cases',
                                  value: '$_totalCases',
                                ),
                                _buildMetricTile(
                                  label: 'Active backlog',
                                  value: '$_openCases',
                                ),
                                _buildMetricTile(
                                  label: 'At risk',
                                  value: '$_atRiskCases',
                                  hasDot: _atRiskCases > 0,
                                  dotColor: AppColors.coral,
                                ),
                                _buildMetricTile(
                                  label: 'Resolved',
                                  value: '$_resolvedCases',
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // AI Operator Briefing (Architectural 2px solid left accent)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(color: AppColors.primary, width: 2.5),
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI suggestion',
                                  style: GoogleFonts.publicSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _atRiskCases > 0
                                      ? 'Prioritize high-urgency incidents first; 2 critical queue items require operator confirmation or diagnostic attachments.'
                                      : 'All queues healthy. Automated triage copilot is indexing requests and monitoring SLA thresholds.',
                                  style: GoogleFonts.publicSans(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Queue Segment Tabs
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildTabButton('all', 'All cases (${_cases.length})'),
                              const SizedBox(width: 8),
                              _buildTabButton('open', 'Open ($_openCases)'),
                              const SizedBox(width: 8),
                              _buildTabButton('attention', 'Needs attention'),
                              const SizedBox(width: 8),
                              _buildTabButton('resolved', 'Resolved ($_resolvedCases)'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Case Ledger Container (1px hairline rules)
                        if (_filteredCases.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(36),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.inbox_outlined, size: 40, color: AppColors.textTertiary),
                                const SizedBox(height: 10),
                                Text(
                                  'No cases in this queue',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'New tickets will appear here once submitted.',
                                  style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredCases.length,
                              separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                              itemBuilder: (context, index) {
                                final c = _filteredCases[index];
                                return InkWell(
                                  onTap: () => context.go('/cases/${c.id}'),
                                  hoverColor: AppColors.surfaceContainerLow,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Top row: Ref Number, Requester/Site, Relative Time
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  c.referenceNumber,
                                                  style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  c.requesterEmail,
                                                  style: GoogleFonts.publicSans(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              DateFormat('dd MMM').format(c.createdAt),
                                              style: GoogleFonts.publicSans(
                                                fontSize: 11,
                                                color: AppColors.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        // Title
                                        Text(
                                          c.title,
                                          style: GoogleFonts.publicSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Badges: Priority, Status, SLA
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            PriorityBadge(priority: c.priority),
                                            StatusBadge(status: c.status),
                                            if (c.slaBreached)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.roseTint,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 5,
                                                      height: 5,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: AppColors.rose,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'SLA breached',
                                                      style: GoogleFonts.publicSans(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.rose,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              Text(
                                                'SLA active',
                                                style: GoogleFonts.publicSans(
                                                  fontSize: 11,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String badge,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
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
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.publicSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.publicSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    bool hasDot = false,
    Color dotColor = AppColors.coral,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabKey, String label) {
    final isActive = _selectedTab == tabKey;
    return InkWell(
      onTap: () => setState(() => _selectedTab = tabKey),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? AppColors.border : Colors.transparent),
        ),
        child: Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
