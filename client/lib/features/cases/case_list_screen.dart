import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/models/case_model.dart';
import 'package:it_helpdesk_client/shared/widgets/gsap_motion.dart';
import 'package:it_helpdesk_client/shared/widgets/priority_badge.dart';
import 'package:it_helpdesk_client/shared/widgets/responsive_grid.dart';
import 'package:it_helpdesk_client/shared/widgets/status_badge.dart';

class CaseListScreen extends StatefulWidget {
  const CaseListScreen({super.key});

  @override
  State<CaseListScreen> createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {
  bool _isLoading = true;
  List<CaseModel> _cases = [];
  String _selectedFilter = 'all'; // all | open | attention | resolved
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCases() async {
    setState(() => _isLoading = true);
    try {
      final query = <String, dynamic>{
        'page': 1,
        'page_size': 50,
      };

      if (_searchController.text.trim().isNotEmpty) {
        query['search'] = _searchController.text.trim();
      }

      final res = await apiClient.get('/cases', queryParams: query);
      final items = (res['items'] as List).map((i) => CaseModel.fromJson(i)).toList();
      if (mounted) {
        setState(() {
          _cases = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<CaseModel> get _filteredCases {
    switch (_selectedFilter) {
      case 'open':
        return _cases.where((c) => c.status != 'resolved' && c.status != 'closed').toList();
      case 'attention':
        return _cases.where((c) => c.status == 'awaiting_requester' || c.status == 'in_assessment' || c.slaBreached).toList();
      case 'resolved':
        return _cases.where((c) => c.status == 'resolved' || c.status == 'closed').toList();
      case 'all':
      default:
        return _cases;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: ResponsiveContentShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                            'Case Ledger',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Track, prioritize, and resolve enterprise tickets',
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
                      label: const Text('New Ticket'),
                      onPressed: () => context.go('/cases/create'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Search Input
              GSAPFadeSlide(
                delay: const Duration(milliseconds: 60),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.hairlineBorder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search by case ID (INC-...) or keywords...',
                            hintStyle: GoogleFonts.publicSans(fontSize: 13, color: AppColors.textTertiary),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onSubmitted: (_) => _fetchCases(),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textTertiary),
                          onPressed: () {
                            _searchController.clear();
                            _fetchCases();
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Filter Chips
              GSAPFadeSlide(
                delay: const Duration(milliseconds: 100),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All (${_cases.length})'),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip('open', 'Open (${_cases.where((c) => c.status != 'resolved' && c.status != 'closed').length})'),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip('attention', 'Needs attention'),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip('resolved', 'Resolved (${_cases.where((c) => c.status == 'resolved' || c.status == 'closed').length})'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Cases List or Skeleton Loader
              if (_isLoading)
                const Column(
                  children: [
                    GSAPShimmerLoader(height: 72, margin: EdgeInsets.only(bottom: AppSpacing.sm)),
                    GSAPShimmerLoader(height: 72, margin: EdgeInsets.only(bottom: AppSpacing.sm)),
                    GSAPShimmerLoader(height: 72, margin: EdgeInsets.only(bottom: AppSpacing.sm)),
                    GSAPShimmerLoader(height: 72),
                  ],
                )
              else if (_filteredCases.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.hairlineBorder),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined, size: 40, color: AppColors.textTertiary),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No cases match filter',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Try clearing your search query or selecting a different status.',
                        style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.hairlineBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCases.length,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.hairlineBorder, height: 1),
                    itemBuilder: (context, index) {
                      final c = _filteredCases[index];
                      return InkWell(
                        onTap: () => context.go('/cases/${c.id}'),
                        hoverColor: AppColors.surfaceContainerLow,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top line: Ref number, requester, time
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
                                      const SizedBox(width: AppSpacing.sm),
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
                                    DateFormat('dd MMM yyyy, HH:mm').format(c.createdAt),
                                    style: GoogleFonts.publicSans(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),

                              // Title
                              Text(
                                c.title,
                                style: GoogleFonts.publicSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // Badges & SLA status
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.xs,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  PriorityBadge(priority: c.priority),
                                  StatusBadge(status: c.status),
                                  if (c.owner != null)
                                    Text(
                                      'Owner: ${c.owner!.fullName ?? c.owner!.email}',
                                      style: GoogleFonts.publicSans(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  else
                                    Text(
                                      'Unassigned',
                                      style: GoogleFonts.publicSans(
                                        fontSize: 11,
                                        color: AppColors.coral,
                                      ),
                                    ),
                                  if (c.slaBreached)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.roseTint,
                                        borderRadius: BorderRadius.circular(AppRadius.xs),
                                      ),
                                      child: Text(
                                        'SLA BREACHED',
                                        style: GoogleFonts.publicSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.rose,
                                        ),
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
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isActive = _selectedFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filterKey),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
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
