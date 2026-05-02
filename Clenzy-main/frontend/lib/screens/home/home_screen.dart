import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/hover_card.dart';
import '../services/service_providers_screen.dart';
import '../services/all_services_screen.dart';
import '../safety/safety_dashboard_screen.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService(AuthService());
  String _userName = 'Arjun';
  final String _location = 'Kochi';
  final String _temp = '28°C';
  final IconData _weatherIcon = Icons.wb_sunny_rounded;
  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = _categories;
    _loadUserProfile();
  }

  void _onSearchChanged(String query) {
    if (mounted) {
      setState(() {
        if (query.isEmpty) {
          _filteredCategories = _categories;
        } else {
          _filteredCategories = _categories
              .where((cat) => (cat['name'] as String).toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      });
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userService.getUserProfile();
      if (mounted) {
        setState(() {
          _userName = profile['full_name'] ?? 'Guest';
        });
      }
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
    }
  }

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Cleaning', 'icon': Icons.cleaning_services_rounded},
    {'name': 'Plumbing', 'icon': Icons.plumbing_rounded},
    {'name': 'Electrical', 'icon': Icons.electrical_services_rounded},
    {'name': 'Appliance', 'icon': Icons.router_rounded},
    {'name': 'Pest Control', 'icon': Icons.bug_report_rounded},
    {'name': 'Painting', 'icon': Icons.format_paint_rounded},
    {'name': 'Carpentry', 'icon': Icons.construction_rounded},
    {'name': 'More', 'icon': Icons.grid_view_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Elegant Background Glow
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.05),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.05),
                    blurRadius: 120,
                    spreadRadius: 60,
                  )
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const SizedBox(height: 24),
                  // Header Block
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: _buildHeader(),
                  ),
                  const SizedBox(height: 32),
                  
                  // Search Bar
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 40),
                  
                  // Service Grid
                  _buildServiceGrid(),
                  const SizedBox(height: 40),
                  
                  // Safety Status Widget
                  FadeInRight(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 300),
                    child: _buildSafetyStatusWidget(),
                  ),
                  const SizedBox(height: 32),
                  
                  // Trust Highlight
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 400),
                    child: _buildTrustHighlight(),
                  ),
                  const SizedBox(height: 32),
                  
                  // Promotional Banner
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 500),
                    child: _buildPromoBanner(),
                  ),
                  const SizedBox(height: 40),
                  
                  // Popular Services
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 600),
                    child: _buildPopularServicesHeader(),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 700),
                    child: _buildPopularServicesList(),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustHighlight() {
    final theme = Theme.of(context);
    return Container(
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
          SizedBox(
            width: 100,
            height: 36,
            child: Stack(
              children: [
                for (int i = 0; i < 4; i++)
                  Positioned(
                    left: i * 22.0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.cardTheme.color!, width: 2),
                        image: DecorationImage(
                          image: NetworkImage('https://i.pravatar.cc/100?u=user$i'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '10,000+ Verified Users',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Trust Clenzy for their home safety.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFFBC9A5C), const Color(0xFF8B6B32)] 
            : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.shield_rounded, size: 240, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Clean Home,\nPeace of Mind',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isDark ? const Color(0xFF8B6B32) : const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Good morning,\n$_userName',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'How can we help today?',
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        ),
        Row(
          children: [
             // Weather Widget
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(_weatherIcon, color: theme.colorScheme.secondary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _temp,
                        style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    _location,
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), width: 1.5),
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?u=arjun'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
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
          Icon(Icons.search_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search for a luxury service',
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(Icons.tune_rounded, color: theme.colorScheme.primary, size: 24),
        ],
      ),
    );
  }

  Widget _buildServiceGrid() {
    final theme = Theme.of(context);
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 100,
        mainAxisSpacing: 24,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        final cat = _filteredCategories[index];
        final isMore = cat['name'] == 'More';
        
        return FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: Duration(milliseconds: 80 * index),
          child: Column(
            children: [
              HoverCard(
                onTap: () {
                  if (isMore) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllServicesScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceProvidersScreen(
                          categoryName: cat['name'],
                          categoryIcon: cat['icon'],
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isMore ? Colors.transparent : theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMore 
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.05)
                    ),
                    boxShadow: isMore ? [] : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    cat['icon'], 
                    color: isMore ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : theme.colorScheme.primary, 
                    size: 26
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                cat['name'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSafetyStatusWidget() {
    final theme = Theme.of(context);
    return HoverCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SafetyDashboardScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Safety Status',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All professionals are AI-verified & background checked.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Glowing Shield Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 0),
                ],
              ),
              child: Icon(Icons.shield_rounded, color: theme.colorScheme.primary, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularServicesHeader() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Popular Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'View all',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPopularServicesList() {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> popular = [
      {
        'title': 'Premium Cleaning',
        'price': 'From \$49',
        'image': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400&auto=format&fit=crop',
      },
      {
        'title': 'Luxury Spa & Salon',
        'price': 'From \$89',
        'image': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=400&auto=format&fit=crop',
      },
    ];

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: popular.length,
        itemBuilder: (context, index) {
          final item = popular[index];
          return HoverCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceProvidersScreen(
                    categoryName: item['title'],
                    categoryIcon: item['title'].contains('Cleaning') ? Icons.cleaning_services_rounded : Icons.spa_rounded,
                  ),
                ),
              );
            },
            child: Container(
              width: 260,
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: Stack(
                      children: [
                        Image.network(
                          item['image'],
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const Positioned(
                          top: 12,
                          right: 12,
                          child: Icon(Icons.favorite_outline_rounded, color: Colors.white, size: 24),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: theme.colorScheme.secondary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '4.9',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              item['price'],
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
