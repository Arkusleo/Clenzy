import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

class FavoritePartnersScreen extends StatefulWidget {
  const FavoritePartnersScreen({super.key});

  @override
  State<FavoritePartnersScreen> createState() => _FavoritePartnersScreenState();
}

class _FavoritePartnersScreenState extends State<FavoritePartnersScreen> {
  final UserService _userService = UserService(AuthService());
  List<dynamic> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final favs = await _userService.getFavoritePartners();
      setState(() => _favorites = favs);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(String id) async {
    try {
      await _userService.removeFavoritePartner(id);
      _loadFavorites(); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Saved Providers',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_favorites.isEmpty) {
      return const Center(child: Text('No saved providers yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final partner = _favorites[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(partner['full_name']?[0] ?? 'P'),
            ),
            title: Text(
              partner['full_name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(partner['email'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _removeFavorite(partner['id']),
            ),
          ),
        );
      },
    );
  }
}
