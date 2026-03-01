import 'package:flutter/material.dart';
import '../profile/payment_methods_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedDateIndex = 2; // Default to 'Fri 03' as per screenshot
  String selectedTime = '11:00 AM';

  final List<Map<String, String>> dates = [
    {'day': 'Mon', 'date': '29'},
    {'day': 'Tue', 'date': '30'},
    {'day': 'Wed', 'date': '01'},
    {'day': 'Thu', 'date': '02'},
    {'day': 'Fri', 'date': '03'},
    {'day': 'Sat', 'date': '04'},
    {'day': 'Sun', 'date': '05'},
  ];

  final List<String> times = [
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Titles
                const Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Book at a time slot as per\nyour convenience',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // Mock Address Selector
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.home_outlined, color: Colors.black54),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Home - House 416, Sector 3, Ud ...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black54),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Select date and time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your service will take approximately 4 hours',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Date Selector
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedDateIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDateIndex = index;
                          });
                        },
                        child: Container(
                          width: 65,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEAEAF9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF5D5FEF)
                                  : const Color(0xFFE8ECF4),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dates[index]['day']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? const Color(0xFF5D5FEF)
                                      : Colors.grey[600],
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dates[index]['date']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF5D5FEF)
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                const Divider(color: Color(0xFFE8ECF4)),
                const SizedBox(height: 24),

                // Time Slots Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: times.length,
                  itemBuilder: (context, index) {
                    final time = times[index];
                    final isSelected = selectedTime == time;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTime = time;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF5D5FEF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF5D5FEF)
                                : const Color(0xFFE8ECF4),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Checkout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentMethodsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D5FEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Proceed to checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
