import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_project/firebase_options.dart';
import 'package:firebase_project/home_page.dart';
import 'package:firebase_project/user_profile.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //for check if user is (disabled/enabled) or still exists
  try {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.currentUser!.reload();
    }
  } on FirebaseAuthException catch (e) {
    print(e.toString());
  }

  runApp(MaterialApp(
    home: (FirebaseAuth.instance.currentUser == null)
        ? HomePage()
        : UserProfile(),
  ));
}
