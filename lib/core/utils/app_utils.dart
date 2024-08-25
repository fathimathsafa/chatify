import 'package:firebase_core/firebase_core.dart';

Future<void> setUpFirebase() async {
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyB_QaK77pkLAZVffXuLPO8XZF1ey1Qhuio",
          appId: "1:40213863269:android:126c0b876f39fedebf5f8c",
          messagingSenderId: "",
          projectId: "winceptchat"));
}

