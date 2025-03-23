import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'history_screen.dart';
import 'add_data_screen.dart';
import 'profile_screen.dart';
import 'package:fitsugar/widgets/bottom_navbar.dart';
import 'package:fitsugar/models/food_entry.dart';
import 'package:fitsugar/services/FirestoreService.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardView(),
    const AddDataScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Image.asset(
          'logo.png',
          height: 40,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final FirestoreService _firestoreService = FirestoreService();

  // Get the most recent 3 food entries from Firestore
  Stream<List<FoodEntry>> _getRecentFoodEntries() {
    return _firestoreService.getFoodEntries().map((entries) {
      // Take just the first 3 entries (they're already sorted by timestamp descending)
      return entries.take(3).toList();
    });
  }

  // Get appropriate icon based on food name
  IconData _getFoodIcon(String foodName) {
    return Icons.restaurant;
  }

  // Format timestamp to a readable format
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  // Get color based on sugar amount
  Color _getSugarLevelColor(double sugarAmount) {
    if (sugarAmount <= 5) {
      return Colors.green;
    } else if (sugarAmount <= 10) {
      return Colors.orange;
    } else if (sugarAmount <= 20) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }


  @override
  Widget build(BuildContext context) {
    // Define the primary color to match login screen (pink color)
    final Color primaryColor = Color(0xFFE94262);
    final Color textColor = Colors.black87;
    final Color cardBorderColor = Colors.grey.shade300;


    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Weekly Sugar Intake Chart
            Text(
              'Weekly Sugar Intake',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 12),

            // Weekly Sugar Chart - UPDATED WITH NEW DECORATION
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<List<FoodEntry>>(
                stream: _firestoreService.getFoodEntries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading data',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No data to display',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Process data for the chart
                  final entries = snapshot.data!;
                  final weeklyData = _processWeeklyData(entries);

                  return _buildSugarIntakeChart(weeklyData, primaryColor);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Add Food Entry Button - Call to Action - UPDATED WITH NEW DECORATION
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (context.findAncestorStateOfType<_DashboardScreenState>() != null) {
                      context.findAncestorStateOfType<_DashboardScreenState>()!._onItemTapped(1); // Index 1 is Add Data/Search screen
                    }
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Add Food Entry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Daily Food Log Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Entries',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                // View All Button
                TextButton(
                  onPressed: () {
                    if (context.findAncestorStateOfType<_DashboardScreenState>() != null) {
                      context.findAncestorStateOfType<_DashboardScreenState>()!._onItemTapped(2); // Index 2 is the History screen
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: primaryColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Recent Food Entries - Show only the last 3 entries - UPDATED WITH NEW DECORATION
            Expanded(
              child: StreamBuilder<List<FoodEntry>>(
                stream: _getRecentFoodEntries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading entries',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.no_food,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No food entries yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first food item',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final entries = snapshot.data!;
                    return ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getFoodIcon(entry.foodName),
                                color: primaryColor,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              entry.foodName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                '${_formatTimestamp(entry.timestamp)} • ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getSugarLevelColor(entry.sugarAmount),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${entry.sugarAmount.toStringAsFixed(1)}g',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Process data for weekly sugar intake chart
  List<Map<String, dynamic>> _processWeeklyData(List<FoodEntry> entries) {
    final now = DateTime.now();
    final weeklyData = <DateTime, double>{};

    // Initialize last 7 days with 0 values
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      weeklyData[date] = 0;
    }

    // Calculate total sugar intake for each day
    for (var entry in entries) {
      final entryDate = entry.timestamp;
      // Normalize to start of day for proper comparison
      final normalizedDate = DateTime(entryDate.year, entryDate.month, entryDate.day);
      final diff = now.difference(normalizedDate).inDays;

      // Only consider entries from the last 7 days
      if (diff >= 0 && diff < 7) {
        weeklyData[normalizedDate] = (weeklyData[normalizedDate] ?? 0) + entry.sugarAmount;
      }
    }

    // Convert map to list of maps for chart
    return weeklyData.entries.map((e) => {
      'date': e.key,
      'amount': e.value,
    }).toList()
      ..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
  }

  // Build sugar intake chart
  Widget _buildSugarIntakeChart(List<Map<String, dynamic>> data, Color primaryColor) {
    // Find max value for Y-axis scaling
    final maxY = data.isEmpty ? 10.0 : data.map((e) => e['amount'] as double).reduce((a, b) => a > b ? a : b) + 5;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 4.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    // Show abbreviated day names instead of dates
                    final date = data[value.toInt()]['date'] as DateTime;

                    // For alternating days, show the day of month, otherwise empty
                    final showDate = value.toInt() % 1 == 0;

                    if (showDate) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('d').format(date),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: (maxY / 5).roundToDouble(),
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}g',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value['amount']);
              }).toList(),
              isCurved: true,
              color: primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: primaryColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: primaryColor.withOpacity(0.2),
              ),
            ),
          ],
          minX: 0,
          maxX: data.length.toDouble() - 1,
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                return lineBarsSpot.map((lineBarSpot) {
                  final date = data[lineBarSpot.x.toInt()]['date'] as DateTime;
                  return LineTooltipItem(
                    '${DateFormat('MMM d').format(date)}: ${lineBarSpot.y.toStringAsFixed(1)}g',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}