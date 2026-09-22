import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/shared/api_client.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';

class AssignCaseDialog extends StatefulWidget {
  final String caseId;
  final int version;
  final VoidCallback onAssigned;

  const AssignCaseDialog({
    super.key,
    required this.caseId,
    required this.version,
    required this.onAssigned,
  });

  @override
  State<AssignCaseDialog> createState() => _AssignCaseDialogState();
}

class _AssignCaseDialogState extends State<AssignCaseDialog> {
  bool _isLoading = true;
  String? _recommendedTeam;
  List<Map<String, dynamic>> _candidates = [];
  String? _selectedUserId;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _fetchSmartAssignment();
  }

  Future<void> _fetchSmartAssignment() async {
    setState(() => _isLoading = true);
    try {
      final res = await apiClient.get('/ai/cases/${widget.caseId}/smart-assignment');
      if (mounted) {
        setState(() {
          _recommendedTeam = res['recommended_team'];
          _candidates = List<Map<String, dynamic>>.from(res['candidate_operators'] ?? []);
          if (_candidates.isNotEmpty) {
            _selectedUserId = _candidates.first['user_id'];
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAssignment() async {
    if (_selectedUserId == null) return;
    setState(() => _isAssigning = true);

    try {
      await apiClient.patch('/cases/${widget.caseId}/assign', body: {
        'version': widget.version,
        'owner_id': _selectedUserId,
      });

      widget.onAssigned();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Case assigned successfully',
              style: GoogleFonts.publicSans(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: AppColors.textPrimary,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.rose),
        );
      }
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
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
                      'Assign operator',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Smart AI assignment by workload, site & availability',
                      style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 24),

            if (_isLoading)
              Container(
                height: 160,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              )
            else if (_candidates.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No available operators found in this cluster.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 13),
                ),
              )
            else ...[
              if (_recommendedTeam != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.groups_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Recommended team: ',
                        style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        _recommendedTeam!,
                        style: GoogleFonts.publicSans(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

              Text(
                'Candidate operators',
                style: GoogleFonts.publicSans(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),

              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _candidates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, idx) {
                    final op = _candidates[idx];
                    final isSelected = _selectedUserId == op['user_id'];

                    return InkWell(
                      onTap: () => setState(() => _selectedUserId = op['user_id']),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.3) : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        op['full_name'],
                                        style: GoogleFonts.publicSans(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      if (idx == 0) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.statusResolved.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            'Best match',
                                            style: GoogleFonts.publicSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.statusResolved),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    '${op['email']} · ${op['site'] ?? 'Remote'} · ${op['active_case_count']} active',
                                    style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${op['match_score'].toInt()} pts',
                              style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: (_selectedUserId == null || _isAssigning) ? null : _confirmAssignment,
                  child: _isAssigning
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Confirm assignment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
