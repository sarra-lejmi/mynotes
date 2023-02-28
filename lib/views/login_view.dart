import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Enter your Email"),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter your Password"),
          ),
          TextButton(
            onPressed: () async {
              final email = _emailController.text;
              final password = _passwordController.text;
              try {
                UserCredential userCredential =
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                print(userCredential);
                Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
              } on FirebaseAuthException catch (e) {
                if (e.code == "user-not-found") {
                  print("User not found!");
                } else if (e.code == "wrong-password") {
                  print("Wrong password!");
                } else if (e.code == "invalid-email") {
                  print("Invalid email!");
                } else {
                  print("Something went wrong");
                }
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, registerRoute, (route) => route.isFirst);
            },
            child: const Text("Not regigistred yet? regidter now!"),
          ),
        ],
      ),
    );
  }
}
