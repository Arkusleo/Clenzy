import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../services/live_service_screen.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../services/job_service_client.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedTab = 0; // 0 = Upcoming, 1 = Past
  final UserService _userService = UserService(AuthService());
  final JobServiceClient _jobServiceClient = JobServiceClient();

  @override
  void initState() {
    super.initState();
    _jobServiceClient.connectWebSocket();
  }

  @override
  void dispose() {
    _jobServiceClient.dispose();
    super.dispose();
  }

  // Premium Helper Functions
  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFF5A623); // Warning Gold
      case 'CONFIRMED':
      case 'ACCEPTED':
        return const Color(0xFF4A90E2); // Apple Blue
      case 'EN ROUTE':
      case 'IN_PROGRESS':
        return const Color(0xFF50E3C2); // Mint 
      case 'COMPLETED':
        return const Color(0xFF5A5A5C); // Premium Gray
      case 'CANCELLED':
        return const Color(0xFFFF3B30); // Apple Red
      default:
        return const Color(0xFF8E8E93);
    }
  }

  IconData _getIconForService(String? serviceType) {
    if (serviceType == null) return Icons.home_repair_service;
    final lower = serviceType.toLowerCase();
    if (lower.contains('plumb')) return Icons.plumbing;
    if (lower.contains('elect') || lower.contains('bolt')) return Icons.bolt;
    if (lower.contains('ac') || lower.contains('air')) return Icons.ac_unit;
    if (lower.contains('paint')) return Icons.format_paint;
    if (lower.contains('clean')) return Icons.cleaning_services;
    return Icons.build_circle_rounded;
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return 'ASAP';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('MMM d, h:mm a').format(dt);
    } catch (_) {
      return 'ASAP';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A), // Deep Apple OLED Black
      body: Stack(
        children: [
          // Subtle ambient glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3366FF).withAlpha(38),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF3366FF), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Bookings',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.tune_rounded,
                          color: Colors.white.withAlpha(150),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tab Bar
                FadeInDown(
                  duration: const Duration(milliseconds: 700),
                  child: _buildTabBar(true),
                ),
                const SizedBox(height: 8),

                // Jobs Stream List
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _jobServiceClient.getCustomerJobs(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white24));
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white54)));
                      }

                      final jobs = snapshot.data ?? [];

                      // Map standard jobs to front-end format
                      final formattedJobs = jobs.map((raw) {
                        final status =
                            (raw['status'] as String?)?.toUpperCase() ?? 'PENDING';
                        
                        final desc = raw['description'] as String? ?? '';
                        String workerName = raw['provider_id'] != null ? 'Assigned Pro' : 'Locating Pro...';
                        String dateTime = _formatDate(raw['created_at']);
                        if (desc.contains('SCHEDULED:')) {
                          try {
                            final parts = desc.split('|');
                            for (var part in parts) {
                              if (part.startsWith('SCHEDULED: ')) {
                                dateTime = part.substring('SCHEDULED: '.length);
                              }
                              if (part.startsWith('PROVIDER: ')) {
                                workerName = part.substring('PROVIDER: '.length);
                              }
                            }
                          } catch (_) {}
                        }

                        return {
                          ...raw,
                          'status': status,
                          'title': raw['service_type'] == null ||
                                  raw['service_type'].toString().isEmpty
                              ? 'Service Booking'
                              : raw['service_type'].toString().toUpperCase(),
                          'address': raw['address'] ?? 'Home',
                          'worker': workerName,
                          'statusColor': _getStatusColor(status).value,
                          'icon': _getIconForService(raw['service_type']),
                          'dateTime': dateTime,
                          'rating': raw['rating'],
                        };
                      }).toList();

                      // Filter logic
                      final upcomingJobs = formattedJobs
                          .where((j) =>
                              j['status'] != 'COMPLETED' &&
                              j['status'] != 'CANCELLED')
                          .toList();
                      final pastJobs = formattedJobs
                          .where((j) =>
                              j['status'] == 'COMPLETED' ||
                              j['status'] == 'CANCELLED')
                          .toList();

                      // Sort by newest
                      upcomingJobs.sort((a, b) => (b['created_at'] ?? '')
                          .toString()
                          .compareTo((a['created_at'] ?? '').toString()));
                      pastJobs.sort((a, b) => (b['created_at'] ?? '')
                          .toString()
                          .compareTo((a['created_at'] ?? '').toString()));

                      final displayList =
                          _selectedTab == 0 ? upcomingJobs : pastJobs;

                      if (displayList.isEmpty) {
                        return FadeInUp(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_rounded,
                                    color: Colors.white.withAlpha(40),
                                    size: 64),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedTab == 0
                                      ? 'No upcoming bookings'
                                      : 'No past history',
                                  style: TextStyle(
                                      color: Colors.white.withAlpha(120),
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        itemCount: displayList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: Duration(milliseconds: 100 * index),
                            child: _buildJobCard(displayList[index], true),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildTabBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0
                        ? Colors.white.withAlpha(25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Upcoming',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _selectedTab == 0 ? FontWeight.w600 : FontWeight.w500,
                      color: _selectedTab == 0 ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _selectedTab == 1
                        ? Colors.white.withAlpha(25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'History',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _selectedTab == 1 ? FontWeight.w600 : FontWeight.w500,
                      color: _selectedTab == 1 ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, bool isDark) {
    final bool isEnRoute = job['status'] == 'EN ROUTE' || job['status'] == 'IN_PROGRESS';
    final bool isCompleted = job['status'] == 'COMPLETED';

    return GestureDetector(
      onTap: () {
        if (isEnRoute) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LiveServiceScreen(job: job)),
          );
        } else {
          _showJobDetails(job, isDark);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withAlpha(20), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern Icon Box
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3366FF).withAlpha(40),
                          const Color(0xFF8A2BE2).withAlpha(40),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(30)),
                    ),
                    child: Icon(
                      job['icon'],
                      color: const Color(0xFFE2E8F0),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Row(
                      children: [
                        if (isEnRoute)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF50E3C2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          isEnRoute
                              ? 'LIVE • ${job['status']}'
                              : (isCompleted
                                    ? '${job['status']} • ${job['dateTime']}'
                                    : '${job['status']} • ${job['dateTime']}'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isEnRoute
                                ? const Color(0xFF50E3C2)
                                : Color(job['statusColor']),
                          ),
                        ),
                        if (isCompleted && job['rating'] != null) ...[
                          const Spacer(),
                          const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                          const SizedBox(width: 4),
                          Text(
                            job['rating'].toString(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      job['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Address and Worker
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: Colors.white.withAlpha(100)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            job['address'],
                            style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(150), fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_rounded, size: 14, color: Colors.white.withAlpha(100)),
                        const SizedBox(width: 6),
                        Text(
                          job['worker'],
                          style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(150), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    if (isCompleted && job['rating'] == null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _showReviewDialog(context, job),
                          icon: const Icon(
                            Icons.star_border,
                            size: 18,
                            color: Color(0xFF3366FF),
                          ),
                          label: const Text(
                            'Leave a Review',
                            style: TextStyle(color: Color(0xFF3366FF)),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            backgroundColor: const Color(
                              0xFF3366FF,
                            ).withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // More options
              Icon(Icons.more_horiz_rounded, color: Colors.white.withAlpha(80), size: 24),
            ],
          ),
        ),
        ),
      ),
    ),
  );
}

  void _showReviewDialog(BuildContext context, Map<String, dynamic> job) {
    int currentRating = 0;
    final TextEditingController commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Rate Your Expert'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('How was ${job['worker']}?'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < currentRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            currentRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Leave a comment (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: currentRating > 0 && !isSubmitting
                      ? () async {
                          setState(() => isSubmitting = true);
                          try {
                            // Using dummy IDs since mock data doesn't have real IDs
                            await _userService.submitReview(
                              job['id'] ?? '1',
                              job['provider_id'] ?? '2',
                              currentRating,
                              commentController.text,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Review submitted!'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                              setState(() => isSubmitting = false);
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3366FF),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showJobDetails(Map<String, dynamic> job, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1B22) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(job['icon'] ?? Icons.work, size: 32, color: const Color(0xFF3366FF)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    job['title'] ?? 'Service',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.calendar_today, 'Date & Time', job['dateTime'] ?? 'TBD', isDark),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.person, 'Provider', job['provider'] ?? 'Assigning', isDark),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.info_outline, 'Status', job['status'] ?? 'PENDING', isDark),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
