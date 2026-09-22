import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/models/case_model.dart';

class AITriagePanel extends StatelessWidget {
  final AITriageModel triage;

  const AITriagePanel({super.key, required this.triage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI triage copilot',
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
                    '${triage.confidenceLevel.toLowerCase()} confidence',
                    style: GoogleFonts.publicSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildTag('Category', triage.suggestedCategory),
                _buildTag('Severity', triage.suggestedSeverity),
                _buildTag('Priority', triage.suggestedPriority),
                if (triage.suggestedTeam != null) _buildTag('Team', triage.suggestedTeam!),
              ],
            ),
            const SizedBox(height: 12),

            // Supporting factors
            if (triage.supportingFactors.isNotEmpty) ...[
              Text(
                'Supporting evidence',
                style: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              ...triage.supportingFactors.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('· ', style: GoogleFonts.publicSans(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            f,
                            style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 8),
            ],

            // Missing info
            if (triage.missingInfo.isNotEmpty) ...[
              Text(
                'Clarifying details recommended',
                style: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.coral),
              ),
              const SizedBox(height: 4),
              ...triage.missingInfo.map((q) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('· ', style: GoogleFonts.publicSans(color: AppColors.coral, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            q,
                            style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textPrimary, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
