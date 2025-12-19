import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // а?"ь ђ'‘:‘-ђ? ‘Шђз‘?ђзђъ Google
  Future<User?> signInWithGoogle() async {
    try {
      // На web використовуємо вбудований popup Firebase, щоб уникати проблем із блокованими вікнами.
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider()..addScope('email');
        final result = await _auth.signInWithPopup(googleProvider);
        return result.user;
      }

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // ђ?ђ?‘?ђс‘?‘'‘?ђ?ђш‘Ш ‘?ђуђш‘?‘?ђ?ђшђ?

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  Future<User?> register(String email, String password, String displayName) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.message}');
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.message}');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
