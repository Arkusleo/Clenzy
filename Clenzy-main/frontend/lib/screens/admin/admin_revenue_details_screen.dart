import 'package:flutter/material.dart';

class AdminRevenueDetailsScreen extends StatelessWidget {
  const AdminRevenueDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Platform Revenue',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Revenue Card
            _buildTotalRevenueCard(),
            const SizedBox(height: 24),

            // Dummy Chart Area
            const Text(
              'Revenue Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 12),
            _buildChartArea(),
            const SizedBox(height: 24),

            // Revenue by Category
            const Text(
              'Revenue by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryDistribution(),
            const SizedBox(height: 24),

            // Monthly Earnings Table
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 12),
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3366FF), Color(0xFF2952CC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3366FF).withAlpha(77),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Platform Revenue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withAlpha(204),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '\$12,450.00',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRevenueBreakdown(
                'Partner Payout',
                '\$9,960.00',
                Colors.white,
              ),
              _buildRevenueBreakdown(
                'Platform Commission',
                '\$2,490.00',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdown(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: color.withAlpha(153)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildChartArea() {
    return Container(
      height: 200,
      width: double.infinity,
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
      child: Stack(
        children: [
          // Dummy chart representation using rounded rects
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(60, 'Jan'),
                _buildBar(90, 'Feb'),
                _buildBar(70, 'Mar'),
                _buildBar(120, 'Apr'),
                _buildBar(80, 'May'),
                _buildBar(140, 'Jun'),
                _buildBar(110, 'Jul'),
              ],
            ),
          ),
          const Positioned(
            top: 16,
            left: 16,
            child: Text(
              '+15% from last month',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF3366FF),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDistribution() {
    return Container(
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
        children: [
          _buildCategoryItem('Home Cleaning', 45, 5602.50, Colors.blue),
          const Divider(height: 1, color: Color(0xFFE8ECF4)),
          _buildCategoryItem('AC Repair', 25, 3112.50, Colors.teal),
          const Divider(height: 1, color: Color(0xFFE8ECF4)),
          _buildCategoryItem('Plumbing', 20, 2490.00, Colors.orange),
          const Divider(height: 1, color: Color(0xFFE8ECF4)),
          _buildCategoryItem('Electrical', 10, 1245.00, Colors.red),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String name,
    int percentage,
    double amount,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D26),
              ),
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    final List<Map<String, dynamic>> transactions = [
      {
        "id": "TRX-1092",
        "date": "Today, 10:30 AM",
        "amount": 85.00,
        "type": "AC Repair",
      },
      {
        "id": "TRX-1091",
        "date": "Yesterday, 02:15 PM",
        "amount": 120.00,
        "type": "House Cleaning",
      },
      {
        "id": "TRX-1090",
        "date": "Feb 27, 09:00 AM",
        "amount": 45.00,
        "type": "Plumbing",
      },
      {
        "id": "TRX-1089",
        "date": "Feb 26, 04:45 PM",
        "amount": 200.00,
        "type": "Deep Cleaning",
      },
    ];

    return Container(
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFE8ECF4)),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tx['id']} - ${tx['type']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D26),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tx['date'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+\$${tx['amount'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
