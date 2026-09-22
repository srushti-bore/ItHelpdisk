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
import 'package:it_helpdesk_client/shared/constants/app_constants.dart';
import 'package:it_helpdesk_client/shared/models/case_model.dart';
import 'package:it_helpdesk_client/shared/models/message_model.dart';
import 'package:it_helpdesk_client/shared/widgets/priority_badge.dart';
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
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.mobileBreakpoint;
    final auth = context.watch<AuthController>();
    final isStaff = auth.currentUser?.role != 'requester';

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }

    if (_case == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Not found')),
        body: Center(
          child: Text(
            'Case not found',
            style: GoogleFonts.publicSans(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final c = _case!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.go('/cases'),
        ),
        title: Row(
          children: [
            Text(
              c.referenceNumber,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textTertiary),
            ),
            const SizedBox(width: 8),
            Text(
              'Desk workspace',
              style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 960),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Column (65%)
                      Expanded(flex: 65, child: _buildMainColumn(c, isStaff)),
                      const SizedBox(width: 20),
                      // Sidebar (35%)
                      Expanded(flex: 35, child: _buildSidebar(c, isStaff)),
                    ],
                  )
                : Column(
                    children: [
                      _buildMainColumn(c, isStaff),
                      const SizedBox(height: 20),
                      _buildSidebar(c, isStaff),
                    ],
                  ),
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
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
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
                    style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                c.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                c.description,
                style: GoogleFonts.publicSans(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Lifecycle Stepper
              _buildLifecycleStepper(c.status),
              const SizedBox(height: 16),

              // Status & Priority Badges
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  PriorityBadge(priority: c.priority),
                  StatusBadge(status: c.status),
                  if (c.site != null && c.site!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        c.site!,
                        style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Continuous AI Case Summary Card (SRS §5.3)
        if (c.summaryText != null && c.summaryText!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.primary, width: 2.5)),
              ),
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AI summary · Continuous triage',
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
                          'Automated',
                          style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.summaryText!,
                    style: GoogleFonts.publicSans(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Communication & Activity Header Tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildMessageTab('all', 'Activity (${_messages.length})'),
                if (isStaff) ...[
                  const SizedBox(width: 8),
                  _buildMessageTab(
                    'internal',
                    'Internal notes (${_messages.where((m) => m.visibility == 'internal_only').length})',
                  ),
                ],
              ],
            ),
            if (isStaff)
              TextButton.icon(
                icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                label: Text(
                  'Draft with AI',
                  style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
                onPressed: _openDraftAssistant,
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Message Thread List
        if (filteredMessages.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'No messages or notes posted yet.',
              style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 12),
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
              itemCount: filteredMessages.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
              itemBuilder: (context, index) {
                final m = filteredMessages[index];
                final isInternal = m.visibility == 'internal_only';

                return Container(
                  color: isInternal ? AppColors.amberTint.withValues(alpha: 0.3) : Colors.transparent,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  (m.author?.fullName ?? m.author?.email ?? 'U').substring(0, 1).toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                m.author?.fullName ?? m.author?.email ?? 'Support Staff',
                                style: GoogleFonts.publicSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (isInternal) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.amberTint,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    'INTERNAL NOTE',
                                    style: GoogleFonts.publicSans(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.amber,
                                    ),
                                  ),
                                ),
                              ],
                              if (m.aiGenerated) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(3),
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
                            style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        m.body,
                        style: GoogleFonts.publicSans(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),

        // Message Composer Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isStaff)
                Row(
                  children: [
                    _buildVisibilityChip('requester_visible', 'Visible to requester'),
                    const SizedBox(width: 8),
                    _buildVisibilityChip('internal_only', 'Internal staff note'),
                  ],
                )
              else
                Text(
                  'Post update or reply to technician',
                  style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 3,
                style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: _visibility == 'internal_only'
                      ? 'Type internal note (only visible to operators and managers)...'
                      : 'Type an update, provide logs, or request info...',
                ),
              ),
              const SizedBox(height: 10),
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
          AITriagePanel(triage: c.triageResult!),
          const SizedBox(height: 14),
        ],

        // SLA Targets & Operational Health Card
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
                'SLA & Operational targets',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (c.sla != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target resolution',
                      style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      DateFormat('dd MMM, HH:mm').format(c.sla!.targetResolveAt),
                      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Resolution status',
                      style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      c.sla!.resolveBreached ? 'Breached' : 'On track',
                      style: GoogleFonts.publicSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.sla!.resolveBreached ? AppColors.rose : AppColors.statusResolved,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SLA health', style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary)),
                    Text(
                      c.slaBreached ? 'Breached' : 'Within threshold',
                      style: GoogleFonts.publicSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.slaBreached ? AppColors.rose : AppColors.statusResolved,
                      ),
                    ),
                  ],
                ),
              ],
              if (c.riskLevel != null) ...[
                const Divider(color: AppColors.border, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fleet risk index', style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary)),
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
        const SizedBox(height: 14),

        // Operator Assignment & Lifecycle Actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Lifecycle & Assignment',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Assigned operator info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned operator',
                        style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      Text(
                        c.owner?.fullName ?? c.owner?.email ?? 'Unassigned',
                        style: GoogleFonts.publicSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.owner != null ? AppColors.textPrimary : AppColors.coral,
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
              const SizedBox(height: 16),

              // Status Change Action Buttons (Slate-Teal for resolution, No green)
              if (isStaff && c.status != 'resolved' && c.status != 'closed') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus('resolved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusResolved,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Mark as resolved'),
                ),
                const SizedBox(height: 8),
              ],

              if (c.status == 'resolved') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus('closed'),
                  child: const Text('Confirm & close ticket'),
                ),
                const SizedBox(height: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.primaryContainer.withValues(alpha: 0.35) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isCurrent ? Border.all(color: AppColors.primary) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent ? AppColors.primary : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      step.replaceAll('_', ' '),
                      style: GoogleFonts.publicSans(
                        fontSize: 10,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (step != steps.last)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('·', style: GoogleFonts.publicSans(color: AppColors.textTertiary, fontSize: 11)),
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
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? AppColors.border : Colors.transparent),
        ),
        child: Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
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
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryContainer.withValues(alpha: 0.35),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      onSelected: (selected) {
        if (selected) setState(() => _visibility = val);
      },
    );
  }
}
