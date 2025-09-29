import 'package:flutter/material.dart';
import 'myComplaints_page.dart';
import 'signup_page.dart';
import 'admin_complaints_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // This variable is required because you kept the Dropdown in the UI
  String selectedRole = 'Public User'; 

  void _login(BuildContext context) async {
    // Basic validation
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password."), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      // 1. Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2. Fetch the user's TRUE role from Firestore using their UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Check for missing data
      if (!userDoc.exists || userDoc.data() == null || !(userDoc.data() as Map<String, dynamic>).containsKey('role')) {
        await FirebaseAuth.instance.signOut();
        throw Exception("User profile data is incomplete. Contact support.");
      }

      String actualRole = userDoc['role'] as String;

      // 3. SECURITY CHECK: Compare actual database role with selected UI role
      if (actualRole != selectedRole) {
        // Mismatch found! Log the authenticated user out to prevent unauthorized access.
        await FirebaseAuth.instance.signOut(); 
        throw Exception("Role mismatch. Please select your registered role and try again.");
      }
      
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome back, $actualRole!"), backgroundColor: Colors.green),
      );

      // 4. Successful Login and Navigation (using pushReplacement for clean stack)
      if (actualRole == 'Govt. Officer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminComplaintsPage()),
        );
      } else { // Public User
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyComplaintsPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors (bad email, bad password, etc.)
      String message = 'Either email or password is wrong.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password.';
      } else {
        message = e.message ?? "Login failed. Please try again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } on Exception catch (e) {
      // Handle custom exception from the security check or missing data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString().replaceAll('Exception: ', '')}"), backgroundColor: Colors.deepOrange),
      );
    }
  }


  void _navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(backgroundColor: Colors.deepPurple, title: Text("LocalFix")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Role Selector (UI retained as requested)
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: ['Public User', 'Govt. Officer'].map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Select Role",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _login(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text("Login", style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Create an account? "),
                      GestureDetector(
                        onTap: () => _navigateToSignup(context),
                        child: Text(
                          "Sign Up",
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