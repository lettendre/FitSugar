import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitsugar/models/food_entry.dart';
import 'package:fitsugar/services/FirestoreService.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugar History'),
      ),
      body: StreamBuilder<List<FoodEntry>>(
        stream: _firestoreService.getFoodEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading history: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No food entries yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Search for foods to track sugar content',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Group entries by date
          final Map<String, List<FoodEntry>> entriesByDate = {};
          final dateFormat = DateFormat('MMM d, yyyy');

          for (var entry in entries) {
            final dateString = dateFormat.format(entry.timestamp);
            if (!entriesByDate.containsKey(dateString)) {
              entriesByDate[dateString] = [];
            }
            entriesByDate[dateString]!.add(entry);
          }

          return ListView.builder(
            itemCount: entriesByDate.length,
            itemBuilder: (context, index) {
              final date = entriesByDate.keys.elementAt(index);
              final dateEntries = entriesByDate[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade700,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: dateEntries.length,
                    itemBuilder: (context, entryIndex) {
                      final entry = dateEntries[entryIndex];
                      return Dismissible(
                        key: Key(entry.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text('Are you sure you want to remove this entry?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('DELETE'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          _firestoreService.deleteFoodEntry(entry.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${entry.foodName} removed')),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            entry.foodName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Added at ${DateFormat('h:mm a').format(entry.timestamp)}',
                            style: TextStyle(color: Colors.grey.shade600),
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
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to determine color based on sugar amount
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
}