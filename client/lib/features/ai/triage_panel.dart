import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/models/case_model.dart';
import 'package:it_helpdesk_client/shared/widgets/liquid_glass_panel.dart';

/// NextAssist AI Triage Copilot Panel
/// Strictly adheres to `Design.md` Section 5.2 & Section 11:
/// - Floating Glass panel with slight blur + depth (visually separated from main UI)
/// - AI suggestions appear as editable cards, clearly labeled
/// - Indigo (#6366F1), Soft Blue (#3B82F6), Soft Purple (#8B5CF6) accents
class AITriagePanel extends StatelessWidget {
  final AITriageModel triage;

  const AITriagePanel({super.key, required this.triage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighConfidence = triage.confidenceLevel.toLowerCase() == 'high';
    final confidenceColor = isHighConfidence ? AppColors.slateTeal : AppColors.warning;
    final confidenceTint = isHighConfidence ? AppColors.slateTealTint : AppColors.warningTint;

    return LiquidGlassPanel(
      blur: 14,
      padding: AppSpacing.cardPadding,
      backgroundColor: isDark ? AppColors.glassSurfaceDark : AppColors.glassSurfaceLight,
      borderColor: isDark ? AppColors.glassBorderDarkAccent : AppColors.glassBorderLightAccent,
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
                      color: AppColors.purpleTint,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.purple),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'AI Triage Copilot',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
              _buildTag('Category', triage.suggestedCategory, AppColors.secondaryTint, AppColors.secondary),
              _buildTag('Severity', triage.suggestedSeverity, AppColors.warningTint, AppColors.warningText),
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
              style: GoogleFonts.publicSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: triage.supportingFactors
                  .map(
                    (factor) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.arrow_right_rounded,
                            size: 16,
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              factor,
                              style: GoogleFonts.publicSans(
                                fontSize: 12,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String label, String value, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w400, color: text.withValues(alpha: 0.8)),
          children: [
            TextSpan(
              text: value,
              style: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w600, color: text),
            ),
          ],
        ),
      ),
    );
  }
}
