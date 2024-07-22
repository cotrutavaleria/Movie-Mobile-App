import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app_client/auth/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullNameController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showEmailError = false;
  bool showPasswordConfirmationError = false;
  bool showFullNameError = false;
  bool showPasswordError = false;
  String fullNameErrorMessage = "";
  String emailErrorMessage = "";
  String passwordConfirmationErrorMessage = "";
  String passwordErrorMessage = "";
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isEmailValid(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return emailRegex.hasMatch(email);
  }

  void checkFullName(String fullName) {
    if (fullName.isEmpty) {
      fullNameErrorMessage = "Enter your name.";
      setState(() {
        showFullNameError = true;
      });
    } else if (fullName.length < 4) {
      fullNameErrorMessage = "Your name is too short.";
      setState(() {
        showFullNameError = true;
      });
    } else {
      setState(() {
        showFullNameError = false;
      });
    }
  }

  void checkPassword(String password) {
    if (password.isEmpty) {
      passwordErrorMessage = "Enter a password.";
      setState(() {
        showPasswordError = true;
      });
    } else if (password.length < 6) {
      passwordErrorMessage = "Password is too short.";
      setState(() {
        showPasswordError = true;
      });
    } else {
      setState(() {
        showPasswordError = false;
      });
    }
  }

  checkPasswordConfirmation(String password, String passwordConfirmation) {
    if (passwordConfirmation.isEmpty) {
      passwordConfirmationErrorMessage = "Please, confirm the password.";
      setState(() {
        showPasswordConfirmationError = true;
      });
    } else if (password.compareTo(passwordConfirmation) != 0) {
      passwordConfirmationErrorMessage = "Passwords don't match.";
      setState(() {
        showPasswordConfirmationError = true;
      });
    } else {
      setState(() {
        showPasswordConfirmationError = false;
      });
    }
  }

  checkEmail(String email) {
    if (email.isEmpty) {
      emailErrorMessage = "Enter an email.";
      setState(() {
        showEmailError = true;
      });
    } else if (!isEmailValid(email)) {
      emailErrorMessage = "Email is not valid.";
      setState(() {
        showEmailError = true;
      });
    } else {
      setState(() {
        showEmailError = false;
      });
    }
  }

  Future<void> _register() async {
    String fullName = fullNameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String passwordConfirmation = passwordConfirmationController.text;

    checkFullName(fullName);
    checkPassword(password);
    checkPasswordConfirmation(password, passwordConfirmation);
    checkEmail(email);

    if (!showEmailError &&
        !showPasswordConfirmationError &&
        !showFullNameError &&
        !showPasswordError) {
      final response = await http.post(
        Uri.parse('http://192.168.1.136:8082/api/v1/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'fullName': fullName,
          'email': email,
          'password': password
        }),
      );
      if (response.statusCode == 200) {
        var message = jsonDecode(response.body);
        emailErrorMessage = message['message'];
        setState(() {
          showEmailError = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        var message = jsonDecode(response.body);
        emailErrorMessage = message['message'];
        setState(() {
          showEmailError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color.fromARGB(255, 187, 134, 115),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 187, 134, 115),
                  Colors.white,
                  Color.fromARGB(255, 229, 141, 109)
                ],
                stops: [0.1, 0.7, 0.9],
              ),
            ),
          ),
          SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 120.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'OpenSans',
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 60.0,
                        child: TextField(
                          controller: fullNameController,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(top: 14.0),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
                            hintText: 'Enter your full name',
                            errorText:
                                showFullNameError ? fullNameErrorMessage : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 60.0,
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(top: 14.0),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                            hintText: 'Enter your e-mail',
                            errorText:
                                showEmailError ? emailErrorMessage : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 60.0,
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(top: 14.0),
                            prefixIcon: const Icon(
                              Icons.password,
                              color: Colors.black,
                            ),
                            hintText: 'Enter your password',
                            errorText:
                                showPasswordError ? passwordErrorMessage : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 60.0,
                        child: TextField(
                          controller: passwordConfirmationController,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'OpenSans',
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(top: 14.0),
                            prefixIcon: const Icon(
                              Icons.password,
                              color: Colors.black,
                            ),
                            hintText: 'Re-enter your password',
                            errorText: showPasswordConfirmationError
                                ? passwordConfirmationErrorMessage
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    width: double.infinity,
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15.0),
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Color(0xFF527DAA),
                            letterSpacing: 1.5,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
