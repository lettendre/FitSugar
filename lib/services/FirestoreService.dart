import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsugar/models/food_entry.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID (or return a guest ID if not logged in)
  String get _userId => _auth.currentUser?.uid ?? 'guest-user';

  // USER DATA METHODS

  // Get user data by UID
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw e.toString();
    }
  }

  // Save user data
  Future<void> saveUserData(String userId, String name, String email) async {
    try {
      await _db.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // Update user data
  Future<void> updateUserData(String userId, String name, String email) async {
    try {
      await _db.collection('users').doc(userId).update({
        'name': name,
        'email': email,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete user data
  Future<void> deleteUserData(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
    } catch (e) {
      throw e.toString();
    }
  }

  // FOOD ENTRY METHODS

  // Get reference to the user's food entries collection
  CollectionReference _getEntriesCollection(String userId) =>
      _db.collection('users').doc(userId).collection('food_entries');

  // Add a new food entry
  Future<void> addFoodEntry(String foodName, double sugarAmount) async {
    try {
      // Use the authenticated user's ID or fall back to guest
      String userId = _userId;

      // Create a document reference with auto-generated ID
      final docRef = _getEntriesCollection(userId).doc();

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
  Stream<List<FoodEntry>> getFoodEntries() {
    String userId = _userId;

    return _getEntriesCollection(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) =>
            FoodEntry.fromJson(doc.data() as Map<String, dynamic>)
        ).toList()
    );
  }

  // Delete a food entry
  Future<void> deleteFoodEntry(String entryId) async {
    try {
      String userId = _userId;
      await _getEntriesCollection(userId).doc(entryId).delete();
    } catch (e) {
      print('Error deleting food entry: $e');
      rethrow;
    }
  }
}