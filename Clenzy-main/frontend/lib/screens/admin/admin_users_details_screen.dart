import 'package:flutter/material.dart';

class UsersDetailsScreen extends StatefulWidget {
  const UsersDetailsScreen({super.key});

  @override
  State<UsersDetailsScreen> createState() => _UsersDetailsScreenState();
}

class _UsersDetailsScreenState extends State<UsersDetailsScreen> {
  final List<Map<String, dynamic>> _users = [
    {
      "name": "Alex Johnson",
      "email": "alex.j@example.com",
      "role": "User",
      "status": "Active",
      "lastLogin": "2 hours ago",
    },
    {
      "name": "Maria Garcia",
      "email": "m.garcia@example.com",
      "role": "Worker",
      "status": "Active",
      "lastLogin": "1 day ago",
    },
    {
      "name": "David Smith",
      "email": "david.s@example.com",
      "role": "Admin",
      "status": "Active",
      "lastLogin": "Just now",
    },
    {
      "name": "Sarah Lee",
      "email": "sarah.l@example.com",
      "role": "User",
      "status": "Disabled",
      "lastLogin": "1 month ago",
    },
  ];

  void _toggleUserStatus(int index) {
    setState(() {
      final currentStatus = _users[index]["status"];
      _users[index]["status"] = currentStatus == "Active"
          ? "Disabled"
          : "Active";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User status updated to ${_users[index]["status"]}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteUser(int index) {
    final name = _users[index]["name"];
    setState(() {
      _users.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User $name deleted successfully'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Total Users',
          style: TextStyle(
            color: Color(0xFF1A1D26),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF1A1D26)),
      ),
      body: _users.isEmpty
          ? const Center(child: Text('No users found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isActive = user['status'] == 'Active';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1D26),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      user['email'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF4CAF50).withAlpha(26)
                                  : Colors.red.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user['status'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? const Color(0xFF4CAF50)
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFE8ECF4)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoChip(Icons.badge_outlined, user['role']),
                          _buildInfoChip(Icons.access_time, user['lastLogin']),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // View Profile
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF3366FF),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(color: Color(0xFF3366FF)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _toggleUserStatus(index),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(
                                  color: isActive
                                      ? Colors.orange
                                      : const Color(0xFF4CAF50),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isActive ? 'Disable' : 'Enable',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.orange
                                      : const Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _deleteUser(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withAlpha(26),
                                foregroundColor: Colors.red,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
