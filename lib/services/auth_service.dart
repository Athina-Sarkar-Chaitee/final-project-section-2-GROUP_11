import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SIGN UP (NO EMAIL VERIFICATION)
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // LOGIN
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // CURRENT USER
  User? get currentUser => _auth.currentUser;
}
