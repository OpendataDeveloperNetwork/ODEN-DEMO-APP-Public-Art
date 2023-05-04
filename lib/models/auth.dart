import 'package:firebase_auth/firebase_auth.dart';

///
/// This file contains all authentication class and its functions.
///

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  ///
  /// Use when users a logging to firebase. Developer is responsible for
  /// checking if the user is signed in successfully or not.
  ///
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  ///
  /// Use when users a creating an account to firebase. Developer is responsible for
  /// checking if the user is successfully created or not.
  ///
  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<bool> updateName(String name) async {
    try {
      await _auth.currentUser!.updateDisplayName(name);
      return true;
    } catch (e) {
      return false;
    }
  }

  String get name => _auth.currentUser!.displayName!;

  ///
  /// Use when users a logging out from firebase. Developer is responsible for
  /// checking if the user is successfully logged out or not.
  ///
  Future<void> signOut() async {
    await _auth.signOut();
  }

  ///
  /// A getter to check if the user is signed in or not. Returns true if the user
  /// signed in successfully, else false.
  ///
  bool get isLoggedIn => _auth.currentUser != null;
}
