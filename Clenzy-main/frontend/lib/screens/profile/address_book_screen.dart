import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import 'add_address_screen.dart';
import 'edit_address_screen.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  late final UserService _userService;
  List<dynamic> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userService = UserService(AuthService());
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final addresses = await _userService.getAddresses();
      setState(() {
        _addresses = addresses;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load addresses: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAddress(String id) async {
    try {
      await _userService.deleteAddress(id);
      _loadAddresses(); // Refresh list after successful delete
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete address: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setAsDefault(String id) async {
    try {
      await _userService.updateAddress(id, isDefault: true);
      _loadAddresses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update address: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getIconForLabel(String label) {
    if (label.toLowerCase() == 'home') return Icons.home_outlined;
    if (label.toLowerCase() == 'office') return Icons.work_outline;
    return Icons.location_on_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Address Book',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _addresses.length + 1,
              itemBuilder: (context, index) {
                if (index == _addresses.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddAddressScreen(),
                          ),
                        );
                        if (result == true) _loadAddresses();
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add New Address',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3366FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }

                final addr = _addresses[index];
                return _buildAddressCard(addr);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, color: Colors.grey[400], size: 64),
          const SizedBox(height: 16),
          const Text(
            'No addresses found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAddressScreen()),
              );
              if (result == true) _loadAddresses();
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add New Address',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3366FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final bool isDefault = address['is_default'] ?? false;
    final String id = address['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDefault
              ? const Color(0xFF3366FF)
              : Colors.grey.withValues(alpha: 0.2),
          width: isDefault ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconForLabel(address['label'] ?? ''),
                  color: const Color(0xFF3366FF),
                ),
                const SizedBox(width: 8),
                Text(
                  address['label'] ?? 'Address',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3366FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        color: Color(0xFF3366FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditAddressScreen(addressData: address),
                        ),
                      );
                      if (result == true) _loadAddresses();
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(id);
                    } else if (value == 'default') {
                      _setAsDefault(id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (!isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Text('Set as Default'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address['full_address'] ?? '',
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),
            if (address['city'] != null)
              Text(
                '${address['city']}, ${address['state']} ${address['pincode'] ?? ''}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
