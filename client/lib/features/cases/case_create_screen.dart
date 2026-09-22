import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';

class CaseCreateScreen extends StatefulWidget {
  const CaseCreateScreen({super.key});

  @override
  State<CaseCreateScreen> createState() => _CaseCreateScreenState();
}

class _CaseCreateScreenState extends State<CaseCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _caseType = 'incident'; // incident | service_request
  String _priority = 'P3'; // P1, P2, P3, P4
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _siteController = TextEditingController(text: 'Pune');
  bool _isSubmitting = false;

  // AI clarifying questions answers state
  String? _q1Answer;
  String? _q2Answer;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _descController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _siteController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    String finalDesc = _descController.text.trim();
    if (_q1Answer != null || _q2Answer != null) {
      finalDesc += '\n\n[Diagnostic Details]:';
      if (_q1Answer != null) finalDesc += '\n- Connection: $_q1Answer';
      if (_q2Answer != null) finalDesc += '\n- Colleagues affected: $_q2Answer';
    }

    try {
      final res = await apiClient.post('/cases', body: {
        'type': _caseType,
        'title': _titleController.text.trim(),
        'description': finalDesc,
        'priority': _priority,
        'site': _siteController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Case ${res['reference_number']} created successfully',
              style: GoogleFonts.publicSans(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: AppColors.textPrimary,
          ),
        );
        context.go('/cases/${res['id']}');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message, style: GoogleFonts.publicSans(fontSize: 13)),
            backgroundColor: AppColors.rose,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.go('/cases'),
        ),
        title: Text(
          'New request',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppColors.border, height: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step 1: Request Type Switcher
                  Text(
                    'Step 1 · Request type',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeCard(
                          type: 'incident',
                          title: 'Report an issue',
                          description: 'Incident — something is broken',
                          isSelected: _caseType == 'incident',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTypeCard(
                          type: 'service_request',
                          title: 'Request a service',
                          description: 'Need new software or hardware',
                          isSelected: _caseType == 'service_request',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Step 2: Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step 2 · Details',
                        style: GoogleFonts.publicSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'All fields required unless noted',
                        style: GoogleFonts.publicSans(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Title',
                        style: GoogleFonts.publicSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_titleController.text.length}/200',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    maxLength: 200,
                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                    style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Brief summary of the issue',
                    ),
                    validator: (v) => v == null || v.trim().length < 5 ? 'Please enter a title (min. 5 chars)' : null,
                  ),
                  const SizedBox(height: 14),

                  // Description Field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Description',
                        style: GoogleFonts.publicSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_descController.text.length}/5,000',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'What happened and when did it start? Include error codes or affected systems...',
                    ),
                    validator: (v) => v == null || v.trim().length < 10 ? 'Please explain in detail (min. 10 chars)' : null,
                  ),
                  const SizedBox(height: 16),

                  // AI Clarifying Questions Anchor Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: AppColors.primary, width: 2)),
                      ),
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI suggestion · Optional clarifying questions',
                            style: GoogleFonts.publicSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Does this happen on Ethernet or Wi-Fi?',
                            style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: ['Ethernet', 'Wi-Fi only', 'Both'].map((opt) {
                              final sel = _q1Answer == opt;
                              return ChoiceChip(
                                label: Text(opt, style: GoogleFonts.publicSans(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                                selected: sel,
                                selectedColor: AppColors.primaryContainer,
                                backgroundColor: AppColors.surfaceContainerLow,
                                side: BorderSide(color: sel ? AppColors.primary : AppColors.border),
                                onSelected: (val) => setState(() => _q1Answer = val ? opt : null),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Are colleagues in your location experiencing this?',
                            style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: ['Yes', 'No', 'Not sure'].map((opt) {
                              final sel = _q2Answer == opt;
                              return ChoiceChip(
                                label: Text(opt, style: GoogleFonts.publicSans(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                                selected: sel,
                                selectedColor: AppColors.primaryContainer,
                                backgroundColor: AppColors.surfaceContainerLow,
                                side: BorderSide(color: sel ? AppColors.primary : AppColors.border),
                                onSelected: (val) => setState(() => _q2Answer = val ? opt : null),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Priority and Location row
                  Row(
                    children: [
                      // Urgency
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Urgency / Priority',
                              style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _priority,
                              isExpanded: true,
                              style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'P1', child: Text('P1 critical (Work stoppage)')),
                                DropdownMenuItem(value: 'P2', child: Text('P2 high (Significant impact)')),
                                DropdownMenuItem(value: 'P3', child: Text('P3 medium (Normal)')),
                                DropdownMenuItem(value: 'P4', child: Text('P4 low (Minor inquiry)')),
                              ],
                              onChanged: (v) => setState(() => _priority = v ?? 'P3'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Location / Site
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Office site',
                              style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _siteController,
                              style: GoogleFonts.publicSans(fontSize: 13, color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Pune, London, New York',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/cases'),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Submit case'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String type,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _caseType = type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.35) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 4 : 1.5,
                    ),
                    color: isSelected ? AppColors.surface : Colors.transparent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.publicSans(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
