import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_task/config/route/const_route.dart';
import 'package:todo_task/presention/screens/sign/sign_up/widget/build_item_text_field.dart';
import 'package:todo_task/presention/widget/components.dart';
import 'package:todo_task/presention/widget/custom_button.dart';

import '../../../../data/datasources/remot/sign_mail_firebase.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(top: 50),
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(42),
            topRight: Radius.circular(42),
          ),
          color: Colors.grey[200],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                BuildItemTextField(
                  formState: _formState,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  nameController: _nameController,
                  phoneController: _phoneController,
                ),
                const SizedBox(
                  height: 40,
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  CustomButton(
                    title: 'Sign Up',
                    color: Colors.deepPurpleAccent.shade200,
                    onClick: () async {
                      if (_formState.currentState.validate()) {
                        setState(() {
                          _isLoading = !_isLoading;
                        });
                        final user = await signUpFirebase();
                        if (user != null) {
                          return Navigator.of(context).pushNamedAndRemoveUntil(
                            signIn,
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'I\'m a already a member.',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      child: const Text('Sign In'),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(signIn);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<UserCredential> signUpFirebase() async {
    return await SignMailFirebase().signUp(
      _emailController.text,
      _passwordController.text,
    );
  }
}