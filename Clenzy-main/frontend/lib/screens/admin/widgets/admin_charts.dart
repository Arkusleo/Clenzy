import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminBookingsChart extends StatelessWidget {
  const AdminBookingsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bookings Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('This Month', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withAlpha(150), size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 300,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withAlpha(10),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w500);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = const Text('Jan', style: style); break;
                          case 2: text = const Text('Feb', style: style); break;
                          case 4: text = const Text('Mar', style: style); break;
                          case 6: text = const Text('Apr', style: style); break;
                          case 8: text = const Text('May', style: style); break;
                          case 10: text = const Text('Jun', style: style); break;
                          case 12: text = const Text('Jul', style: style); break;
                          default: text = const Text('', style: style); break;
                        }
                        return SideTitleWidget(meta: meta, space: 10, child: text);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 300,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.right,
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 12,
                minY: 0,
                maxY: 1500,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 500),
                      FlSpot(1, 600),
                      FlSpot(2, 450),
                      FlSpot(3, 850),
                      FlSpot(4, 700),
                      FlSpot(5, 450),
                      FlSpot(6, 650),
                      FlSpot(7, 950),
                      FlSpot(8, 1245),
                      FlSpot(9, 850),
                      FlSpot(10, 1000),
                      FlSpot(11, 1300),
                      FlSpot(12, 1450),
                    ],
                    isCurved: true,
                    color: const Color(0xFF3366FF),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        return spot.x == 8; // Highlight May
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: const Color(0xFF3366FF),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3366FF).withAlpha(100),
                          const Color(0xFF3366FF).withAlpha(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => const Color(0xFF3366FF),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          '${touchedSpot.y.toInt()}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminUsersDonutChart extends StatelessWidget {
  final int totalUsers;
  final int totalWorkers;

  const AdminUsersDonutChart({
    super.key,
    required this.totalUsers,
    required this.totalWorkers,
  });

  @override
  Widget build(BuildContext context) {
    // Generate some slightly realistic proportions based on the available data to match screenshot
    final double customersPerc = totalUsers > 0 ? ((totalUsers - totalWorkers) / totalUsers) * 100 : 66.8;
    final double workersPerc = totalUsers > 0 ? (totalWorkers / totalUsers) * 100 : 24.3;
    final double adminsPerc = 6.4; 
    final double othersPerc = 2.5;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Users by Role',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 45,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            color: const Color(0xFF3366FF), // Customers - Blue
                            value: customersPerc,
                            title: '',
                            radius: 18,
                          ),
                          PieChartSectionData(
                            color: const Color(0xFF10B981), // Workers - Green
                            value: workersPerc,
                            title: '',
                            radius: 18,
                          ),
                          PieChartSectionData(
                            color: const Color(0xFF8A2BE2), // Admins - Purple
                            value: adminsPerc,
                            title: '',
                            radius: 18,
                          ),
                          PieChartSectionData(
                            color: const Color(0xFFF5A623), // Others - Orange
                            value: othersPerc,
                            title: '',
                            radius: 18,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            totalUsers.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'Total Users',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLegend('Customers', '${customersPerc.toStringAsFixed(1)}%', const Color(0xFF3366FF), totalUsers - totalWorkers),
                    const SizedBox(height: 12),
                    _buildLegend('Workers', '${workersPerc.toStringAsFixed(1)}%', const Color(0xFF10B981), totalWorkers),
                    const SizedBox(height: 12),
                    _buildLegend('Admins', '${adminsPerc.toStringAsFixed(1)}%', const Color(0xFF8A2BE2), 234), // mock
                    const SizedBox(height: 12),
                    _buildLegend('Others', '${othersPerc.toStringAsFixed(1)}%', const Color(0xFFF5A623), 90),  // mock
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, String percent, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 40,
          child: Text(
            '($percent)',
            style: const TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.right,
          ),
        )
      ],
    );
  }
}
