import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';

class AIDraftDialog extends StatefulWidget {
  final String caseId;
  final VoidCallback onMessageSent;

  const AIDraftDialog({super.key, required this.caseId, required this.onMessageSent});

  @override
  State<AIDraftDialog> createState() => _AIDraftDialogState();
}

class _AIDraftDialogState extends State<AIDraftDialog> {
  String _draftType = 'info_request';
  final _instructionsController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _draftId;
  bool _isGenerating = false;
  bool _isSending = false;

  @override
  void dispose() {
    _instructionsController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _generateDraft() async {
    setState(() => _isGenerating = true);
    try {
      final res = await apiClient.post('/ai/cases/${widget.caseId}/draft', body: {
        'draft_type': _draftType,
        'custom_instructions': _instructionsController.text.trim(),
      });

      if (mounted) {
        setState(() {
          _draftId = res['id'];
          _bodyController.text = res['body'] ?? '';
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate draft. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _sendDraft() async {
    if (_draftId == null || _bodyController.text.trim().isEmpty) return;
    setState(() => _isSending = true);

    try {
      await apiClient.post('/ai/drafts/$_draftId/send', body: {
        'body': _bodyController.text.trim(),
      });

      widget.onMessageSent();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderColor),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI draft assistant',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Automated response drafting · Human-in-the-loop',
                      style: GoogleFonts.publicSans(fontSize: 12, color: context.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: context.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(color: context.borderColor, height: 24),

            // Message Purpose
            Text(
              'Message purpose',
              style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: context.textPrimary),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _draftType,
              style: GoogleFonts.publicSans(fontSize: 13, color: context.textPrimary),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'info_request', child: Text('Request missing information / logs')),
                DropdownMenuItem(value: 'progress_update', child: Text('Send diagnostic progress update')),
                DropdownMenuItem(value: 'resolution', child: Text('Confirm resolution with requester')),
                DropdownMenuItem(value: 'escalation_summary', child: Text('Escalation handover summary note')),
              ],
              onChanged: (v) => setState(() => _draftType = v ?? 'info_request'),
            ),
            const SizedBox(height: 12),

            // Generate Button
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateDraft,
              child: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Generate AI draft'),
            ),
            const SizedBox(height: 16),

            // Edit text area
            Text(
              'Review & edit draft',
              style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: context.textPrimary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _bodyController,
              maxLines: 5,
              style: GoogleFonts.publicSans(fontSize: 13, color: context.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Generated draft will appear here. Edit any text before approval...',
              ),
            ),
            const SizedBox(height: 18),

            // Send Button
            if (_bodyController.text.isNotEmpty)
              ElevatedButton(
                onPressed: _isSending ? null : _sendDraft,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slateTeal,
                  foregroundColor: Colors.white,
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Approve & send update'),
              ),
          ],
        ),
      ),
    );
  }
}
