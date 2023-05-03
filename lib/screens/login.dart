import 'package:flutter/material.dart';

// ---------------------- //
// ----- Login Page ----- //
// ---------------------- //

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: OutlinedButton(
            onPressed: () => goBack(context), child: const Text("Go back!")),
      ),
    );
  }
}
