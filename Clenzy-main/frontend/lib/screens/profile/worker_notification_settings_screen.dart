import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerNotificationSettingsScreen extends StatefulWidget {
  const WorkerNotificationSettingsScreen({super.key});

  @override
  State<WorkerNotificationSettingsScreen> createState() =>
      _WorkerNotificationSettingsScreenState();
}

class _WorkerNotificationSettingsScreenState
    extends State<WorkerNotificationSettingsScreen> {
  bool _jobRequests = true;
  bool _messages = true;
  bool _payments = true;
  bool _promotions = false;
  bool _appUpdates = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jobRequests = prefs.getBool('notif_job_requests') ?? true;
      _messages = prefs.getBool('notif_messages') ?? true;
      _payments = prefs.getBool('notif_payments') ?? true;
      _promotions = prefs.getBool('notif_promotions') ?? false;
      _appUpdates = prefs.getBool('notif_app_updates') ?? true;
    });
  }

  void _saveSettings() async {
    setState(() => _isLoading = true);

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_job_requests', _jobRequests);
    await prefs.setBool('notif_messages', _messages);
    await prefs.setBool('notif_payments', _payments);
    await prefs.setBool('notif_promotions', _promotions);
    await prefs.setBool('notif_app_updates', _appUpdates);

    // Simulate API save
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification preferences saved'),
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
          'Notifications',
          style: TextStyle(
            color: Color(0xFF1A1D26),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1D26)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Push Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 16),
            _buildToggleItem(
              'New Job Requests',
              'Get notified when customers request your services',
              _jobRequests,
              (val) => setState(() => _jobRequests = val),
            ),
            _buildToggleItem(
              'New Messages',
              'Receive alerts for new chat messages from customers',
              _messages,
              (val) => setState(() => _messages = val),
            ),
            _buildToggleItem(
              'Payment Updates',
              'Notifications about successful payouts and earnings',
              _payments,
              (val) => setState(() => _payments = val),
            ),

            const SizedBox(height: 32),
            const Text(
              'General Updates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 16),
            _buildToggleItem(
              'Promotional Offers',
              'Receive marketing and promotional content',
              _promotions,
              (val) => setState(() => _promotions = val),
            ),
            _buildToggleItem(
              'App Updates',
              'Get notified about new features and improvements',
              _appUpdates,
              (val) => setState(() => _appUpdates = val),
              showDivider: false,
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
          onPressed: _isLoading ? null : _saveSettings,
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
                  'Save Preferences',
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

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1D26),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF3366FF),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey[300],
              ),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFE8ECF4), height: 1),
          ),
      ],
    );
  }
}
