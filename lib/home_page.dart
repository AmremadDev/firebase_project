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
                await signInAnonymously(context);
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
                        if (isLoading == false) {
                          // isLoading == true;
                          await signInAnonymously(context);
                          if (!mounted) return;
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => UserProfile()));
                        }
                        // isLoading == false;
                      },
                child: const Text("Anonymous Auth.")),
            ElevatedButton(
                onPressed: () async {
                  UserCredential? user = await signInWithGoogle(context);
                  if (!mounted || user == null) return;
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => UserProfile()));
                },
                child: const Text("Google Auth.")),
            ElevatedButton(
                onPressed: () async {
                  signInWithEmailAndPassword(
                      "a.emad@outlook.com", "123456", context);

                  // UserCredential? userCredential = await createUserWithEmailAndPassword("a.emad@outlook.com" , "123456",context);
                  // if (userCredential != null) {
                  //   // ignore: use_build_context_synchronously
                  //   signInWithEmailAndPassword("a.emad@outlook.com" , "123456",context);
                  // }

                  if (!mounted || userCredential == null) return;
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => UserProfile()));
                },
                child: const Text("Email/Password Auth.")),
            ElevatedButton(
                onPressed: () {
                  verifyPhoneNumber();
                },
                child: Text("Phone"))
          ],
        ),
      ),
    );
  }
}

Future<UserCredential?> signInAnonymously(BuildContext context) async {
  UserCredential? userCredential;
  try {
    userCredential = await FirebaseAuth.instance.signInAnonymously();
    return userCredential;
  } catch (e) {
    SnackBar snackBar = SnackBar(
      content: Text(e.toString()),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
  } on FirebaseAuthException catch (e) {
    SnackBar snackBar = SnackBar(
      content: Text(e.code.toString()),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Once signed in, return the UserCredential
}

Future<UserCredential?> createUserWithEmailAndPassword(
    String emailAddress, String password, BuildContext context) async {
  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );
    return credential;
  } on FirebaseAuthException catch (e) {
    SnackBar snackBar = SnackBar(
      content: Text(e.code.toString()),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

Future<UserCredential?> signInWithEmailAndPassword(
    String emailAddress, String password, BuildContext context) async {
  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailAddress, password: password);
    return credential;
  } on FirebaseAuthException catch (e) {
    SnackBar snackBar = SnackBar(
      content: Text(e.code.toString()),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

void verifyPhoneNumber() async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: '+201111146515',
    verificationCompleted: (PhoneAuthCredential credential) {},
    verificationFailed: (FirebaseAuthException e) {},
    codeSent: (String verificationId, int? resendToken) {},
    codeAutoRetrievalTimeout: (String verificationId) {},
  );
}
