import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerAboutScreen extends StatelessWidget {
  const WorkerAboutScreen({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch \$url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'About',
          style: TextStyle(
            color: Color(0xFF1A1D26),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1D26)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A7DFF), Color(0xFF3366FF)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3366FF).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.build_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            // App Name & Version
            const Text(
              'Clenzy Partner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECF4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Version 1.0.0 (Build 3)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Links Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECF4)),
              ),
              child: Column(
                children: [
                  _buildLinkRow(
                    context,
                    Icons.star_outline_rounded,
                    'Rate App on Store',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFE8ECF4)),
                  _buildLinkRow(
                    context,
                    Icons.security_rounded,
                    'Privacy Policy',
                    onTap: () => _launchURL('https://example.com/privacy'),
                  ),
                  const Divider(height: 1, color: Color(0xFFE8ECF4)),
                  _buildLinkRow(
                    context,
                    Icons.library_books_outlined,
                    'Terms of Service',
                    onTap: () => _launchURL('https://example.com/terms'),
                  ),
                  const Divider(height: 1, color: Color(0xFFE8ECF4)),
                  _buildLinkRow(
                    context,
                    Icons.code_rounded,
                    'Open Source Licenses',
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'Clenzy Partner',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(
                          Icons.build_rounded,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Copyright
            Text(
              '© ${DateTime.now().year} Clenzy Inc.\nAll rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkRow(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1D26),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
