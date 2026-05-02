import 'package:flutter/material.dart';
import 'dart:ui';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import 'admin_users_screen.dart';
import 'admin_approvals_screen.dart';
import 'widgets/admin_charts.dart';
import 'widgets/admin_lists.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const _AdminOverviewScreen(),
      const AdminUsersScreen(),
      const AdminApprovalsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14), // Deep dark bg
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        border: Border(
           right: BorderSide(color: Colors.white.withAlpha(15)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF3366FF), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'clenzy',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          // Nav items
          _buildNavItem(Icons.dashboard_rounded, 'Dashboard', 0),
          _buildNavItem(Icons.people_outline, 'Users', 1),
          _buildNavItem(Icons.verified_user_outlined, 'Approvals', 2),
          const Spacer(),
          // Admin Profile section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3366FF).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Color(0xFF3366FF), size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('admin@clenzy.com', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: GestureDetector(
              onTap: () async {
                  await AuthService().signOut();
                  // ignore: use_build_context_synchronously
                  if (!mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.white.withAlpha(150), size: 18),
                  const SizedBox(width: 8),
                  const Text('Log out', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3366FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOverviewScreen extends StatefulWidget {
  const _AdminOverviewScreen();

  @override
  State<_AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<_AdminOverviewScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _stats;
  List<dynamic>? _recentJobs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final stats = await _adminService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
    
    // Always attach mock list so dashboard populates while real integration happens
    if (mounted) {
      setState(() {
          _recentJobs = [
            {'id': '2451', 'service_type': 'Home Cleaning', 'created_at': 'May 28, 2024', 'status': 'completed'},
            {'id': '2450', 'service_type': 'Deep Cleaning', 'created_at': 'May 28, 2024', 'status': 'accepted'},
            {'id': '2449', 'service_type': 'Office Cleaning', 'created_at': 'May 27, 2024', 'status': 'pending'},
            {'id': '2448', 'service_type': 'Carpet Cleaning', 'created_at': 'May 27, 2024', 'status': 'completed'},
            {'id': '2447', 'service_type': 'Home Cleaning', 'created_at': 'May 26, 2024', 'status': 'accepted'},
          ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF3366FF)));
    }

    return Container(
      color: const Color(0xFF0D0F14), // Body background
      child: Stack(
         children: [
            // Ambient glows matching screenshot
            Positioned(
              left: -100, bottom: -100,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  width: 500, height: 500,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3366FF).withAlpha(20)),
                ),
              )
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildStatCardsRow(),
                  const SizedBox(height: 24),
                  // Row 1: Area Chart (flex 2) + Recent Bookings (flex 1)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        flex: 5,
                        child: SizedBox(
                           height: 380,
                           child: AdminBookingsChart()
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                           height: 380,
                           child: AdminRecentBookingsList(
                              recentJobs: _recentJobs,
                              onViewAll: () => _showAllBookingsModal(context),
                           )
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Row 2: Donut Chart | Top Services | Worker Performance
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                         flex: 3,
                         child: SizedBox(
                            height: 320,
                            child: AdminUsersDonutChart(
                               totalUsers: _stats?['total_users'] ?? 3672,
                               totalWorkers: _stats?['total_partners'] ?? 892,
                            )
                         ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                         flex: 4,
                         child: SizedBox(
                            height: 320,
                            child: AdminTopServicesList(
                               onViewAll: () => _showAllServicesModal(context),
                            )
                         ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                         flex: 4,
                         child: SizedBox(
                            height: 320,
                            child: AdminWorkerPerformanceList(
                               onViewAll: () => _showAllWorkersModal(context),
                            )
                         ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
         ],
      ),
    );
  }

  void _showAllBookingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
         height: MediaQuery.of(context).size.height * 0.85,
         padding: const EdgeInsets.all(24),
         decoration: BoxDecoration(
            color: const Color(0xFF131722),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withAlpha(20)),
         ),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     const Text('All Bookings History', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                     IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
                  ]
               ),
               const SizedBox(height: 24),
               Expanded(
                  // Reuse the widget but let it expand fully
                  child: AdminRecentBookingsList(recentJobs: _recentJobs)
               )
            ]
         )
      ),
    );
  }

  void _showAllServicesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
         height: MediaQuery.of(context).size.height * 0.85,
         padding: const EdgeInsets.all(24),
         decoration: BoxDecoration(
            color: const Color(0xFF131722),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withAlpha(20)),
         ),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     const Text('All Active Services Catalog', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                     IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
                  ]
               ),
               const SizedBox(height: 24),
               const Expanded(child: AdminTopServicesList())
            ]
         )
      ),
    );
  }

  void _showAllWorkersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
         height: MediaQuery.of(context).size.height * 0.85,
         padding: const EdgeInsets.all(24),
         decoration: BoxDecoration(
            color: const Color(0xFF131722),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withAlpha(20)),
         ),
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     const Text('Full Worker Directory', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                     IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
                  ]
               ),
               const SizedBox(height: 24),
               const Expanded(child: AdminWorkerPerformanceList())
            ]
         )
      ),
    );
  }

  String _searchTopic = '';

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Admin! 👋',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchTopic.isEmpty ? "Here's what's happening with Clenzy today." : "Showing results for topic: '$_searchTopic'",
              style: TextStyle(
                color: Colors.white.withAlpha(150),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
           children: [
              Container(
                 width: 300,
                 height: 44,
                 padding: const EdgeInsets.symmetric(horizontal: 16),
                 decoration: BoxDecoration(
                    color: const Color(0xFF131722),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withAlpha(15)),
                 ),
                 child: Row(
                    children: [
                       Icon(Icons.search, color: Colors.white.withAlpha(100), size: 20),
                       const SizedBox(width: 12),
                       Expanded(
                          child: TextField(
                             style: const TextStyle(color: Colors.white, fontSize: 14),
                             onSubmitted: (value) {
                                setState(() {
                                   _searchTopic = value;
                                });
                             },
                             decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(color: Colors.white.withAlpha(100), fontSize: 14),
                                border: InputBorder.none,
                             ),
                          ),
                       ),
                    ],
                 ),
              ),
              const SizedBox(width: 24),
              Stack(
                 children: [
                    Icon(Icons.notifications_none_rounded, color: Colors.white.withAlpha(200), size: 28),
                    Positioned(
                       right: 0, top: 0,
                       child: Container(
                          width: 14, height: 14,
                          decoration: const BoxDecoration(color: Color(0xFF3366FF), shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                       )
                    ),
                 ]
              ),
           ]
        ),
      ],
    );
  }

  Widget _buildStatCardsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Bookings', (_stats?['total_jobs'] ?? 1245).toString(), Icons.calendar_today_rounded, const Color(0xFF3366FF), 12.5)),
        const SizedBox(width: 24),
        Expanded(child: _buildStatCard('Total Users', (_stats?['total_users'] ?? 3672).toString(), Icons.person_rounded, const Color(0xFF3366FF), 8.3)),
        const SizedBox(width: 24),
        Expanded(child: _buildStatCard('Total Workers', (_stats?['total_partners'] ?? 892).toString(), Icons.work_outline_rounded, const Color(0xFF3366FF), 15.7)),
        const SizedBox(width: 24),
        Expanded(child: _buildStatCard('Total Revenue', '\$${(_stats?['total_revenue'] ?? 24500).toString()}', Icons.attach_money_rounded, const Color(0xFF3366FF), 20.1)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color mainColor, double percentIncrease) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: mainColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: mainColor.withAlpha(100), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 4),
                    Text('$percentIncrease%', style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    const Text('from last month', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
