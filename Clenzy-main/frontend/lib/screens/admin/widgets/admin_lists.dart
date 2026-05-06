import 'package:flutter/material.dart';

class ThemeColors {
  static const Color darkCard = Color(0xFF131722);
  static const Color primaryBlue = Color(0xFF3366FF);
  static const Color borderWhite = Colors.white12;
}

class AdminRecentBookingsList extends StatelessWidget {
  final List<dynamic>? recentJobs;
  final VoidCallback? onViewAll;

  const AdminRecentBookingsList({super.key, this.recentJobs, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeColors.borderWhite),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Bookings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(color: ThemeColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
             child: (recentJobs == null || recentJobs!.isEmpty)
               ? const Center(child: Text('No bookings available', style: TextStyle(color: Colors.white54)))
               : ListView.separated(
                  itemCount: '${recentJobs!.length}' == '0' ? 0 : (recentJobs!.length > 4 ? 4 : recentJobs!.length),
                  separatorBuilder: (context, index) => Divider(color: Colors.white.withAlpha(10), height: 24),
                  itemBuilder: (context, index) {
                    final job = recentJobs![index];
                    final serviceType = job['service_type'] ?? 'Service';
                    final dateStr = job['created_at'] != null ? job['created_at'].toString().split('T')[0] : 'May 28, 2024';
                    final status = job['status'] ?? 'pending';

                    Color statusColor;
                    String statusText;
                    
                    if (status == 'completed') {
                      statusColor = const Color(0xFF10B981);
                      statusText = 'Completed';
                    } else if (status == 'accepted' || status == 'arrived' || status == 'started') {
                      statusColor = const Color(0xFF3366FF);
                      statusText = 'Confirmed';
                    } else {
                      statusColor = const Color(0xFFF5A623);
                      statusText = 'Pending';
                    }

                    return Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withAlpha(10),
                          radius: 18,
                          child: const Icon(Icons.person, size: 18, color: Colors.white70),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#BK-${job['id']}',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                serviceType,
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            dateStr,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: 80,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            border: Border.all(color: statusColor.withAlpha(50)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    );
                  },
               ),
          ),
        ],
      ),
    );
  }
}

class AdminTopServicesList extends StatelessWidget {
  final VoidCallback? onViewAll;
  const AdminTopServicesList({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeColors.borderWhite),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(color: ThemeColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildItem(Icons.home_outlined, 'Home Cleaning', '1,245 Bookings', 40, Color(0xFF3366FF)),
          const SizedBox(height: 20),
          _buildItem(Icons.cleaning_services_outlined, 'Deep Cleaning', '892 Bookings', 28, Color(0xFF3366FF)),
          const SizedBox(height: 20),
          _buildItem(Icons.business_outlined, 'Office Cleaning', '623 Bookings', 20, Color(0xFF3366FF)),
          const SizedBox(height: 20),
          _buildItem(Icons.layers_outlined, 'Carpet Cleaning', '312 Bookings', 10, Color(0xFF3366FF)),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, String subtitle, double percent, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
        SizedBox(
          width: 80,
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    backgroundColor: Colors.white.withAlpha(10),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '${percent.toInt()}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class AdminWorkerPerformanceList extends StatelessWidget {
  final VoidCallback? onViewAll;
  const AdminWorkerPerformanceList({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeColors.borderWhite),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Worker Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(color: ThemeColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildWorkerItem('James Smith', '128 Jobs', 4.9, 98),
          const SizedBox(height: 20),
          _buildWorkerItem('Sarah Lee', '96 Jobs', 4.8, 95),
          const SizedBox(height: 20),
          _buildWorkerItem('Michael Brown', '112 Jobs', 4.7, 92),
        ],
      ),
    );
  }

  Widget _buildWorkerItem(String name, String subtitle, double rating, int completionPerc) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withAlpha(20),
          radius: 18,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(rating.toString(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.white70, size: 14),
            ],
          ),
        ),
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withAlpha(15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$completionPerc%',
            style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class AdminRecentUsersList extends StatelessWidget {
  final VoidCallback? onViewAll;
  const AdminRecentUsersList({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeColors.borderWhite),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Users',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: const Text(
                  'View All',
                  style: TextStyle(color: ThemeColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildUserItem('Alice Johnson', 'alice.j@example.com', 'Customer'),
          const SizedBox(height: 20),
          _buildUserItem('Bob Williams', 'bob.w@example.com', 'Worker'),
          const SizedBox(height: 20),
          _buildUserItem('Charlie Brown', 'charlie.b@example.com', 'Customer'),
          const SizedBox(height: 20),
          _buildUserItem('Diana Prince', 'diana.p@example.com', 'Customer'),
        ],
      ),
    );
  }

  Widget _buildUserItem(String name, String email, String role) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withAlpha(20),
          radius: 18,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(email, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: role.toLowerCase() == 'worker' 
                ? const Color(0xFF10B981).withAlpha(20)
                : const Color(0xFF3366FF).withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            role,
            style: TextStyle(
              color: role.toLowerCase() == 'worker' ? const Color(0xFF10B981) : const Color(0xFF3366FF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
