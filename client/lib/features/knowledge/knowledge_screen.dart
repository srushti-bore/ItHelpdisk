import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/models/knowledge_model.dart';

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
    'VPN',
    'Email & Communication',
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
        'page_size': 50,
      };

      if (_selectedCategory != 'All') {
        query['category'] = _selectedCategory;
      }
      if (_searchController.text.trim().isNotEmpty) {
        query['search'] = _searchController.text.trim();
      }

      final res = await apiClient.get('/knowledge/articles', queryParams: query);
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      article.category,
                      style: GoogleFonts.publicSans(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Updated on ${DateFormat('dd MMM yyyy').format(article.updatedAt)} · ${article.state}',
                style: GoogleFonts.publicSans(color: AppColors.textTertiary, fontSize: 12),
              ),
              const Divider(color: AppColors.border, height: 28),
              SelectableText(
                article.body,
                style: GoogleFonts.publicSans(
                  fontSize: 13,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                icon: const Icon(Icons.content_copy_rounded, size: 16),
                label: const Text('Copy resolution steps'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: article.body));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Copied resolution steps to clipboard',
                        style: GoogleFonts.publicSans(color: Colors.white, fontSize: 13),
                      ),
                      backgroundColor: AppColors.textPrimary,
                    ),
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
    final categoryController = TextEditingController(text: 'Hardware');
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Author knowledge article',
          style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  style: GoogleFonts.publicSans(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Article title',
                    hintText: 'e.g. How to re-enroll office Wi-Fi certificates',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  style: GoogleFonts.publicSans(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'e.g. Hardware, Network, VPN',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 6,
                  style: GoogleFonts.publicSans(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Content / Remediation guide',
                    hintText: 'Step-by-step diagnostic and remediation guide...',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) return;
              try {
                await apiClient.post(
                  '/knowledge/articles',
                  body: {
                    'title': titleController.text.trim(),
                    'category': categoryController.text.trim(),
                    'body': bodyController.text.trim(),
                    'state': 'published',
                  },
                );
                if (context.mounted) Navigator.pop(context);
                _fetchArticles();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.rose),
                  );
                }
              }
            },
            child: const Text('Publish article'),
          ),
        ],
      ),
    );
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
                          'Knowledge base',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Standard operating procedures and verified remediation guides',
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
                    label: const Text('New article'),
                    onPressed: _showCreateArticleDialog,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Search Bar
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
                          hintText: 'Search SOPs, error codes, and troubleshooting guides...',
                          hintStyle: GoogleFonts.publicSans(fontSize: 13, color: AppColors.textTertiary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _fetchArticles(),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _fetchArticles();
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primaryContainer.withValues(alpha: 0.35),
                        backgroundColor: AppColors.surface,
                        labelStyle: GoogleFonts.publicSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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
              const SizedBox(height: 16),

              // Article Ledger List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      )
                    : _articles.isEmpty
                        ? RefreshIndicator(
                            onRefresh: _fetchArticles,
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
                                      const Icon(Icons.article_outlined, size: 40, color: AppColors.textTertiary),
                                      const SizedBox(height: 10),
                                      Text(
                                        'No articles found',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Try another search keyword or category.',
                                        style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchArticles,
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
                                itemCount: _articles.length,
                                separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                                itemBuilder: (context, index) {
                                  final art = _articles[index];
                                  return InkWell(
                                    onTap: () => _showArticleDetails(art),
                                    hoverColor: AppColors.surfaceContainerLow,
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceContainerLow,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  art.category,
                                                  style: GoogleFonts.publicSans(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                DateFormat('dd MMM yyyy').format(art.updatedAt),
                                                style: GoogleFonts.publicSans(
                                                  fontSize: 11,
                                                  color: AppColors.textTertiary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            art.title,
                                            style: GoogleFonts.publicSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            art.body,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.publicSans(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                              height: 1.4,
                                            ),
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
}
