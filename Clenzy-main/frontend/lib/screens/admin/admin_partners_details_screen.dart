import 'package:flutter/material.dart';

class AdminPartnersDetailsScreen extends StatefulWidget {
  const AdminPartnersDetailsScreen({super.key});

  @override
  State<AdminPartnersDetailsScreen> createState() =>
      _AdminPartnersDetailsScreenState();
}

class _AdminPartnersDetailsScreenState
    extends State<AdminPartnersDetailsScreen> {
  final List<Map<String, dynamic>> _partners = [
    {
      "name": "Michael Roberts",
      "email": "m.roberts@pro.com",
      "profession": "Plumber",
      "rating": 4.8,
      "completedJobs": 142,
      "status": "Online",
      "isPending": false,
    },
    {
      "name": "Sarah Jenkins",
      "email": "sarah.clean@example.com",
      "profession": "Home Cleaner",
      "rating": 4.9,
      "completedJobs": 205,
      "status": "Offline",
      "isPending": false,
    },
    {
      "name": "David Wallace",
      "email": "dw.electric@example.com",
      "profession": "Electrician",
      "rating": 4.2,
      "completedJobs": 34,
      "status": "Online",
      "isPending": false,
    },
    {
      "name": "Emma Thompson",
      "email": "emma.t@example.com",
      "profession": "Pet Groomer",
      "rating": 0.0,
      "completedJobs": 0,
      "status": "Pending",
      "isPending": true,
    },
    {
      "name": "Robert Chen",
      "email": "chen.repairs@example.com",
      "profession": "Appliance Repair",
      "rating": 4.7,
      "completedJobs": 89,
      "status": "Offline",
      "isPending": false,
    },
  ];

  void _approvePartner(int index) {
    setState(() {
      _partners[index]["status"] = "Online";
      _partners[index]["isPending"] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partner Approved!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _disablePartner(int index) {
    setState(() {
      _partners[index]["status"] = "Disabled";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partner Disabled'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Total Partners',
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
      body: _partners.isEmpty
          ? const Center(child: Text('No partners found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _partners.length,
              itemBuilder: (context, index) {
                final partner = _partners[index];
                final isPending = partner['isPending'] as bool;
                final status = partner['status'];

                Color statusColor;
                if (status == 'Online') {
                  statusColor = const Color(0xFF4CAF50);
                } else if (status == 'Offline') {
                  statusColor = Colors.grey[600]!;
                } else if (status == 'Pending') {
                  statusColor = Colors.orange;
                } else {
                  statusColor = Colors.red;
                }

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8ECF4),
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://ui-avatars.com/api/?name=${partner['name'].replaceAll(' ', '+')}&background=E8ECF4&color=1A1D26',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partner['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1D26),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  partner['email'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.work_outline,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      partner['profession'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF3366FF),
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
                              color: statusColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFE8ECF4)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            Icons.star,
                            partner['rating'].toString(),
                            'Rating',
                            Colors.orange,
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: const Color(0xFFE8ECF4),
                          ),
                          _buildStatColumn(
                            Icons.task_alt,
                            partner['completedJobs'].toString(),
                            'Completed',
                            const Color(0xFF4CAF50),
                          ),
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
                                'View Profile',
                                style: TextStyle(color: Color(0xFF3366FF)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isPending)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _approvePartner(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Approve'),
                              ),
                            )
                          else
                            Expanded(
                              child: OutlinedButton(
                                onPressed: status == 'Disabled'
                                    ? null
                                    : () => _disablePartner(index),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: BorderSide(
                                    color: status == 'Disabled'
                                        ? Colors.grey
                                        : Colors.red,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  status == 'Disabled' ? 'Disabled' : 'Disable',
                                  style: TextStyle(
                                    color: status == 'Disabled'
                                        ? Colors.grey
                                        : Colors.red,
                                  ),
                                ),
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

  Widget _buildStatColumn(
    IconData icon,
    String value,
    String label,
    Color iconColor,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }
}
