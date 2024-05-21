import 'package:chatfirebase/pages/generalPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../theme_controller.dart';
import 'chatApp.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Login'),
        actions: [
          IconButton(
            icon: Icon(themeController.isDarkMode.value ? Icons.dark_mode : Icons.light_mode),
            onPressed: themeController.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signInWithEmailPassword,
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  void _signInWithEmailPassword() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    // Email ve şifreyi konsola yazdır
    print('Email: $email');
    print('Password: $password');

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        print('Successfully signed in UID: ${user.uid}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) =>GeneralPage()),
        );
      } else {
        print('Failed to sign in');
      }
    } catch (e) {
      print('Failed to sign in: $e');
    }
  }
}
