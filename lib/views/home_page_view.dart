import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/verify_email_view.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.emailVerified) {
          print(user);
          return const NotesView();
        } else {
          return const VerifyEmailView();
        }
      } else {
        return const LoginView();
      }
    },);




    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text("Home Page"),
    //   ),
    //   body: FutureBuilder(
    //     builder: (context, snapshot) {
    //       final user = FirebaseAuth.instance.currentUser;
    //       if(user != null) {
    //         if(user.emailVerified) {
    //           print("emaaail verified");
    //         } else {
    //           Navigator.of(context).push(MaterialPageRoute(builder: (context) => const  VerifyEmailView(),));
    //           // return const VerifyEmailView();
    //         }
    //       } else {
    //         return const LoginView();
    //       }
    //       return const Text("it's okay");



          
    //       // if (!(user?.emailVerified ?? false)){
    //       //   print("Verify your email first!");
    //       //   print(user);
    //       //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => const VerifyEmailView(),));
    //       // }
    //       // return const Text("juste pour tester");
    //     },
    //   ),
    // );
  }
}
