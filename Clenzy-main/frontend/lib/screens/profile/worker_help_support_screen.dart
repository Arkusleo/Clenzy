import 'package:flutter/material.dart';

class WorkerHelpSupportScreen extends StatelessWidget {
  const WorkerHelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Help & Support',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // How can we help widget
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3366FF), Color(0xFF2952CC)],
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can we help\nyou today?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Browse FAQs, raise a ticket or contact our support team directly.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildContactAction(
                    icon: Icons.chat_bubble_outline,
                    title: 'Live Chat',
                    subtitle: 'Usually responds\nin 5 mins',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starting Live Chat...')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildContactAction(
                    icon: Icons.mail_outline,
                    title: 'Email',
                    subtitle: 'Usually responds\nin 24 hours',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening Mail client...')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // FAQs
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECF4)),
              ),
              child: Column(
                children: [
                  _buildFaqItem('How do I receive payments?'),
                  const Divider(height: 1, color: Color(0xFFE8ECF4)),
                  _buildFaqItem('What if a customer cancels?'),
                  const Divider(height: 1, color: Color(0xFFE8ECF4)),
                  _buildFaqItem('How do I update my service areas?'),
                  const Divider(height: 1, color: Color(0xFFE8ECF4)),
                  _buildFaqItem('How are ratings calculated?'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Raise a ticket button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ticket Raised successfully. We will contact you.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Raise a Support Ticket'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: const Color(0xFF3366FF),
                  side: const BorderSide(color: Color(0xFF3366FF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8ECF4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3366FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF3366FF), size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D26),
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        iconColor: const Color(0xFF3366FF),
        collapsedIconColor: Colors.grey[400],
        children: const [
          Text(
            'This is a sample answer to the frequently asked question. It provides helpful context and instructions for the user regarding platform policies.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5568),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
