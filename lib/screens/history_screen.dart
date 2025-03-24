import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitsugar/models/food_entry.dart';
import 'package:fitsugar/services/FirestoreService.dart';

enum SortOption { dateNewest, dateOldest, sugarHighest, sugarLowest }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  SortOption _currentSortOption = SortOption.dateNewest;
  final Color cardBorderColor = Colors.grey.shade300;

  String getSortOptionText(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        return 'Date: Newest first';
      case SortOption.dateOldest:
        return 'Date: Oldest first';
      case SortOption.sugarHighest:
        return 'Sugar: Highest first';
      case SortOption.sugarLowest:
        return 'Sugar: Lowest first';
    }
  }

  List<FoodEntry> _sortEntries(List<FoodEntry> entries) {
    switch (_currentSortOption) {
      case SortOption.dateNewest:
        entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case SortOption.dateOldest:
        entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case SortOption.sugarHighest:
        entries.sort((a, b) => b.sugarAmount.compareTo(a.sugarAmount));
        break;
      case SortOption.sugarLowest:
        entries.sort((a, b) => a.sugarAmount.compareTo(b.sugarAmount));
        break;
    }
    return entries;
  }

  //delete confirmation popup
  Future<bool> _confirmDelete(FoodEntry entry) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Method to delete entry and show confirmation
  void _deleteEntry(FoodEntry entry) {
    _firestoreService.deleteFoodEntry(entry.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${entry.foodName} removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.pink;
    final Color shadowColor = Colors.grey.withOpacity(0.2);
    final Color cardBorderColor = Colors.grey.shade300;
    final Color grey600 = Colors.grey.shade600;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugar History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          // Sort button in AppBar
          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort, color: primaryColor),
            tooltip: 'Sort',
            onSelected: (SortOption option) {
              setState(() {
                _currentSortOption = option;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              PopupMenuItem<SortOption>(
                value: SortOption.dateNewest,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: _currentSortOption == SortOption.dateNewest ? Colors.pink : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('Date (newest first)'),
                  ],
                ),
              ),
              PopupMenuItem<SortOption>(
                value: SortOption.dateOldest,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: _currentSortOption == SortOption.dateOldest
                          ? Colors.pink
                          : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('Date (oldest first)'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<SortOption>(
                value: SortOption.sugarHighest,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: _currentSortOption == SortOption.sugarHighest
                          ? Colors.pink
                          : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sugar level (highest first)'),
                  ],
                ),
              ),
              PopupMenuItem<SortOption>(
                value: SortOption.sugarLowest,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: _currentSortOption == SortOption.sugarLowest
                          ? Colors.pink
                          : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sugar level (lowest first)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Current sort indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Sorted by: ${getSortOptionText(_currentSortOption)}',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          // Food entries list
          Expanded(
            child: StreamBuilder<List<FoodEntry>>(
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

                List<FoodEntry> entries = snapshot.data ?? [];

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

                // Sort entries based on current sort option
                entries = _sortEntries(entries);

                // When sorting by sugar, show a flat list
                if (_currentSortOption == SortOption.sugarHighest ||
                    _currentSortOption == SortOption.sugarLowest) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key(entry.id),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await _confirmDelete(entry);
                          },
                          onDismissed: (direction) {
                            _deleteEntry(entry);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cardBorderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowColor,
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: ListTile(
                                title: Text(
                                  entry.foodName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  dateFormat.format(entry.timestamp),
                                  style: TextStyle(color: grey600),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
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
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () async {
                                        if (await _confirmDelete(entry)) {
                                          _deleteEntry(entry);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  //group by date when sorted by date
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
                    padding: const EdgeInsets.all(16),
                    itemCount: entriesByDate.length,
                    itemBuilder: (context, index) {
                      final date = entriesByDate.keys.elementAt(index);
                      final dateEntries = entriesByDate[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                            child: Text(
                              date,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: dateEntries.length,
                            itemBuilder: (context, entryIndex) {
                              final entry = dateEntries[entryIndex];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Dismissible(
                                  key: Key(entry.id),
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: grey600,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 16),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    return await _confirmDelete(entry);
                                  },
                                  onDismissed: (direction) {
                                    _deleteEntry(entry);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: cardBorderColor),
                                      boxShadow: [
                                        BoxShadow(
                                          color: shadowColor,
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                      child: ListTile(
                                        title: Text(
                                          entry.foodName,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          'Added at ${DateFormat('h:mm a').format(entry.timestamp)}',
                                          style: TextStyle(color: grey600),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
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
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                                              onPressed: () async {
                                                if (await _confirmDelete(entry)) {
                                                  _deleteEntry(entry);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
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
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  //determine color based on sugar amount
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