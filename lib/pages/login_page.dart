import 'package:flutter/material.dart';
import 'myComplaints_page.dart';
import 'signup_page.dart';
import 'admin_complaints_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State Variables for New Features
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // This variable is required because you kept the Dropdown in the UI
  String selectedRole = 'Public User';
  final List<String> _roles = ['Public User', 'Govt. Officer'];

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    // Added check if widget is mounted for safety
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  // --- Password Reset Function ---
  void _resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar("Please enter your email in the field to reset the password.");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar(
        "Password reset email sent to $email. Check your inbox!",
        color: Colors.green,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send reset email. Make sure the email is correct.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email address.';
      }
      _showSnackBar(message);
    } catch (e) {
       _showSnackBar("A network error occurred. Please check your connection.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _login(BuildContext context) async {
    // Basic validation
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      _showSnackBar("Please enter both email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Login failed. User object is null.");
      }

      // **IMPORTANT: EMAIL VERIFICATION CHECK (Re-introducing the critical security check)**
      await user.reload(); 
      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && !refreshedUser.emailVerified) {
        await FirebaseAuth.instance.signOut();
        _showSnackBar("❌ Access denied. Please verify your email address to log in.", color: Colors.red);
        setState(() => _isLoading = false);
        return; 
      }
      
      // 2. Fetch the user's TRUE role from Firestore using their UID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
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
      _showSnackBar("Welcome back, $actualRole!", color: Colors.green);

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
      // --- IMPROVED ERROR HANDLING LOGIC ---
      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          // This covers wrong password, user not found, and general invalid credentials
          message = 'Invalid email or password.';
          break;
        case 'invalid-email':
          message = 'The email format is incorrect.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        default:
          // Fallback for unexpected or network-related errors
          message = "Login failed. Please check your connection and try again.";
          debugPrint('Firebase Auth Error Code: ${e.code}, Message: ${e.message}'); // Log for debugging
          break;
      }
      _showSnackBar(message);
    } on Exception catch (e) {
      // Handle custom exception from the security check or missing data
      String error = e.toString().replaceAll('Exception: ', '');
      if (error.contains('connection abort') || error.contains('network')) {
        _showSnackBar("Network Error: Could not connect to the server. Please check your connection.");
      } else {
        _showSnackBar("Error: $error", color: Colors.deepOrange);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  void _navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupPage()),
    );
  }

  // Helper for consistent input decoration styling
  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F0FF),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Role Selector
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: _roles.map((role) {
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
                      decoration: _inputDecoration("Select Role"),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("Email"),
                    ),
                    const SizedBox(height: 16),
                    
                    // --- Password Field with Visibility Toggle ---
                    TextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: _inputDecoration(
                        "Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    
                    // --- Forgot Password Link ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _login(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: _isLoading ? null : () => _navigateToSignup(context),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
