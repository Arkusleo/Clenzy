import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, dynamic> addressData;
  const EditAddressScreen({super.key, required this.addressData});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late TextEditingController _labelController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late bool _isDefault;

  late final UserService _userService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userService = UserService(AuthService());
    _labelController = TextEditingController(
      text: widget.addressData['label'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.addressData['full_address'] ?? '',
    );
    _cityController = TextEditingController(
      text: widget.addressData['city'] ?? '',
    );
    _stateController = TextEditingController(
      text: widget.addressData['state'] ?? '',
    );
    _pincodeController = TextEditingController(
      text: widget.addressData['pincode'] ?? '',
    );
    _isDefault = widget.addressData['is_default'] ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress() async {
    if (_labelController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _userService.updateAddress(
        widget.addressData['id'],
        label: _labelController.text.trim(),
        fullAddress: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        isDefault: _isDefault,
      );
      if (mounted) {
        Navigator.pop(context, true); // Return true to trigger refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Edit Address',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(
              'Label (e.g., Home, Office)',
              _labelController,
              Icons.label_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Full Address',
              _addressController,
              Icons.location_on_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'City',
              _cityController,
              Icons.location_city_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'State',
                    _stateController,
                    Icons.map_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'Pincode',
                    _pincodeController,
                    Icons.pin_drop_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Set as Default Address'),
              value: _isDefault,
              onChanged: (val) => setState(() => _isDefault = val),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: const Color(0xFF3366FF),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
    );
  }
}
