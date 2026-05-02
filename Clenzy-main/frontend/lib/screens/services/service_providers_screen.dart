import 'package:flutter/material.dart';
import 'booking_page.dart';
import '../profile/worker_profile_screen.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

class ServiceProvidersScreen extends StatefulWidget {
  final String categoryName;
  final IconData categoryIcon;

  const ServiceProvidersScreen({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
  });

  @override
  State<ServiceProvidersScreen> createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  final UserService _userService = UserService(AuthService());
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Individual', 'Agency', 'Top'];

  double _selectedDistance = 10.0;
  final List<double> _distanceOptions = [5, 10, 25, 50];

  final List<Map<String, dynamic>> _providers = [
    {
      'id': 1,
      'name': "John's Pro Plumbing",
      'type': 'individual',
      'rating': 4.9,
      'reviews': '120+',
      'price': 45,
      'isVerified': true,
      'distance': 2.5,
      'imageUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
    },
    {
      'id': 2,
      'name': 'Rapid Response',
      'type': 'agency',
      'rating': 4.8,
      'reviews': '350',
      'price': 65,
      'isVerified': true,
      'distance': 4.2,
      'imageUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    },
    {
      'id': 3,
      'name': 'Elite Pipe Fixers',
      'type': 'agency',
      'rating': 5.0,
      'reviews': '85',
      'price': 70,
      'isVerified': true,
      'distance': 8.0,
      'imageUrl': 'https://images.unsplash.com/photo-1581092921461-eab10ce8e6f3?w=150',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      await _userService.getFavoritePartners();
      // Ignoring favs mapping since favorites aren't locally stored anymore 
    } catch (e) {
      debugPrint('Failed to load favorites: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredProviders {
    return _providers.where((p) {
      if ((p['distance'] as double) > _selectedDistance) return false;
      if (_selectedFilter == 1) return p['type'] == 'individual';
      if (_selectedFilter == 2) return p['type'] == 'agency';
      if (_selectedFilter == 3) return (p['rating'] ?? 0) >= 4.9;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF030303) : const Color(0xFFFBFBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: isDark ? Colors.white70 : Colors.black87),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(isDark),
          Expanded(
            child: _filteredProviders.isEmpty
                ? const Center(child: Text('No providers found nearby'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    itemCount: _filteredProviders.length,
                    itemBuilder: (c, i) => _buildProviderCard(_filteredProviders[i], isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (c, i) {
          final isSelected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF0D0F14).withValues(alpha: 0.5) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE8ECF4)),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  _filters[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => WorkerProfileScreen(worker: provider)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141820) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withAlpha(20) : const Color(0xFFE8ECF4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'provider_avatar_${provider['id']}',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2563EB), width: 2),
                  image: DecorationImage(image: NetworkImage(provider['imageUrl']), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(provider['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      if (provider['isVerified']) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: Color(0xFF2563EB), size: 16),
                      ],
                    ],
                  ),
                  Text('${provider['rating']} • ${provider['reviews']} reviews',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${provider['distance']}km away',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${provider['price']}/h',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => BookingPage(provider: provider, categoryName: widget.categoryName))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('BOOK', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by Distance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _distanceOptions.map((d) => GestureDetector(
                onTap: () {
                  setState(() => _selectedDistance = d);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedDistance == d ? const Color(0xFF2563EB) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2563EB)),
                  ),
                  child: Text('${d.toInt()}km', style: TextStyle(fontWeight: FontWeight.w900, color: _selectedDistance == d ? Colors.white : const Color(0xFF2563EB))),
                ),
              )).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
