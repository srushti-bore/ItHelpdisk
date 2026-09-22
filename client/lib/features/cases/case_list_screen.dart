import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/models/case_model.dart';
import 'package:it_helpdesk_client/shared/widgets/priority_badge.dart';
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
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 860),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Case ledger',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                    label: const Text('New ticket'),
                    onPressed: () => context.go('/cases/create'),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _fetchCases(),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _fetchCases();
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Filter Chips / Segment Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterTab('all', 'All cases (${_cases.length})'),
                    const SizedBox(width: 8),
                    _buildFilterTab('open', 'Active queue'),
                    const SizedBox(width: 8),
                    _buildFilterTab('attention', 'Needs attention'),
                    const SizedBox(width: 8),
                    _buildFilterTab('resolved', 'Resolved'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ledger List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      )
                    : _filteredCases.isEmpty
                        ? RefreshIndicator(
                            onRefresh: _fetchCases,
                            color: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 60),
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
                                        'No matching cases',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Try adjusting your search criteria or filter.',
                                        style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchCases,
                            color: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
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
                                          // Top Row: Ref Number, Requester, Time
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

                                          // Badges row
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
                                                ),
                                              if (c.site != null && c.site!.isNotEmpty)
                                                Text(
                                                  c.site!,
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
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String key, String label) {
    final isActive = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
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
