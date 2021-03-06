import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_project/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (user!.isAnonymous == true)
                ? const Text(
                    "This is Anonymous user",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : Text(user!.email.toString()),
            Text("id=> ( ${user!.uid.toString()} )"),
            ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: ((context) => HomePage())));
                },
                child: const Text("Sign Out")),
            permmantentAccount(user!),
          ],
        ),
      ),
    );
  }
}

Widget permmantentAccount(User user) {
  if (user.isAnonymous == true) {
    return ElevatedButton(
        onPressed: () async {},
        child: const Text("Convert to a permanent account"));
  } else {
    return const Text("");
  }
}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}
