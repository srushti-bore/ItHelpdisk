import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/models/knowledge_model.dart';
import 'package:it_helpdesk_client/shared/widgets/gsap_motion.dart';
import 'package:it_helpdesk_client/shared/widgets/responsive_grid.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  bool _isLoading = true;
  List<KnowledgeModel> _articles = [];
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Hardware',
    'Software',
    'Network',
    'Access & Identity',
    'Security',
  ];

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchArticles() async {
    setState(() => _isLoading = true);
    try {
      final query = <String, dynamic>{
        'page': 1,
        'page_size': 30,
      };

      if (_selectedCategory != 'All') {
        query['category'] = _selectedCategory.toLowerCase();
      }

      if (_searchController.text.trim().isNotEmpty) {
        query['query'] = _searchController.text.trim();
      }

      final res = await apiClient.get('/knowledge', queryParams: query);
      final items = (res['items'] as List).map((i) => KnowledgeModel.fromJson(i)).toList();

      if (mounted) {
        setState(() {
          _articles = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showArticleDetails(KnowledgeModel article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.isDarkMode ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      article.category,
                      style: GoogleFonts.publicSans(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20, color: context.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                article.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Updated on ${DateFormat('dd MMM yyyy').format(article.updatedAt)} · ${article.state}',
                style: GoogleFonts.publicSans(color: context.textTertiary, fontSize: 12),
              ),
              Divider(color: context.borderColor, height: 28),
              SelectableText(
                article.body,
                style: GoogleFonts.publicSans(
                  fontSize: 14,
                  height: 1.6,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton.icon(
                icon: const Icon(Icons.content_copy_rounded, size: 16),
                label: const Text('Copy Resolution Procedure'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '${article.title}\n\n${article.body}'));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SOP copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateArticleDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String category = 'hardware';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: ctx.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text(
            'New Knowledge Article',
            style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: ctx.textPrimary),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Article Title (e.g. VPN Error 800 Resolution)'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'hardware', child: Text('Hardware')),
                      DropdownMenuItem(value: 'software', child: Text('Software')),
                      DropdownMenuItem(value: 'network', child: Text('Network')),
                      DropdownMenuItem(value: 'access', child: Text('Access & Identity')),
                      DropdownMenuItem(value: 'security', child: Text('Security')),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => category = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: bodyController,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Remediation Steps & Procedure'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) return;
                try {
                  await apiClient.post('/knowledge', body: {
                    'title': titleController.text.trim(),
                    'category': category,
                    'body': bodyController.text.trim(),
                    'tags': [category],
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _fetchArticles();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Failed to publish: $e'), backgroundColor: AppColors.rose),
                    );
                  }
                }
              },
              child: const Text('Publish Article'),
            ),
          ],
        ),
      ),
    );
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
                            'Knowledge Base',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Standard operating procedures and verified remediation guides',
                            style: GoogleFonts.publicSans(
                              fontSize: 13,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('New Article'),
                      onPressed: _showCreateArticleDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Search Bar
              GSAPFadeSlide(
                delay: const Duration(milliseconds: 60),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.borderColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 18, color: context.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.publicSans(fontSize: 13, color: context.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search SOPs, error codes, and troubleshooting guides...',
                            hintStyle: GoogleFonts.publicSans(fontSize: 13, color: context.textTertiary),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onSubmitted: (_) => _fetchArticles(),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 16, color: context.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            _fetchArticles();
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Category Chips
              GSAPFadeSlide(
                delay: const Duration(milliseconds: 100),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: context.isDarkMode ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primaryTint,
                          backgroundColor: context.containerBg,
                          labelStyle: GoogleFonts.publicSans(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.primary : context.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : context.borderColor,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                              _fetchArticles();
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Article Ledger List or Skeleton
              if (_isLoading)
                const Column(
                  children: [
                    GSAPShimmerLoader(height: 80, margin: EdgeInsets.only(bottom: AppSpacing.sm)),
                    GSAPShimmerLoader(height: 80, margin: EdgeInsets.only(bottom: AppSpacing.sm)),
                    GSAPShimmerLoader(height: 80, margin: EdgeInsets.only(bottom: AppSpacing.sm)),
                    GSAPShimmerLoader(height: 80),
                  ],
                )
              else if (_articles.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.article_outlined, size: 40, color: context.textTertiary),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No articles found',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Try another search keyword or category.',
                        style: GoogleFonts.publicSans(color: context.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: context.borderColor),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _articles.length,
                    separatorBuilder: (_, __) => Divider(color: context.borderColor, height: 1),
                    itemBuilder: (context, index) {
                      final art = _articles[index];
                      return InkWell(
                        onTap: () => _showArticleDetails(art),
                        hoverColor: context.hoverBg,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: context.isDarkMode ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primaryTint,
                                      borderRadius: BorderRadius.circular(AppRadius.xs),
                                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                                    ),
                                    child: Text(
                                      art.category,
                                      style: GoogleFonts.publicSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(art.updatedAt),
                                    style: GoogleFonts.publicSans(
                                      fontSize: 11,
                                      color: context.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                art.title,
                                style: GoogleFonts.publicSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                art.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.publicSans(
                                  fontSize: 12,
                                  color: context.textSecondary,
                                  height: 1.45,
                                ),
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
}
