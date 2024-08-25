import 'package:firebase_auth/firebase_auth.dart';

class LoginFunctions {
  Future<String?> loginUser({required String emaill, required String pwd}) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emaill, password: pwd);
      return null;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return e.message;
    }
  }
}