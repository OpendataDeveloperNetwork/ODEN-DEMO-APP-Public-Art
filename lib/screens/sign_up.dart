import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/only_back_button_app_bar.dart';
import '../models/auth.dart';
// ------------------------ //
// ----- Sign Up Page ----- //
// ------------------------ //

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: onlyBackButtonAppBarWidget(context), body: const SignUpBody());
  }
}

class SignUpBody extends StatefulWidget {
  const SignUpBody({super.key});

  @override
  State<SignUpBody> createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<SignUpBody> {
  String errorMessage = "";
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool isEmailInvalid = false;
  bool isPasswordInvalid = false;
  bool isNameInvalid = false;

  void showError(String message) {
    setState(() {
      errorMessage = message;
      isEmailInvalid = true;
      isPasswordInvalid = true;
    });
  }

  bool isAnyFieldsEmpty() {
    bool isAnyEmpty = false;
    setState(() {
      if (_emailController.text.isEmpty) {
        isEmailInvalid = true;
        isAnyEmpty = true;
      }
      if (_passwordController.text.isEmpty) {
        isPasswordInvalid = true;
        isAnyEmpty = true;
      }
      if (_nameController.text.isEmpty) {
        isNameInvalid = true;
        isAnyEmpty = true;
      }
    });
    return isAnyEmpty;
  }

  Future<void> signUpWithEmailAndPassword(BuildContext context) async {
    bool signUpSuccessful = false;

    if (_confirmPasswordController.text != _passwordController.text) {
      showError("Passwords do not match.");
      isPasswordInvalid = true;
      isEmailInvalid = false;
      isNameInvalid = false;
      return;
    }
    if (isAnyFieldsEmpty()) {
      showError("Please fill in all fields.");
      return;
    }
    try {
      await Auth().createUserWithEmailAndPassword(
          _emailController.text, _passwordController.text);
      signUpSuccessful = true;
    } on FirebaseAuthException catch (e) {
      showError(e.message!);
      if (e.code == 'weak-password') {
        isPasswordInvalid = true;
        isEmailInvalid = false;
        isNameInvalid = false;
      } else {
        isEmailInvalid = true;
        isPasswordInvalid = false;
        isNameInvalid = false;
      }
      return;
    }
    bool addedName = false;
    if (signUpSuccessful) {
      addedName = await Auth().updateName(_nameController.text);
    }
    if (addedName && context.mounted) {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/profile');
    }
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
      String label, TextEditingController controller, bool isInvalidListener) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: !isInvalidListener ? Colors.grey : Colors.red, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        focusColor: isInvalidListener ? Colors.green : Colors.red,
        labelStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(
            borderSide: BorderSide(width: 4),
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
    );
  }

  Visibility _buildErrorMessage() {
    return Visibility(
      visible: isEmailInvalid || isPasswordInvalid || isNameInvalid,
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

  Container _buildLoginButton() {
    return Container(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => signUpWithEmailAndPassword(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16BCD2),
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ));
  }

  void toLoginPage() {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/login');
  }

  Row _buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Have an account? ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        TextButton(onPressed: toLoginPage, child: const Text("Log In"))
      ],
    );
  }

  Column _buildLoginWidgets() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        "Hello, ",
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 5),
      const Text(
        "Sign Up!",
        style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 30),
      _buildErrorMessage(),
      const SizedBox(height: 30),
      _editableTextField(
          "Enter Email Address", _emailController, isEmailInvalid),
      const SizedBox(height: 30),
      _editableTextField("Enter Username", _nameController, isNameInvalid),
      const SizedBox(height: 30),
      _editableTextField(
          "Enter Password", _passwordController, isPasswordInvalid),
      const SizedBox(height: 30),
      _editableTextField(
          "Re-enter Password", _confirmPasswordController, isPasswordInvalid),
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
