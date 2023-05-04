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

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);
    } catch (e) {
      print(e);
    }
  }

  Expanded _buildLogo() {
    return Expanded(
        child: Container(
      color: Colors.white,
      child: Center(
        child: Image.asset('assets/images/logo.png'),
      ),
    ));
  }

  Expanded _buildLoginContainer() {
    return Expanded(
      flex: 4,
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

  TextField _editableTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        focusColor: Colors.green,
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
          onPressed: signInWithEmailAndPassword,
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

  Row _buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white),
        ),
        TextButton(onPressed: () {}, child: const Text("Sign Up"))
      ],
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
      const SizedBox(height: 45),
      _editableTextField("Enter Email Address", _emailController),
      const SizedBox(height: 30),
      _editableTextField("Enter Password", _passwordController),
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
