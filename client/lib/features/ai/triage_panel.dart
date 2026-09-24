import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/models/case_model.dart';
import 'package:it_helpdesk_client/shared/widgets/liquid_glass_panel.dart';

/// NextAssist AI Triage Copilot Panel
/// Strictly adheres to `NextAssist — Design.md`:
/// - Section 6: Liquid Glassmorphism for AI Assistant components
/// - Section 3: AI is assistive, not dominant
/// - Section 4: Pastel sRGB palette (Soft Lavender, Warm Peach, Slate-Teal)
class AITriagePanel extends StatelessWidget {
  final AITriageModel triage;

  const AITriagePanel({super.key, required this.triage});

  @override
  Widget build(BuildContext context) {
    final isHighConfidence = triage.confidenceLevel.toLowerCase() == 'high';
    final confidenceColor = isHighConfidence ? AppColors.slateTeal : AppColors.amber;
    final confidenceTint = isHighConfidence ? AppColors.slateTealTint : AppColors.amberTint;

    return LiquidGlassPanel(
      blur: 24,
      padding: AppSpacing.cardPadding,
      backgroundColor: AppColors.glassSurface,
      borderColor: AppColors.glassBorderSubtle,
      borderWidth: 1.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'AI Triage Copilot',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: confidenceTint,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: confidenceColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  '${triage.confidenceLevel.toLowerCase()} confidence',
                  style: GoogleFonts.publicSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: confidenceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Suggestion Chips
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _buildTag('Category', triage.suggestedCategory, AppColors.mutedBlueTint, AppColors.mutedBlue),
              _buildTag('Severity', triage.suggestedSeverity, AppColors.amberTint, AppColors.warningText),
              _buildTag('Priority', triage.suggestedPriority, AppColors.dangerTint, AppColors.dangerText),
              if (triage.suggestedTeam != null)
                _buildTag('Team', triage.suggestedTeam!, AppColors.primaryTint, AppColors.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Supporting factors
          if (triage.supportingFactors.isNotEmpty) ...[
            Text(
              'Supporting Evidence',
              style: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...triage.supportingFactors.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
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
            const SizedBox(height: AppSpacing.sm),
          ],

          // Missing info
          if (triage.missingInfo.isNotEmpty) ...[
            Text(
              'Clarifying Details Recommended',
              style: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warmPeachText),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...triage.missingInfo.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('· ', style: GoogleFonts.publicSans(color: AppColors.warmPeach, fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildTag(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: GoogleFonts.publicSans(fontSize: 11, color: textColor.withValues(alpha: 0.8))),
          Text(value, style: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }
}
