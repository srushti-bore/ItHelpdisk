import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:it_helpdesk_client/features/ai/draft_dialog.dart';
import 'package:it_helpdesk_client/features/ai/triage_panel.dart';
import 'package:it_helpdesk_client/features/auth/auth_controller.dart';
import 'package:it_helpdesk_client/features/cases/assign_dialog.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/models/case_model.dart';
import 'package:it_helpdesk_client/shared/models/message_model.dart';
import 'package:it_helpdesk_client/shared/widgets/gsap_motion.dart';
import 'package:it_helpdesk_client/shared/widgets/interactive_card.dart';
import 'package:it_helpdesk_client/shared/widgets/liquid_glass_panel.dart';
import 'package:it_helpdesk_client/shared/widgets/priority_badge.dart';
import 'package:it_helpdesk_client/shared/widgets/responsive_grid.dart';
import 'package:it_helpdesk_client/shared/widgets/status_badge.dart';
import 'package:provider/provider.dart';

class CaseDetailScreen extends StatefulWidget {
  final String caseId;

  const CaseDetailScreen({super.key, required this.caseId});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  bool _isLoading = true;
  CaseModel? _case;
  List<MessageModel> _messages = [];
  final _messageController = TextEditingController();
  String _visibility = 'requester_visible';
  bool _isSending = false;
  String _messageTab = 'all'; // all | internal

  @override
  void initState() {
    super.initState();
    _fetchCaseDetails();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchCaseDetails() async {
    setState(() => _isLoading = true);
    try {
      final caseRes = await apiClient.get('/cases/${widget.caseId}');
      final msgRes = await apiClient.get('/cases/${widget.caseId}/messages');

      if (mounted) {
        setState(() {
          _case = CaseModel.fromJson(caseRes);
          _messages = (msgRes as List).map((m) => MessageModel.fromJson(m)).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _case == null) return;
    setState(() => _isSending = true);

    try {
      await apiClient.post('/cases/${_case!.id}/messages', body: {
        'body': _messageController.text.trim(),
        'visibility': _visibility,
        'ai_generated': false,
      });

      _messageController.clear();
      await _fetchCaseDetails();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post message')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _updateStatus(String targetStatus) async {
    if (_case == null) return;
    try {
      await apiClient.patch('/cases/${_case!.id}/status', body: {
        'version': _case!.version,
        'target_status': targetStatus,
      });
      _fetchCaseDetails();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.rose),
        );
      }
    }
  }

  void _openDraftAssistant() {
    showDialog(
      context: context,
      builder: (_) => AIDraftDialog(
        caseId: widget.caseId,
        onMessageSent: _fetchCaseDetails,
      ),
    );
  }

  void _openAssignDialog() {
    if (_case == null) return;
    showDialog(
      context: context,
      builder: (_) => AssignCaseDialog(
        caseId: _case!.id,
        version: _case!.version,
        onAssigned: _fetchCaseDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isStaff = auth.currentUser?.role != 'requester';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(title: const Text('Loading case details...')),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: ResponsiveContentShell(
            maxWidth: AppBreakpoints.maxContentWidthWide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GSAPShimmerLoader(height: 180),
                SizedBox(height: AppSpacing.lg),
                GSAPShimmerLoader(height: 120),
                SizedBox(height: AppSpacing.lg),
                GSAPShimmerLoader(height: 240),
              ],
            ),
          ),
        ),
      );
    }

    if (_case == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(title: const Text('Not found')),
        body: Center(
          child: Text(
            'Case not found',
            style: GoogleFonts.publicSans(color: context.textSecondary),
          ),
        ),
      );
    }

    final c = _case!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 20, color: context.textPrimary),
          onPressed: () => context.go('/cases'),
        ),
        title: Row(
          children: [
            Text(
              c.referenceNumber,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(shape: BoxShape.circle, color: context.textTertiary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Desk workspace',
              style: GoogleFonts.publicSans(fontSize: 12, color: context.textSecondary),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: context.borderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContentShell(
          maxWidth: AppBreakpoints.maxContentWidthWide,
          child: AdaptiveFlexRow(
            primaryFlex: 64,
            secondaryFlex: 36,
            spacing: AppSpacing.xl,
            primary: _buildMainColumn(c, isStaff),
            secondary: _buildSidebar(c, isStaff),
          ),
        ),
      ),
    );
  }

  Widget _buildMainColumn(CaseModel c, bool isStaff) {
    final filteredMessages = _messageTab == 'internal'
        ? _messages.where((m) => m.visibility == 'internal_only').toList()
        : _messages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Case Meta Card
        GSAPFadeSlide(
          direction: SlideDirection.down,
          child: InteractiveCard(
            enableHover: false,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reference ${c.referenceNumber}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Created ${DateFormat('dd MMM yyyy').format(c.createdAt)}',
                      style: GoogleFonts.publicSans(fontSize: 11, color: context.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Title
                Text(
                  c.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  c.description,
                  style: GoogleFonts.publicSans(
                    fontSize: 13,
                    color: context.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Horizontal Lifecycle Stepper
                _buildLifecycleStepper(c.status),
                const SizedBox(height: AppSpacing.lg),

                // Status & Priority Badges
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PriorityBadge(priority: c.priority),
                    StatusBadge(status: c.status),
                    if (c.site != null && c.site!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.containerBg,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Text(
                          c.site!,
                          style: GoogleFonts.publicSans(fontSize: 11, color: context.textSecondary),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Continuous AI Case Summary Card (Liquid Glassmorphism)
        if (c.summaryText != null && c.summaryText!.isNotEmpty) ...[
          GSAPFadeSlide(
            delay: const Duration(milliseconds: 60),
            child: LiquidGlassPanel(
              padding: AppSpacing.cardPadding,
              backgroundColor: context.isDarkMode ? AppColors.glassSurfaceDark : AppColors.glassSurfaceLight,
              borderColor: context.isDarkMode ? AppColors.glassBorderDarkAccent : AppColors.glassBorderLightAccent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'AI Summary · Continuous Triage',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.isDarkMode ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          'Live Summary',
                          style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    c.summaryText!,
                    style: GoogleFonts.publicSans(fontSize: 13, color: context.textPrimary, height: 1.45),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Activity & Messages Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildMessageTab('all', 'Public conversation (${_messages.where((m) => m.visibility != 'internal_only').length})'),
                if (isStaff) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _buildMessageTab('internal', 'Internal staff notes (${_messages.where((m) => m.visibility == 'internal_only').length})'),
                ],
              ],
            ),
            if (isStaff)
              TextButton.icon(
                icon: const Icon(Icons.auto_awesome_rounded, size: 15, color: AppColors.primary),
                label: Text(
                  'Draft with AI',
                  style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
                onPressed: _openDraftAssistant,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Message Thread List
        if (filteredMessages.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.borderColor),
            ),
            child: Text(
              'No messages or notes posted yet.',
              style: GoogleFonts.publicSans(color: context.textSecondary, fontSize: 12),
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
              itemCount: filteredMessages.length,
              separatorBuilder: (_, __) => Divider(color: context.borderColor, height: 1),
              itemBuilder: (context, index) {
                final m = filteredMessages[index];
                final isInternal = m.visibility == 'internal_only';

                return Container(
                  color: isInternal ? AppColors.amberTint.withValues(alpha: context.isDarkMode ? 0.12 : 0.35) : Colors.transparent,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: context.isDarkMode ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primaryTint,
                                  borderRadius: BorderRadius.circular(AppRadius.xs),
                                  border: Border.all(color: context.borderColor),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  (m.author?.fullName ?? m.author?.email ?? 'U').substring(0, 1).toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                m.author?.fullName ?? m.author?.email ?? 'Support Staff',
                                style: GoogleFonts.publicSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                              if (isInternal) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.amberTint,
                                    borderRadius: BorderRadius.circular(AppRadius.xs),
                                  ),
                                  child: Text(
                                    'INTERNAL NOTE',
                                    style: GoogleFonts.publicSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warningText,
                                    ),
                                  ),
                                ),
                              ],
                              if (m.aiGenerated) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: context.isDarkMode ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primaryTint,
                                    borderRadius: BorderRadius.circular(AppRadius.xs),
                                  ),
                                  child: Text(
                                    'AI DRAFT',
                                    style: GoogleFonts.publicSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            DateFormat('dd MMM, HH:mm').format(m.createdAt),
                            style: GoogleFonts.publicSans(fontSize: 11, color: context.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        m.body,
                        style: GoogleFonts.publicSans(
                          fontSize: 13,
                          color: context.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: AppSpacing.lg),

        // Message Composer Card
        InteractiveCard(
          enableHover: false,
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isStaff)
                Row(
                  children: [
                    _buildVisibilityChip('requester_visible', 'Visible to requester'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildVisibilityChip('internal_only', 'Internal staff note'),
                  ],
                )
              else
                Text(
                  'Post update or reply to technician',
                  style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: context.textSecondary),
                ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _messageController,
                maxLines: 3,
                style: GoogleFonts.publicSans(fontSize: 13, color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: _visibility == 'internal_only'
                      ? 'Type internal note (only visible to operators and managers)...'
                      : 'Type an update, provide logs, or request info...',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendMessage,
                  child: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send update'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(CaseModel c, bool isStaff) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Triage Panel (if available)
        if (c.triageResult != null) ...[
          GSAPFadeSlide(
            delay: const Duration(milliseconds: 100),
            child: AITriagePanel(triage: c.triageResult!),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // SLA Targets & Operational Health Card
        GSAPFadeSlide(
          delay: const Duration(milliseconds: 140),
          child: InteractiveCard(
            enableHover: false,
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SLA & Operational targets',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (c.sla != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target resolution',
                        style: GoogleFonts.publicSans(fontSize: 12, color: context.textSecondary),
                      ),
                      Text(
                        DateFormat('dd MMM, HH:mm').format(c.sla!.targetResolveAt),
                        style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resolution status',
                        style: GoogleFonts.publicSans(fontSize: 12, color: context.textSecondary),
                      ),
                      Text(
                        c.sla!.resolveBreached ? 'Breached' : 'On track',
                        style: GoogleFonts.publicSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.sla!.resolveBreached ? AppColors.rose : AppColors.slateTeal,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SLA health', style: GoogleFonts.publicSans(fontSize: 12, color: context.textSecondary)),
                      Text(
                        c.slaBreached ? 'Breached' : 'Within threshold',
                        style: GoogleFonts.publicSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.slaBreached ? AppColors.rose : AppColors.slateTeal,
                        ),
                      ),
                    ],
                  ),
                ],
                if (c.riskLevel != null) ...[
                  Divider(color: context.borderColor, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fleet risk index', style: GoogleFonts.publicSans(fontSize: 12, color: context.textSecondary)),
                      Text(
                        '${c.riskLevel} risk',
                        style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.amber),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Operator Assignment & Lifecycle Actions
        GSAPFadeSlide(
          delay: const Duration(milliseconds: 180),
          child: InteractiveCard(
            enableHover: false,
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Lifecycle & Assignment',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Assigned operator info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assigned operator',
                          style: GoogleFonts.publicSans(fontSize: 11, color: context.textSecondary),
                        ),
                        Text(
                          c.owner?.fullName ?? c.owner?.email ?? 'Unassigned',
                          style: GoogleFonts.publicSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.owner != null ? context.textPrimary : AppColors.coral,
                          ),
                        ),
                      ],
                    ),
                    if (isStaff && c.status != 'closed')
                      OutlinedButton(
                        onPressed: _openAssignDialog,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          c.owner == null ? 'Assign' : 'Reassign',
                          style: GoogleFonts.publicSans(fontSize: 11),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Status Change Action Buttons (Slate-Teal for resolution, No green)
                if (isStaff && c.status != 'resolved' && c.status != 'closed') ...[
                  ElevatedButton(
                    onPressed: () => _updateStatus('resolved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.slateTeal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark as resolved'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                if (c.status == 'resolved') ...[
                  ElevatedButton(
                    onPressed: () => _updateStatus('closed'),
                    child: const Text('Confirm & close ticket'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                if (c.status == 'closed')
                  OutlinedButton.icon(
                    icon: const Icon(Icons.replay_rounded, size: 16),
                    label: const Text('Reopen case'),
                    onPressed: () => _updateStatus('assigned'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLifecycleStepper(String currentStatus) {
    final steps = [
      'new',
      'in_assessment',
      'assigned',
      'awaiting_requester',
      'resolved',
      'closed',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: steps.map((step) {
          final isCurrent = currentStatus.toLowerCase() == step;
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrent ? (context.isDarkMode ? AppColors.primary.withValues(alpha: 0.25) : AppColors.primaryTint) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: isCurrent ? Border.all(color: AppColors.primary) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent ? AppColors.primary : context.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      step.replaceAll('_', ' '),
                      style: GoogleFonts.publicSans(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isCurrent ? AppColors.primary : context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (step != steps.last)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('·', style: GoogleFonts.publicSans(color: context.textTertiary, fontSize: 11)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageTab(String tabKey, String label) {
    final isActive = _messageTab == tabKey;
    return InkWell(
      onTap: () => setState(() => _messageTab = tabKey),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? context.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: isActive ? context.borderColor : Colors.transparent),
        ),
        child: Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? context.textPrimary : context.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityChip(String val, String label) {
    final isSelected = _visibility == val;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.publicSans(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? context.textPrimary : context.textSecondary,
        ),
      ),
      selected: isSelected,
      selectedColor: context.isDarkMode ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primaryTint,
      backgroundColor: context.containerBg,
      side: BorderSide(color: isSelected ? AppColors.primary : context.borderColor),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      onSelected: (selected) {
        if (selected) setState(() => _visibility = val);
      },
    );
  }
}
