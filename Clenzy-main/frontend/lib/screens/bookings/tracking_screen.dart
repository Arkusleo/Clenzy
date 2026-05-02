import 'package:flutter/material.dart';

class TrackingScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const TrackingScreen({super.key, required this.job});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _getStepIndex(String status) {
    switch (status) {
      case 'searching':
        return 0;
      case 'accepted':
        return 1;
      case 'arrived':
        return 2;
      case 'started':
        return 3;
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }

  Widget _buildTimelineStep(
    String title,
    String subtitle,
    int stepIndex,
    int currentIndex,
  ) {
    final isCompleted = currentIndex >= stepIndex;
    final isActive = currentIndex == stepIndex;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey[300],
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(color: Colors.green.shade800, width: 2)
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            if (stepIndex < 4)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? Colors.black
                      : (isCompleted ? Colors.black87 : Colors.grey),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              if (stepIndex < 4) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1) Mock Map Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF3F4F6),
              // We simulate a map using an image or just a styled background.
              // Given no assets, we'll use a placeholder grey background indicating the map,
              // or a network map image.
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600&auto=format&fit=crop', // generic map-like aerial view placeholder
                      fit: BoxFit.cover,
                      color: Colors.white.withValues(alpha: 0.4),
                      colorBlendMode: BlendMode.screen,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2) Content overlay
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Titles
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Track your',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.0,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Expert, Live',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.0,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Expert Status Indicator & Bottom Card overlay
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Main White Card
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 60,
                                ), // Space for overlapping Pink Banner
                                // Expert Profile Row
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: const NetworkImage(
                                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Lata Patil',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.green,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '4.8',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.chat_bubble_outline,
                                        ),
                                        onPressed: () {},
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.phone_outlined),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Visual Job Timeline
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Job Progress',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTimelineStep(
                                      'Searching',
                                      'Looking for an expert',
                                      0,
                                      _getStepIndex(
                                        widget.job['status'] ?? 'searching',
                                      ),
                                    ),
                                    _buildTimelineStep(
                                      'Accepted',
                                      'Expert is on the way',
                                      1,
                                      _getStepIndex(
                                        widget.job['status'] ?? 'searching',
                                      ),
                                    ),
                                    _buildTimelineStep(
                                      'Arrived',
                                      'Expert reached your location',
                                      2,
                                      _getStepIndex(
                                        widget.job['status'] ?? 'searching',
                                      ),
                                    ),
                                    _buildTimelineStep(
                                      'Started',
                                      'Work in progress',
                                      3,
                                      _getStepIndex(
                                        widget.job['status'] ?? 'searching',
                                      ),
                                    ),
                                    _buildTimelineStep(
                                      'Completed',
                                      'Job finished',
                                      4,
                                      _getStepIndex(
                                        widget.job['status'] ?? 'searching',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Pink Tracking Banner Overlay
                          Positioned(
                            top: -10, // Slightly overlap top for effect
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 100, // Reduced from 120 to fix stretch
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63), // Pinkish red
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Status: ${widget.job['status']?.toString().toUpperCase()}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.job['description'] ??
                                              'Updates incoming.',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ETA Circle floating over banner
                          Positioned(
                            top: -40, // higher up relative to the card
                            right: 40,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 6,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ARRIVING IN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    '10',
                                    style: TextStyle(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                  Text(
                                    'MIN',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Footer text
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No guessing. ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              'No follow-ups.',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE91E63),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
