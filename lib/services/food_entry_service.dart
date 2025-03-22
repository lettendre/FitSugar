import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsugar/models/food_entry.dart';

class FoodEntryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID (or return a guest ID if not logged in)
  String get _userId => _auth.currentUser?.uid ?? 'guest-user';

  // Get reference to the user's food entries collection
  CollectionReference get _entriesCollection =>
      _firestore.collection('users').doc(_userId).collection('food_entries');

  // Add a new food entry
  Future<void> addEntry(String foodName, double sugarAmount) async {
    try {
      // Create a document reference with auto-generated ID
      final docRef = _entriesCollection.doc();

      // Create a new food entry
      final entry = FoodEntry(
        id: docRef.id,
        foodName: foodName,
        sugarAmount: sugarAmount,
        timestamp: DateTime.now(),
      );

      // Save to Firestore
      await docRef.set(entry.toJson());
    } catch (e) {
      print('Error adding food entry: $e');
      rethrow;
    }
  }

  // Get all food entries for the current user
  Stream<List<FoodEntry>> getEntries() {
    return _entriesCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) =>
            FoodEntry.fromJson(doc.data() as Map<String, dynamic>)
        ).toList()
    );
  }

  // Delete a food entry
  Future<void> deleteEntry(String entryId) async {
    try {
      await _entriesCollection.doc(entryId).delete();
    } catch (e) {
      print('Error deleting food entry: $e');
      rethrow;
    }
  }
}