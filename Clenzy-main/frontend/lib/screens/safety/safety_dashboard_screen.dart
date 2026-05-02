import 'package:flutter/material.dart';
import '../../widgets/hover_card.dart';
import 'panic_pulse_screen.dart';
import 'safety_chat_screen.dart';

class SafetyDashboardScreen extends StatelessWidget {
  const SafetyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SafetyChatScreen()),
          );
        },
        backgroundColor: const Color(0xFF3366FF),
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        label: const Text('Safety AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(
                'Safety Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your security is our top priority.',
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16),
              ),
              const SizedBox(height: 32),
              
              // Trust Score Widget 
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 86,
                          height: 86,
                          child: CircularProgressIndicator(
                            value: 0.98,
                            strokeWidth: 8,
                            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '98',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '/100',
                              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Trust Score',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Based on elite performance, reviews & safety compliance.',
                            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              Text(
                'Safety Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              
                  _buildSafetyFeatureCard(
                    context,
                    Icons.auto_awesome_rounded,
                    'AI Safety Assistant',
                    'Real-time guidance and instant help for any safety concerns.',
                    const Color(0xFF3366FF),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SafetyChatScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSafetyFeatureCard(
                    context,
                    Icons.verified_user_rounded,
                    'AI-Verified Pros',
                    'Every professional goes through rigorous identity and behavior checks.',
                    isDark ? const Color(0xFFBC9A5C) : const Color(0xFF1E293B), // Primary matching
                  ),
              const SizedBox(height: 16),
              _buildSafetyFeatureCard(
                context,
                Icons.qr_code_scanner_rounded,
                'SafeLink Check-In',
                'Verify your professional before they start the service.',
                isDark ? const Color(0xFFD4AF37) : const Color(0xFF334155),
              ),
              const SizedBox(height: 16),
              _buildSafetyFeatureCard(
                context,
                Icons.emergency_rounded,
                'Panic Button',
                'One tap alerts our executive team and your emergency contacts instantly.',
                const Color(0xFFEF4444),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PanicPulseScreen()),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color accentColor, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return HoverCard(
      onTap: onTap ?? () {
        _showFeatureDetails(context, title, description, accentColor);
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), height: 1.4),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          ],
        ),
      ),
    );
  }

  void _showFeatureDetails(BuildContext context, String title, String description, Color color) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          // Premium inset shadow effect alternative
          border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.1))),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(14),
                   decoration: BoxDecoration(
                     color: color.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: color.withValues(alpha: 0.2)),
                   ),
                   child: Icon(Icons.info_outline_rounded, color: color, size: 28),
                 ),
                 const SizedBox(width: 20),
                 Expanded(
                   child: Text(
                     title,
                     style: TextStyle(
                       fontSize: 24,
                       fontWeight: FontWeight.w800,
                       color: theme.colorScheme.onSurface,
                       letterSpacing: -0.5,
                     ),
                   ),
                 ),
               ],
            ),
            const SizedBox(height: 32),
            Text(
              description,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 32),
            Text(
              'Detailed Protocol',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Our safety protocols are integrated deeply into our ultra-premium service. We utilize high-fidelity GPS tracking, biometric secure login validation, and autonomous AI-driven background risk assessments to ensure your sanctuary remains uncompromised.',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.brightness == Brightness.dark ? const Color(0xFF111827) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Acknowledge',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
