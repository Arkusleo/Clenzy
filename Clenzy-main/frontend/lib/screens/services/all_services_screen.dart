import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'service_providers_screen.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  final List<Map<String, dynamic>> _featuredServices = const [
    {
      'title': 'Cleaning',
      'desc': 'Deep cleaning, sofa cleaning, kitchen cleaning & more.',
      'icon': Icons.cleaning_services_rounded,
      'color': Color(0xFFEBF2FF),
      'iconColor': Color(0xFF3366FF),
    },
    {
      'title': 'Plumbing',
      'desc': 'Leak fixing, pipe installation, bathroom fittings & more.',
      'icon': Icons.plumbing_rounded,
      'color': Color(0xFFE0F7FA),
      'iconColor': Color(0xFF0097A7),
    },
    {
      'title': 'Electrical',
      'desc': 'Wiring, fan installation, switch repair & more.',
      'icon': Icons.electrical_services_rounded,
      'color': Color(0xFFFFF3E0),
      'iconColor': Color(0xFFF57C00),
    },
    {
      'title': 'Appliance',
      'desc': 'AC, fridge, washing machine repair & maintenance.',
      'icon': Icons.tv_rounded,
      'color': Color(0xFFF3E5F5),
      'iconColor': Color(0xFF7B1FA2),
    },
    {
      'title': 'Pest Control',
      'desc': 'Safe and effective solutions for pest-free spaces.',
      'icon': Icons.bug_report_rounded,
      'color': Color(0xFFFCE4EC),
      'iconColor': Color(0xFFC2185B),
    },
    {
      'title': 'Painting',
      'desc': 'Interior & exterior painting with perfect finishing.',
      'icon': Icons.format_paint_rounded,
      'color': Color(0xFFE1F5FE),
      'iconColor': Color(0xFF0288D1),
    },
    {
      'title': 'Carpentry',
      'desc': 'Custom furniture, repairs, and woodwork.',
      'icon': Icons.construction_rounded,
      'color': Color(0xFFFFF3E0),
      'iconColor': Color(0xFFE64A19),
    },
    {
      'title': 'And More',
      'desc': 'Many other services to keep your home perfect.',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFFF5F5F5),
      'iconColor': Color(0xFF616161),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030303) : const Color(0xFFFBFBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
            color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'All Services, One Trusted Place',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        letterSpacing: -1,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explore our complete range of home services designed to make your life easier.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _featuredServices.length,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: Duration(milliseconds: 100 * index),
                    child: _ServiceFeatureCard(
                      service: _featuredServices[index],
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 800),
              child: _buildHelpBanner(context, isDark),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpBanner(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1424) : const Color(0xFFEBF2FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3366FF).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.05 : 1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: Color(0xFF3366FF), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Book a service in minutes and relax while we take care of the rest.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E3A59),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Book a Service', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceFeatureCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isDark;

  const _ServiceFeatureCard({required this.service, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceProvidersScreen(
              categoryName: service['title'] as String,
              categoryIcon: service['icon'] as IconData,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D0F14).withValues(alpha: 0.5) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE8ECF4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (service['color'] as Color).withValues(alpha: isDark ? 0.1 : 1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                service['icon'] as IconData, 
                color: service['iconColor'] as Color, 
                size: 26
              ),
            ),
            const SizedBox(height: 16),
            Text(
              service['title'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                service['desc'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Learn more',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3366FF),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, color: Color(0xFF3366FF), size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
