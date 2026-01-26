import 'package:flutter/material.dart';
import 'placeholders.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardHome(),
    WorkersScreen(),
    BookingsScreen(),
    PanicAppsScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Color(0xFF1A1A2E),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text('CLENZY ADMIN',
                style: TextStyle(
                    color: Color(0xFFE94560),
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ),
          _buildSidebarItem(0, Icons.dashboard, 'Dashboard'),
          _buildSidebarItem(1, Icons.people, 'Workers'),
          _buildSidebarItem(2, Icons.book, 'Bookings'),
          _buildSidebarItem(3, Icons.warning, 'Panic Alerts'),
          _buildSidebarItem(4, Icons.analytics, 'Analytics'),
          Spacer(),
          Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.grey),
            title: Text('Logout', style: TextStyle(color: Colors.grey)),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Color(0xFFE94560) : Colors.grey),
      title: Text(title,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey)),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      selected: isSelected,
      selectedTileColor: Colors.white.withValues(alpha: 0.05),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_getScreenTitle(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          Row(
            children: [
              IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
              SizedBox(width: 10),
              CircleAvatar(
                  backgroundColor: Color(0xFFE94560),
                  child: Icon(Icons.person, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard Overview';
      case 1:
        return 'Worker Management';
      case 2:
        return 'Booking Management';
      case 3:
        return 'Panic Alerts (Emergency)';
      case 4:
        return 'Platform Analytics';
      default:
        return 'Clenzy Admin';
    }
  }
}

class DashboardHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      color: Color(0xFFF4F7FE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(),
          SizedBox(height: 24),
          Text('Real-time Dispatch Monitor',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          SizedBox(height: 16),
          Expanded(child: _buildDispatchGrid()),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        _buildStatCard('Total Bookings', '1,284', Icons.book, Colors.blue),
        SizedBox(width: 16),
        _buildStatCard('Active Workers', '84', Icons.people, Colors.green),
        SizedBox(width: 16),
        _buildStatCard('Panic Alerts (24h)', '2', Icons.warning, Colors.red),
        SizedBox(width: 16),
        _buildStatCard(
            'Revenue', '\$12,450', Icons.attach_money, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color)),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchGrid() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        itemCount: 5,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Booking #CLK-92${index}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Service: Deep Cleaning • Customer: Jane Doe'),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Solo Assigned',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}
