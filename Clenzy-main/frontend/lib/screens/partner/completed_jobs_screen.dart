import 'package:flutter/material.dart';

class CompletedJobsScreen extends StatelessWidget {
  const CompletedJobsScreen({super.key});

  final List<Map<String, dynamic>> _completedJobs = const [
    {
      "title": "AC Repair",
      "ticket": "FX-1021",
      "completedAt": "Feb 28, 10:30 AM",
      "customer": "John Doe",
      "amount": 85.00,
      "address": "123 South St, Springfield",
      "timeSlot": "10:00 AM - 11:30 AM",
      "notes": "Replaced the capacitor and refilled freon.",
    },
    {
      "title": "Kitchen Leak Fix",
      "ticket": "FX-1034",
      "completedAt": "Feb 27, 01:00 PM",
      "customer": "Sarah Smith",
      "amount": 65.00,
      "address": "456 North Ave, Springfield",
      "timeSlot": "12:00 PM - 01:30 PM",
      "notes": "Fixed the leaking pipe under the sink.",
    },
    {
      "title": "Electrical Inspection",
      "ticket": "FX-1102",
      "completedAt": "Feb 26, 03:30 PM",
      "customer": "Mark James",
      "amount": 120.00,
      "address": "789 East Blvd, Springfield",
      "timeSlot": "02:00 PM - 04:00 PM",
      "notes": "Inspected main panel and replaced two breakers.",
    },
    {
      "title": "Furniture Assembly",
      "ticket": "FX-1188",
      "completedAt": "Feb 25, 11:45 AM",
      "customer": "Lisa Brown",
      "amount": 40.00,
      "address": "321 West Pkwy, Springfield",
      "timeSlot": "10:00 AM - 12:00 PM",
      "notes": "Assembled IKEA wardrobe.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Completed Jobs',
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _completedJobs.length,
        itemBuilder: (context, index) {
          final job = _completedJobs[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/completedJobDetails',
                arguments: job,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8ECF4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        job['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D26),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ticket: ${job['ticket']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job['customer'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        '\$${job['amount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3366FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE8ECF4)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job['completedAt'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
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
