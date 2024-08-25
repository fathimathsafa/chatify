import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpFunctions {
  Future<String?> registerUser(
      {required String email, required String pwd, required String name}) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pwd,
      );
      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'userId': credential.user!.uid,
        'email': email,
        'name': name,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      print(e);
      return 'Error occurred. Please try again.';
    }
  }
}