import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: FutureBuilder(builder: (context, snapshot) {
        final user = FirebaseAuth.instance.currentUser;
        if(user?.emailVerified ?? false) {
          print("You are a verified user!");
        } else {
          print("Verify your email first!");
        }
        return const Text("juste pour tester");
      },),
    );
  }
}
