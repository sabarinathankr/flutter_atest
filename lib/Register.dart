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

  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();


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
    _dobController.dispose();

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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check if any mandatory fields are empty
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _mobileController.text.isEmpty ||
          _selectedGender == null ||
          _dobController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Please fill all fields.')),
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
          Dateofbirth: _dobController.text,
          Profile: base64Image ?? '', // ✅ Pass empty string if null
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
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // Format the date (e.g., yyyy-MM-dd)
      String formattedDate = "${picked.year}-${picked.month.toString().padLeft(
          2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

    @override
    Widget build(BuildContext context) {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Register to ATEST'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
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
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                      label: 'Full Name', controller: _nameController,inputfeildtype: TextInputType.name,icontype:Icons.person),
                  _buildTextField(label: 'Email', controller: _emailController,inputfeildtype: TextInputType.emailAddress,icontype: Icons.email),

                  _buildTextField(label: 'Password',
                      controller: _passwordController,inputfeildtype: TextInputType.visiblePassword,icontype:Icons.password,
                      obscureText: true),
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
                  Visibility(visible: true,child:Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _dobController,
                      readOnly: true, // prevent keyboard from appearing
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today),
                        labelText: "Select Date",
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
                      onTap: () => _selectDate(context),
                    ),
                  ), ),
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
