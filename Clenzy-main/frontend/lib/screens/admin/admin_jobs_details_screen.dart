import 'package:flutter/material.dart';

class AdminJobsDetailsScreen extends StatefulWidget {
  const AdminJobsDetailsScreen({super.key});

  @override
  State<AdminJobsDetailsScreen> createState() => _AdminJobsDetailsScreenState();
}

class _AdminJobsDetailsScreenState extends State<AdminJobsDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _allJobs = [
    {
      "service": "AC Repair",
      "ticket": "FX-1021",
      "worker": "Michael Roberts",
      "customer": "John Doe",
      "address": "123 South St, Springfield",
      "time": "Feb 28, 10:30 AM",
      "price": 85.00,
      "status": "Completed",
    },
    {
      "service": "House Cleaning",
      "ticket": "FX-1022",
      "worker": "Sarah Jenkins",
      "customer": "Emily Chen",
      "address": "45 North Ave, Springfield",
      "time": "Today, 02:00 PM",
      "price": 120.00,
      "status": "Active",
    },
    {
      "service": "Plumbing Inspection",
      "ticket": "FX-1023",
      "worker": "Unassigned",
      "customer": "Robert Smith",
      "address": "88 West Blvd, Springfield",
      "time": "Tomorrow, 09:00 AM",
      "price": 50.00,
      "status": "Active",
    },
    {
      "service": "TV Installation",
      "ticket": "FX-1024",
      "worker": "David Wallace",
      "customer": "Lisa Brown",
      "address": "321 East Pkwy, Springfield",
      "time": "Feb 27, 04:30 PM",
      "price": 60.00,
      "status": "Cancelled",
    },
    {
      "service": "Deep Cleaning",
      "ticket": "FX-1025",
      "worker": "Sarah Jenkins",
      "customer": "Mark James",
      "address": "55 Central Square",
      "time": "Feb 26, 11:00 AM",
      "price": 200.00,
      "status": "Completed",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredJobs(String filter) {
    if (filter == 'All') return _allJobs;
    return _allJobs.where((job) => job['status'] == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Total Jobs',
          style: TextStyle(
            color: Color(0xFF1A1D26),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1D26)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3366FF),
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: const Color(0xFF3366FF),
          indicatorWeight: 3,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Jobs'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobsList(_getFilteredJobs('All')),
          _buildJobsList(_getFilteredJobs('Active')),
          _buildJobsList(_getFilteredJobs('Completed')),
          _buildJobsList(_getFilteredJobs('Cancelled')),
        ],
      ),
    );
  }

  Widget _buildJobsList(List<Map<String, dynamic>> jobs) {
    if (jobs.isEmpty) {
      return const Center(child: Text('No jobs found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        final status = job['status'];

        Color statusColor;
        Color statusBgColor;
        if (status == 'Completed') {
          statusColor = const Color(0xFF4CAF50);
          statusBgColor = const Color(0xFF4CAF50).withAlpha(26);
        } else if (status == 'Active') {
          statusColor = const Color(0xFF3366FF);
          statusBgColor = const Color(0xFF3366FF).withAlpha(26);
        } else {
          statusColor = Colors.red;
          statusBgColor = Colors.red.withAlpha(26);
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job['service'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1D26),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
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
              const SizedBox(height: 8),
              Text(
                'Ticket ID: ${job['ticket']}',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE8ECF4)),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.person_outline,
                "Customer: ${job['customer']}",
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.engineering_outlined,
                "Worker: ${job['worker']}",
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_on_outlined, job['address']),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.access_time_outlined, job['time']),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1D26),
                    ),
                  ),
                  Text(
                    '\$${job['price'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3366FF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
