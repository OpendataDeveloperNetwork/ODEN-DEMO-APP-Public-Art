import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/only_back_button_app_bar.dart';
import '../models/auth.dart';

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
      appBar: onlyBackButtonAppBarWidget(context),
      body: const LoginBody(),
    );
  }
}

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';
  bool isEmailInvalid = false;
  bool isPasswordInvalid = false;

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    bool signInSuccessful = false;
    try {
      await Auth().signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);
      signInSuccessful = true;
    } on FirebaseAuthException catch (e) {
      showError(e.message!);
    }
    if (signInSuccessful && context.mounted) {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/profile');
    }
  }

  void showError(String message) {
    setState(() {
      errorMessage = message;
      isEmailInvalid = true;
      isPasswordInvalid = true;
    });
  }

  Expanded _buildLogo() {
    return Expanded(
        child: Container(
      color: Colors.white,
      child: Center(
        child: Image.asset('assets/images/logo.jpg',
            width: 250, height: 250, fit: BoxFit.contain),
      ),
    ));
  }

  Expanded _buildLoginContainer() {
    return Expanded(
      flex: 5,
      child: Container(
          decoration: const BoxDecoration(
              color: Color(0xFF2D3848),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 8,
                  spreadRadius: 3,
                  offset: Offset(4, 8),
                ),
              ],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), topRight: Radius.circular(40))),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 25, 30, 0),
            child: SingleChildScrollView(child: _buildLoginWidgets()),
          )),
    );
  }

  TextField _editableTextField(
      String label, TextEditingController controller, bool invalidListener) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: !invalidListener ? Colors.grey : Colors.red, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        focusColor: invalidListener ? Colors.green : Colors.red,
        labelStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(
            borderSide: BorderSide(width: 4),
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
    );
  }

  Container _buildLoginButton() {
    return Container(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => signInWithEmailAndPassword(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF77BF4B),
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            "Log In",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ));
  }

  void toSignUpPage() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/signUp');
  }

  Row _buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white),
        ),
        TextButton(onPressed: toSignUpPage, child: const Text("Sign Up"))
      ],
    );
  }

  Visibility _buildErrorMessage() {
    return Visibility(
      visible: isEmailInvalid && isPasswordInvalid,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.red[600], borderRadius: BorderRadius.circular(15)),
        child: Center(
            child: Text(errorMessage,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500))),
      ),
    );
  }

  Column _buildLoginWidgets() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        "Welcome back,",
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 5),
      const Text(
        "Log In!",
        style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 30),
      _buildErrorMessage(),
      const SizedBox(height: 30),
      _editableTextField(
          "Enter Email Address", _emailController, isEmailInvalid),
      const SizedBox(height: 30),
      _editableTextField(
          "Enter Password", _passwordController, isPasswordInvalid),
      const SizedBox(height: 50),
      _buildLoginButton(),
      const SizedBox(height: 20),
      _buildSignUpButton()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLogo(),
        const SizedBox(height: 20),
        _buildLoginContainer(),
      ],
    );
  }
}
