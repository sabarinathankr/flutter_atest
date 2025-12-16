import 'dart:convert';

import 'package:ate/db_connection/DBConnections.dart';
import 'package:ate/ui/landingpage.dart';
import 'package:ate/utils/app_constants.dart';
import 'package:ate/utils/shared_preference.dart';
import 'package:flutter/material.dart';

import 'DataFile.dart';
import 'main.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {

      setState(() => _isLoading = true);

      DbConnections dbConnections = DbConnections();

      String result = await dbConnections.loginData(
        _emailController.text,
        _passwordController.text,
        context,
      );

      setState(() => _isLoading = false);

      if (result == "success") {
        // SUCCESS DIALOG
        final dialog = AwesomeDialog(
          context: context,
          animType: AnimType.leftSlide,
          dialogType: DialogType.noHeader,
          showCloseIcon: false,
          dismissOnTouchOutside: false,
          customHeader: Icon(Icons.check_circle, color: Colors.green, size: 80),
          title: 'Success',
          desc: 'User login successful!',
        );

        dialog.show();

        Future.delayed(const Duration(seconds: 2), () {
          dialog.dismiss();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
                (_) => false,
          );
        });

      } else if (result == "failure") {
        // WRONG CREDENTIALS
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials'),
            backgroundColor: Colors.red,
          ),
        );

      } else if (result == "error") {
        // INTERNAL ERROR
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  /* void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate login process
      // await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });
      DbConnections dbConnections =  DbConnections();
     *//* dbConnections.loginData(
          _emailController.text, _passwordController.text, context);*//*
      String? result = await dbConnections.loginData(_emailController.text, _passwordController.text, context);

     *//* if (result != null) {
        // SUCCESS CALLBACK
        print("Login success, userType = $result");
      } else {
        // FAILURE CALLBACK
        print("Login failed");
      }*//*

      if (result== null || result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      // Save user locally
      var userDoc = result.first;
      print("SharedPreferences_userDoc: $userDoc");
      try {
        await SharedPreferenceHelper.setString(AppConstants.userData, jsonEncode(userDoc));


      } catch (spError) {
        print("SharedPreferences error: $spError");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local storage error'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      String userType = userDoc['UsrType'] ?? "";

      if (userType.isNotEmpty) {
        final dialog = AwesomeDialog(
          context: context,
          animType: AnimType.leftSlide,
          dialogType: DialogType.noHeader,
          showCloseIcon: false,
          dismissOnTouchOutside: false,
          customHeader: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          title: 'Success',
          desc: 'User login successful!',
        );

        dialog.show();

        Future.delayed(Duration(seconds: 2), () {
          dialog.dismiss();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false,
          );
        });

        // return userType;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User type not defined.'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');

      // Show success message

    }
  }*/

  void _openTermsAndConditions() {
    // Handle terms and conditions link
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terms and Conditions'),
          content: const Text(
            'This is where your terms and conditions would be displayed. '
                'You can replace this with your actual terms content or '
                'navigate to a web page.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _emailController.text = 'veera1997@gmail.com';
    _passwordController.text = 'veera12345';
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or App Name
                  const Icon(
                    Icons.login,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Sign in to your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email TextField
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password TextField
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Terms and Conditions Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'By signing in, you agree to our ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: _openTermsAndConditions,
                        child: const Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}