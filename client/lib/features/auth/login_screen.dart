import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/features/auth/auth_controller.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/widgets/gsap_motion.dart';
import 'package:it_helpdesk_client/shared/widgets/interactive_card.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberSession = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final success = await auth.login(_emailController.text.trim(), _passwordController.text);
    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding(context),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header Block
                    GSAPFadeSlide(
                      direction: SlideDirection.down,
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NexAssist',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Enterprise AI Technical Operations',
                                style: GoogleFonts.publicSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Login Card
                    GSAPFadeSlide(
                      delay: const Duration(milliseconds: 60),
                      child: InteractiveCard(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        enableHover: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Welcome Headline
                            Text(
                              'Sign In',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Enter your institutional credentials to access assigned triage queues.',
                              style: GoogleFonts.publicSans(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Error Banner if present
                            if (auth.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerTint,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: AppColors.dangerRose.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.dangerRose),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        auth.errorMessage!,
                                        style: GoogleFonts.publicSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.dangerText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Email Input Field
                            Text(
                              'Email Address',
                              style: GoogleFonts.publicSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.publicSans(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'operator@nexassist.internal',
                                prefixIcon: Icon(Icons.mail_outline_rounded, size: 18),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email is required';
                                if (!v.contains('@')) return 'Enter a valid email address';
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Password Input Field
                            Text(
                              'Password',
                              style: GoogleFonts.publicSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.publicSans(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18,
                                    color: AppColors.textTertiary,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password is required';
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: _rememberSession,
                                        activeColor: AppColors.primary,
                                        onChanged: (v) => setState(() => _rememberSession = v ?? true),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Remember session',
                                      style: GoogleFonts.publicSans(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                  child: Text(
                                    'Need Help?',
                                    style: GoogleFonts.publicSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            // Submit Action Button (Indigo)
                            ElevatedButton(
                              onPressed: auth.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Sign in to Workspace',
                                      style: GoogleFonts.publicSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Demo Accounts Quick Picker
                    GSAPFadeSlide(
                      delay: const Duration(milliseconds: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Institutional Quick-Access Profiles:',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              _buildDemoChip('L1 Operator (Priya)', 'operator@nexassist.internal', 'Password123!', AppColors.primary),
                              _buildDemoChip('Admin (Elena)', 'admin@nexassist.internal', 'Password123!', AppColors.secondary),
                              _buildDemoChip('Requester (Rahul)', 'rahul.requester@nexassist.internal', 'Password123!', AppColors.purple),
                              _buildDemoChip('Team Lead (Marcus)', 'teamlead@nexassist.internal', 'Password123!', AppColors.warning),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Compliance & Version Footer
                    Center(
                      child: Text(
                        'NexAssist Operations Core v3.3 · SOC2 Compliant',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoChip(String label, String email, String password, Color accentColor) {
    return ActionChip(
      avatar: Icon(Icons.person_outline_rounded, size: 14, color: accentColor),
      label: Text(
        label,
        style: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      backgroundColor: accentColor.withValues(alpha: 0.1),
      side: BorderSide(color: accentColor.withValues(alpha: 0.25)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      onPressed: () {
        setState(() {
          _emailController.text = email;
          _passwordController.text = password;
        });
        _submit();
      },
    );
  }
}
