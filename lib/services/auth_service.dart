import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //getter for current user
  User? get currentUser => _firebaseAuth.currentUser;

  //sign in
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  //sign up
  Future<UserCredential> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //update the user's display name after creating the account
      await userCredential.user?.updateDisplayName(name);

      //refresh user data to make sure info is up to date
      await userCredential.user?.reload();

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  //sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    notifyListeners();
  }

  //update user name
  Future<void> updateUserName(String newName) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(newName);
      await _firebaseAuth.currentUser?.reload();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  //update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _firebaseAuth.currentUser?.updateEmail(newEmail);
      await _firebaseAuth.currentUser?.reload();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  //update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  //reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  //check if user is logged in
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  //stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}