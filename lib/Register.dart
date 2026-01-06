import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'DataFile.dart';


class RegisterPage extends StatefulWidget {
  RegisterPage();

  @override
  State<RegisterPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isPasswordHidden = true;

  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _genderController = TextEditingController();



  File? _image;
  var base64Image;
  final ImagePicker _picker = ImagePicker();
  String? _selectedGender;


  @override
  void dispose() {

    _nameController.dispose();
    _emailController.dispose();

    _passwordController.dispose();
    _mobileController.dispose();
    _genderController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() async {
        _image = File(pickedFile.path);
        final bytes = _image!.readAsBytes();
        base64Image = base64Encode(await bytes);
      });
    }
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$'
    );

    return passwordRegex.hasMatch(password);
  }

  Future<void> _submitForm() async {


    if (_formKey.currentState!.validate()) {
      // Check if any mandatory fields are empty
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _mobileController.text.isEmpty ||
          _selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Please fill all fields.')),
        );
        return;
      }
      String pwd = _passwordController.text.toString().trim();
      if (!isValidPassword(pwd)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Password must contain at least 6 characters, one uppercase letter, one lowercase letter, one number, and one special character.Invalid password ')),
        );
        return;
      }
      try {
        var user = UserForms(
          FullName: _nameController.text,
          Email: _emailController.text,
          Password: _passwordController.text,
          MobileNumber: _mobileController.text,
          Gender: _selectedGender.toString(),
          Profile: '', // ✅ Pass empty string if null
          UsrType: 'User',
        );

        blanddb ins = blanddb();
        ins.InsertData(user, context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please correct the highlighted errors.')),
      );
    }
  }



  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required TextInputType inputfeildtype,
    required IconData icontype,
    bool obscureText = false,
  }) {
    return Visibility(visible: true,
        child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputfeildtype,
        decoration: InputDecoration(
          prefixIcon: Icon(icontype),
          labelText: label,
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
            return 'Please enter $label';
          }
          return null;
        },
      ),
    ),
    );
  }

  Widget _buildTextFieldWithPassword({
    required String label,
    required TextEditingController controller,
    required TextInputType inputfeildtype,
    required IconData icontype,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputfeildtype,
        decoration: InputDecoration(
          prefixIcon: Icon(icontype),
          labelText: label,

          // 👁 Show / Hide icon
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: onToggleVisibility,
          )
              : null,

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
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {


  }

    @override
    Widget build(BuildContext context) {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Register'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  /*GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : null,
                      child: _image == null
                          ? Icon(Icons.camera_alt, size: 40)
                          : null,
                    ),
                  ),*/
                  SizedBox(height: 50),
                  _buildTextField(
                      label: 'Full Name', controller: _nameController,inputfeildtype: TextInputType.name,icontype:Icons.person),
                  _buildTextField(label: 'Email', controller: _emailController,inputfeildtype: TextInputType.emailAddress,icontype: Icons.email),

                  /*_buildTextField(label: 'Password',
                      controller: _passwordController,inputfeildtype: TextInputType.visiblePassword,icontype:Icons.password,
                      obscureText: true),*/


                  _buildTextFieldWithPassword(label: 'Password',
                  controller: _passwordController,inputfeildtype: TextInputType.visiblePassword,icontype:Icons.password,isPassword: true,
                  obscureText: _isPasswordHidden,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                ),
                  _buildTextField(
                      label: 'Mobile Number', controller: _mobileController,inputfeildtype: TextInputType.phone,icontype:Icons.phone),
                 Visibility(visible: true,child:Padding(
                   padding: const EdgeInsets.only(bottom: 16.0),
                   child:
                   DropdownButtonFormField<String>(

                     decoration: InputDecoration(
                       labelText: 'Gender',
                       prefixIcon: Icon(Icons.person),
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
                     value: _selectedGender,
                     items: ['Male', 'Female', 'Other']
                         .map((gender) => DropdownMenuItem(
                       value: gender,
                       child: Text(gender),
                     ))
                         .toList(),
                     onChanged: (value) {
                       setState(() {
                         _selectedGender = value;
                       });
                     },
                   ),
                 ) ,) ,
                  Visibility(visible: true,child:ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: Icon(Icons.account_box_outlined, color: Colors.black),
                    label: Text('Register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: EdgeInsets.symmetric(
                          vertical: 16, horizontal: 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ), ),

                  SizedBox(height: 24),

                  SizedBox(height: 40),

                ],
              ),
            ),
          ),
        ),
      );
    }
  }
