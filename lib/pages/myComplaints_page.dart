import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // REQUIRED
import 'package:firebase_auth/firebase_auth.dart';     // REQUIRED
import 'dart:convert';                                 // REQUIRED
import 'complaint_page.dart';

class MyComplaintsPage extends StatefulWidget {
  @override
  _MyComplaintsPageState createState() => _MyComplaintsPageState();
}

class _MyComplaintsPageState extends State<MyComplaintsPage> {
  bool isSidebarOpen = false;
  // NOTE: REMOVING THE HARDCODED 'complaints' LIST

  final User? currentUser = FirebaseAuth.instance.currentUser;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
      case 'Completed':
        return Colors.green;
      case 'In Progress':
      case 'Working':
        return Colors.orange;
      case 'Pending':
      default:
        return Colors.red;
    }
  }

  // Helper function to decode and display the Base64 image
  Widget _buildImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return const SizedBox.shrink(); // Hide if no image data is present
    }
    try {
      final imageBytes = base64Decode(base64String);
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
        ),
      );
    } catch (e) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Text('Error loading image proof'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double sidebarWidth = 250;
    Duration duration = Duration(milliseconds: 300);

    // Safety check for logged-in user
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your complaints.')),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8EDF9),
      body: Stack(
        children: [
          // Sidebar (UNCHANGED UI)
          AnimatedPositioned(
            duration: duration,
            left: isSidebarOpen ? 0 : -sidebarWidth,
            top: 0,
            bottom: 0,
            child: Container(
              width: sidebarWidth,
              color: Colors.deepPurple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                    color: Colors.deepPurple,
                    child: Text(
                      'LocalFix',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildDrawerItem(Icons.add, 'New Complaint'),
                  _buildDrawerItem(Icons.person, 'Profile'),
                  _buildDrawerItem(Icons.settings, 'Settings'),
                  Spacer(),
                  _buildDrawerItem(Icons.logout, 'Logout'),
                ],
              ),
            ),
          ),

          // Main content (UI UNCHANGED, DATA SOURCE CHANGED)
          AnimatedPositioned(
            duration: duration,
            left: isSidebarOpen ? sidebarWidth : 0,
            right: isSidebarOpen ? -sidebarWidth : 0,
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 8,
              borderRadius:
                  isSidebarOpen ? BorderRadius.circular(16) : BorderRadius.zero,
              child: Column(
                children: [
                  // Custom Top AppBar (UNCHANGED UI)
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: isSidebarOpen
                          ? BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            )
                          : BorderRadius.zero,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              isSidebarOpen = !isSidebarOpen;
                            });
                          },
                        ),
                        SizedBox(width: 8),
                        Text(
                          'My Complaints',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Complaints list (DATA SOURCE CHANGED TO STREAMBUILDER)
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      // 1. Fetch only the complaints belonging to the current user
                      stream: FirebaseFirestore.instance
                          .collection('complaints')
                          .where('userId', isEqualTo: currentUser!.uid) // CRITICAL FILTER
                          .orderBy('timestamp', descending: true) 
                          .snapshots(),
                      
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        // This handles the Index error you saw earlier
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Error loading complaints. Please ensure the Firestore Index is enabled. Error: ${snapshot.error}'),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('You have not filed any complaints yet.'));
                        }

                        final complaints = snapshot.data!.docs;
                        
                        return ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: complaints.length,
                          itemBuilder: (context, index) {
                            final complaintData = complaints[index].data() as Map<String, dynamic>;
                            final status = complaintData['status'] ?? 'Pending';
                            
                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              color: Colors.white,
                              elevation: 4,
                              child: ExpansionTile(
                                title: Text(
                                  complaintData['title'] ?? 'N/A',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Status: $status",
                                  style: TextStyle(
                                      color: _getStatusColor(status)),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 2. Display the Base64 Image proof
                                        _buildImage(complaintData['image_base64'] as String?), 
                                        
                                        Text("Description: ${complaintData['description'] ?? 'N/A'}"),
                                        SizedBox(height: 8),
                                        Text("Submitted On: ${complaintData['date'] ?? 'N/A'}"), 
                                        SizedBox(height: 8),
                                        Text(
                                          "Current Status: $status",
                                          style: TextStyle(
                                            color: _getStatusColor(status),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: () async {
        if (title == 'New Complaint') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ComplaintPage()),
          );
        } else if (title == 'Logout') {
          await FirebaseAuth.instance.signOut(); // Perform Firebase Logout
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title page coming soon!')),
          );
        }
      },
    );
  }
}