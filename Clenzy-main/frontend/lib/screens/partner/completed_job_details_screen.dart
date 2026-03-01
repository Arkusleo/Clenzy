import 'package:flutter/material.dart';

class CompletedJobDetailsScreen extends StatelessWidget {
  const CompletedJobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve argument data passed from CompletedJobsScreen
    final job =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No job data provided.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Completed Job Details',
          style: TextStyle(
            color: Color(0xFF1A1D26),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1D26)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECF4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['title'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1D26),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ticket ID: ${job['ticket']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
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
                          color: const Color(0xFF4CAF50).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'COMPLETED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE8ECF4)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Earned',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1D26),
                        ),
                      ),
                      Text(
                        '\$${job['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3366FF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Details List
            const Text(
              'Job Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECF4)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.person_outline,
                    "Customer Name",
                    job['customer'],
                  ),
                  const Divider(height: 1, color: Color(0xFFE8ECF4)),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    "Address",
                    job['address'],
                  ),
                  const Divider(height: 1, color: Color(0xFFE8ECF4)),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    "Time Completed",
                    job['completedAt'],
                  ),
                  const Divider(height: 1, color: Color(0xFFE8ECF4)),
                  _buildDetailRow(
                    Icons.access_time_outlined,
                    "Scheduled Slot",
                    job['timeSlot'],
                  ),
                ],
              ),
            ),
            if (job['notes'] != null && job['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Job Notes / Instructions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D26),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8ECF4)),
                ),
                child: Text(
                  job['notes'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1D26),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
