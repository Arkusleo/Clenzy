import 'package:flutter/material.dart';

class JobFeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Jobs'),
        backgroundColor: Color(0xFF1B1B2F),
        actions: [
          IconButton(
            icon: Icon(Icons.person_pin_circle),
            onPressed: () {}, // Toggle online/offline
          )
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildJobCard(context);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF1B1B2F),
        selectedItemColor: Color(0xFFE94560),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Earnings'),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context) {
    return Card(
      color: Color(0xFF16213E),
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Home Cleaning',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text('\$45.00',
                    style: TextStyle(
                        color: Color(0xFFE94560),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey, size: 16),
                SizedBox(width: 4),
                Text('2.5 km away • Downtown',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Reject'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Colors.grey)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Accept'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0F3460)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
