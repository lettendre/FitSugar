import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsugar/models/food_entry.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get current user ID
  String get _userId => _auth.currentUser?.uid ?? 'guest-user';

  //enable offline persistence during initialisation
  FirestoreService() {
    try {
      _db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up Firestore persistence: $e');
      }
    }
  }

  ///user data methods

  //get user data by UID
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user data: $e');
      }
      return null;
    }
  }

  //save user data
  Future<bool> saveUserData(String userId, String name, String email) async {
    try {
      await _db.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
      return false;
    }
  }

  //update user data
  Future<bool> updateUserData(String userId, String name, String email) async {
    try {
      await _db.collection('users').doc(userId).update({
        'name': name,
        'email': email,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user data: $e');
      }
      return false;
    }
  }

  ///food entry methods

  //get reference to the user's food entries collection
  CollectionReference _getEntriesCollection(String userId) =>
      _db.collection('users').doc(userId).collection('food_entries');

  //add new food entry
  Future<bool> addFoodEntry(String foodName, double sugarAmount) async {
    try {
      //use the authenticated user's ID
      String userId = _userId;

      //create a document reference with auto generated ID
      final docRef = _getEntriesCollection(userId).doc();

      //create a new food entry
      final entry = FoodEntry(
        id: docRef.id,
        foodName: foodName,
        sugarAmount: sugarAmount,
        timestamp: DateTime.now(),
      );

      //save to database
      await docRef.set(entry.toJson());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding food entry: $e');
      }
      return false;
    }
  }

  //get all food entries for the current user as a stream
  Stream<List<FoodEntry>> getFoodEntries() {
    String userId = _userId;

    try {
      return _getEntriesCollection(userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) =>
          snapshot.docs.map((doc) =>
              FoodEntry.fromJson(doc.data() as Map<String, dynamic>)
          ).toList()
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting food entries stream: $e');
      }
      //return an empty stream on error
      return Stream.value([]);
    }
  }

  //delete a food entry
  Future<bool> deleteFoodEntry(String entryId) async {
    try {
      String userId = _userId;
      await _getEntriesCollection(userId).doc(entryId).delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting food entry: $e');
      }
      return false;
    }
  }

  //get food entries as a list instead of Stream
  Future<List<FoodEntry>> getFoodEntriesAsList() async {
    try {
      String userId = _userId;
      final snapshot = await _getEntriesCollection(userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) =>
          FoodEntry.fromJson(doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting food entries as list: $e');
      }
      return [];
    }
  }
}