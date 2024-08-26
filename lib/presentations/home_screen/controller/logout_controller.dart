import 'package:firebase_auth/firebase_auth.dart';

class LogOutFunctions {
  Future<void> logoutuser()async{
    await FirebaseAuth.instance.signOut();
}
}
