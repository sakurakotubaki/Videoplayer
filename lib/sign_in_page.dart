import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_upload/upload_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign in'),
          onPressed: () async {
            final auth = FirebaseAuth.instance;
            await auth.signInAnonymously();
            if (context.mounted) {
              Navigator.of(context)
                  .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const UploadPage()), (route) => false);
            }
          },
        ),
      ),
    );
  }
}
