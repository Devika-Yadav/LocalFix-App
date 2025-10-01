import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart'; // Import the new Edit Profile Page

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Helper function to build the data display rows, matching the design's clean look
  Widget _buildProfileRow({required String label, required String value, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          if (!isLast) // Use a subtle divider unless it's the last item
            Divider(color: Colors.grey.shade300, height: 20),
        ],
      ),
    );
  }

  // Navigates to the Edit Profile Page
  void _handleEdit(BuildContext context, Map<String, dynamic> currentData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(initialData: currentData),
      ),
    ).then((_) {
      // Force a refresh when returning from the edit page
      setState(() {});
    });
  }

  // Handles account deletion with confirmation dialog
  Future<void> _handleDeleteAccount(BuildContext context, User user) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Confirm Account Deletion', style: TextStyle(color: Colors.red)),
        content: const Text(
            'Are you sure you want to permanently delete your account? This action is irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        // 1. Delete user data from Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        
        // 2. Delete the Firebase Authentication user account
        await user.delete();

        // 3. Navigate back to the login page (assumed to be the first route)
        Navigator.popUntil(context, (route) => route.isFirst);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account successfully deleted.')),
        );
      } on FirebaseAuthException catch (e) {
        // Handle cases like requiring re-authentication
        String message = 'Error deleting account. Please log out and log back in, then try again.';
        if (e.code == 'requires-recent-login') {
          message = 'You must re-authenticate before deleting your account.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unknown error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current Firebase Auth user
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not logged in.')),
      );
    }

    // Use a StreamBuilder to fetch user details from Firestore
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading user data: ${snapshot.error}'));
          }
          
          final userData = snapshot.data?.data() as Map<String, dynamic>?;

          // Safely retrieve data
          final name = userData?['fullName'] ?? 'N/A';
          final mobileNumber = userData?['phone'] ?? 'N/A';
          final userRole = userData?['role'] ?? 'N/A';
          final email = user.email ?? 'N/A'; 

          // Prepare data map to pass to edit screen
          final currentData = {
            'uid': user.uid,
            'name': name,
            'mobileNumber': mobileNumber,
            'userRole': userRole,
            'email': email, // Email is not editable in this screen, but useful for reference
          };

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Icon
                      const Center(child: Icon(Icons.account_circle, size: 80, color: Colors.deepPurple)),
                      const SizedBox(height: 16),
                      
                      // Data Fields
                      _buildProfileRow(label: "Name", value: name),
                      _buildProfileRow(label: "Email", value: email),
                      _buildProfileRow(label: "Mobile Number", value: mobileNumber),
                      _buildProfileRow(label: "User Role", value: userRole, isLast: true),
                      
                      const SizedBox(height: 30),
                      
                      // Edit Button (Green/Teal from design)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Text('Edit'),
                        onPressed: () => _handleEdit(context, currentData),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C49A), // Teal/Mint color
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Delete Account Button (Red from design)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete_forever, size: 20),
                        label: const Text('Delete Account'),
                        onPressed: () => _handleDeleteAccount(context, user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700, // Red
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
