import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/user_profile.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserCredential? userCredential;
  bool isLoading = false;

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  void _doSomething() async {
    _btnController.success();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundedLoadingButton(
              controller: _btnController,
              onPressed: () async {
                await signInAnonymously();
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => UserProfile()));
                    
              },
              child:
                  const Text('Tap me!', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
                onPressed: (isLoading == true)
                    ? null
                    : () async {
                        setState(() {
                          isLoading == true;
                        });

                        if (isLoading == false) {
                          await signInAnonymously();
                          if (!mounted) return;
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => UserProfile()));
                        }

                        setState(() {
                          isLoading == false;
                        });
                      },
                child: const Text("Anonymous Auth.")),
            ElevatedButton(
                onPressed: () async {
                  UserCredential? user = await signInWithGoogle(context);
                  if (!mounted || user == null) return;
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => UserProfile()));
                },
                child: const Text("Google Auth."))
          ],
        ),
      ),
    );
  }
}

Future<UserCredential?> signInAnonymously() async {
  UserCredential? userCredential;
  try {
    userCredential = await FirebaseAuth.instance.signInAnonymously();
    print("Signed in with temporary account.");
    return userCredential;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "operation-not-allowed":
        print("Anonymous auth hasn't been enabled for this project.");
        return userCredential;
      default:
        print("Unknown error.");
        return userCredential;
    }
  }
}

Future<UserCredential?> signInWithGoogle(BuildContext context) async {
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

  try {
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    const snackBar = SnackBar(
      content: Text('The user account has been disabled by an administrator.!'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Once signed in, return the UserCredential
}
