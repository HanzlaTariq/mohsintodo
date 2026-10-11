import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User user = cred.user!;
    await user.updateDisplayName(name);

    final UserModel profile = UserModel(uid: user.uid, name: name, email: email);
    await _db.collection('users').doc(user.uid).set(profile.toMap());
    return profile;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User user = cred.user!;
    UserModel? profile;
    try {
      profile = await fetchProfile(user.uid);
    } catch (_) {
      profile = null;
    }
    return profile ??
        UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Friend',
          email: user.email ?? email,
        );
  }

  Future<UserModel?> fetchProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.collection('users').doc(uid).get();
    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return UserModel.fromMap(data);
  }

  Future<void> signOut() => _auth.signOut();

  static String messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
