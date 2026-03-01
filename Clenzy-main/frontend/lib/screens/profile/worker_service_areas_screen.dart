import 'package:flutter/material.dart';
import '../../models/partner_profile_data.dart';

class WorkerServiceAreasScreen extends StatefulWidget {
  const WorkerServiceAreasScreen({super.key});

  @override
  State<WorkerServiceAreasScreen> createState() =>
      _WorkerServiceAreasScreenState();
}

class _WorkerServiceAreasScreenState extends State<WorkerServiceAreasScreen> {
  List<String> _serviceAreas = [];

  @override
  void initState() {
    super.initState();
    _serviceAreas = List.from(PartnerProfileData.instance.serviceAreas);
    if (_serviceAreas.isEmpty) {
      _serviceAreas = ['San Francisco', 'Oakland', 'Berkeley', 'Palo Alto'];
    }
  }

  final _newAreaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newAreaController.dispose();
    super.dispose();
  }

  void _addArea() {
    final area = _newAreaController.text.trim();
    if (area.isNotEmpty && !_serviceAreas.contains(area)) {
      setState(() {
        _serviceAreas.add(area);
        _newAreaController.clear();
      });
    }
  }

  void _saveAreas() async {
    setState(() => _isLoading = true);

    // Simulate API save
    await Future.delayed(const Duration(seconds: 1));

    PartnerProfileData.instance.serviceAreas = List.from(_serviceAreas);

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Service areas updated successfully'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Service Areas',
          style: TextStyle(
            color: Color(0xFF1A1D26),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1D26)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Areas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add cities, neighborhoods, or pin codes where you provide services.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newAreaController,
                    decoration: InputDecoration(
                      hintText: 'e.g., San Jose',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3366FF),
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.location_city_outlined),
                    ),
                    onSubmitted: (_) => _addArea(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3366FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _addArea,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: _serviceAreas.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3366FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF3366FF),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      _serviceAreas[index],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1D26),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          _serviceAreas.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveAreas,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3366FF),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Areas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
