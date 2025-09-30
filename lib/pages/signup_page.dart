import 'package:flutter/material.dart';
import 'login_page.dart';
// import 'complaint_page.dart';
import 'admin_complaints_page.dart'; // Admin page
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myComplaints_page.dart';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'Public User';
  final List<String> _roles = ['Public User', 'Govt. Officer'];

  bool _isLoading = false;

  void _submitSignup() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    // 1. Create User with Firebase Auth
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Get the User ID
    final uid = userCredential.user!.uid;

    // 2. Store User details (Name, Phone, Role) in Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': _emailController.text.trim(),
      'fullName': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'role': _selectedRole, // This is CRUCIAL for your login logic
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Success message
    // Place the success message BEFORE navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Account Created Successfully!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Check if the role is 'Govt. Officer' first for clarity
    if (_selectedRole == 'Govt. Officer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminComplaintsPage()),
      );
    } else { // Must be 'Public User'
      // You should use MyComplaintsPage (used in login) for consistency
      // but ComplaintPage is acceptable if that's the desired first screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyComplaintsPage()), 
      );
    }

  } on FirebaseAuthException catch (e) {
    // Handle specific errors like email-already-in-use
    String message;
    if (e.code == 'weak-password') {
      message = 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      message = 'An account already exists for that email.';
    } else {
      message = e.message ?? 'Signup failed. Please try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $message"),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.deepPurple),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F0FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 8,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Role Selector
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: _inputDecoration("Select Role"),
                    items: _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),

                  SizedBox(height: 12),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: _inputDecoration("Full Name"),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration("Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.contains('@') ? null : 'Enter a valid email',
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration("Phone Number"),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value!.length < 10 ? 'Enter a valid phone number' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: _inputDecoration("Password"),
                    obscureText: true,
                    validator: (value) => value!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: _inputDecoration("Confirm Password"),
                    obscureText: true,
                    validator: (value) => value != _passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
