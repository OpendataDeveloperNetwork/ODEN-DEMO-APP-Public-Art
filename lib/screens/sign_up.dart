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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> signUpWithEmailAndPassword(BuildContext context) async {
    bool signUpSuccessful = false;
    try {
      await Auth().createUserWithEmailAndPassword(
          _emailController.text, _passwordController.text);
      signUpSuccessful = true;
    } catch (e) {
      // TODO: Create a feedback when invalid password or something else.
      print(e);
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
        child: Image.asset('assets/images/logo.png'),
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
          onPressed: () => signUpWithEmailAndPassword(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF77BF4B),
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
      const SizedBox(height: 45),
      _editableTextField("Enter Email Address", _emailController),
      const SizedBox(height: 30),
      _editableTextField("Enter Username", _nameController),
      const SizedBox(height: 30),
      _editableTextField("Enter Password", _passwordController),
      const SizedBox(height: 30),
      _editableTextField("Re-enter Password", _confirmPasswordController),
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
