import 'package:flutter/material.dart';

class PanicPulseScreen extends StatefulWidget {
  const PanicPulseScreen({super.key});

  @override
  State<PanicPulseScreen> createState() => _PanicPulseScreenState();
}

class _PanicPulseScreenState extends State<PanicPulseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Are you safe?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'If something doesn\'t feel right,\nwe\'re here to help.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
              ),
              
              const Spacer(),
              
              // Pulsing SOS Button
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rings
                      for (int i = 0; i < 3; i++)
                        Transform.scale(
                          scale: 1.0 + (_controller.value + i / 3.0) % 1.0 * 1.5,
                          child: Opacity(
                            opacity: 1.0 - (_controller.value + i / 3.0) % 1.0,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFEF4444), width: 2),
                              ),
                            ),
                          ),
                        ),
                      // Core Button
                      GestureDetector(
                        onTap: () {
                          // Real SOS Trigger
                          _triggerSOS();
                        },
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withAlpha(100),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                            gradient: const RadialGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'SOS',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tap to Alert',
                                  style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const Spacer(),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF141820),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withAlpha(5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What happens next?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    _buildStepRow(Icons.support_agent_rounded, 'Our support team will be notified immediately.'),
                    const SizedBox(height: 16),
                    _buildStepRow(Icons.location_on_rounded, 'Your location will be shared in real-time.'),
                    const SizedBox(height: 16),
                    _buildStepRow(Icons.group_rounded, 'Emergency contacts will be alerted.'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFEF4444), size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }

  void _triggerSOS() {
    // Show a confirmation/loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141820),
        title: const Text('SOS Alert Sent', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Emergency services and your contacts have been notified. Please stay calm and keep your phone close.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('I am Safe Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
