import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert'; // Required to decode the Base64 image string
import 'profile.dart';
import 'settings.dart';

class AdminComplaintsPage extends StatefulWidget {
  @override
  _AdminComplaintsPageState createState() => _AdminComplaintsPageState();
}

class _AdminComplaintsPageState extends State<AdminComplaintsPage> {
  bool isSidebarOpen = false;
  // State variable to hold the currently selected filter
  String currentFilter = 'All Cases'; 
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Working':
        return Colors.orange;
      case 'Pending':
      default:
        return Colors.red;
    }
  }

  // CORE LOGIC: Update the status in Firestore
  Future<void> _updateStatus(String complaintId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      // In a real app, you'd check e.code for permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status. Check Firestore Rules.')),
      );
    }
  }

  // Helper function to build the main query based on the filter
  Stream<QuerySnapshot> _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('complaints');

    if (currentFilter != 'All Cases') {
      query = query.where('status', isEqualTo: currentFilter);
    }
    
    // Always order by timestamp for consistent display (newest first)
    query = query.orderBy('timestamp', descending: true);
    
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    double sidebarWidth = 250;
    Duration duration = const Duration(milliseconds: 300);

    return Scaffold(
      backgroundColor: const Color(0xFFF8EDF9),
      body: Stack(
        children: [
          // Sidebar 
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                    child: const Text(
                      'LocalFix',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Navigation Filters (Status-based menu items)
                  _buildDrawerItem(Icons.all_inclusive, 'All Cases', filter: 'All Cases'),
                  _buildDrawerItem(Icons.timelapse, 'Pending', filter: 'Pending'),
                  _buildDrawerItem(Icons.settings_suggest, 'Working', filter: 'Working'),
                  _buildDrawerItem(Icons.done_all, 'Completed', filter: 'Completed'),
                  
                  // Original UI items
                  _buildDrawerItem(Icons.person, 'Profile', filter: 'Profile'),
                  _buildDrawerItem(Icons.settings, 'Settings', filter: 'Settings'),
                  const Spacer(),
                  _buildDrawerItem(Icons.logout, 'Logout', filter: 'Logout'),
                ],
              ),
            ),
          ),

          // Main content
          AnimatedPositioned(
            duration: duration,
            left: isSidebarOpen ? sidebarWidth : 0,
            right: isSidebarOpen ? -sidebarWidth : 0,
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 8,
              borderRadius: isSidebarOpen ? BorderRadius.circular(16) : BorderRadius.zero,
              child: Column(
                children: [
                  // Top App Bar
                  Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: isSidebarOpen
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            )
                          : BorderRadius.zero,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              isSidebarOpen = !isSidebarOpen;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Admin Complaints: $currentFilter', 
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Complaint List (USES STREAMBUILDER)
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _buildQuery(), 
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error loading complaints: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No complaints found for status: $currentFilter.'));
                        }

                        final complaints = snapshot.data!.docs;
                        
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: complaints.length,
                          itemBuilder: (context, index) {
                            final complaintData = complaints[index].data() as Map<String, dynamic>;
                            final complaintId = complaints[index].id;
                            final status = complaintData['status'] ?? 'Pending';
                            
                            return ComplaintCard(
                              complaintId: complaintId,
                              complaintData: complaintData,
                              status: status,
                              getStatusColor: _getStatusColor,
                              updateStatus: _updateStatus,
                            );
                          },
                        );
                      },
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

  // Modified Drawer Item to handle status filtering
  Widget _buildDrawerItem(IconData icon, String title, {required String filter}) {
    bool isSelected = filter == currentFilter;
    return ListTile(
      tileColor: isSelected ? Colors.deepPurple.shade700 : null,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: () async {
        if (filter == 'Logout') {
          await FirebaseAuth.instance.signOut();
          // Navigate back to the login page (or first route)
          Navigator.popUntil(context, (route) => route.isFirst); 
        }else if (filter == 'Profile') {
        // --- THIS BLOCK IS MODIFIED TO OPEN PROFILEPAGE ---
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        // We close the sidebar upon navigation
        setState(() {
          isSidebarOpen = false;
        });
        // --------------------------------------------------
      } else if (filter == 'Settings') {
         Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        // We close the sidebar upon navigation
        setState(() {
          isSidebarOpen = false;
        });
      }  else {
          // Set the filter and close the sidebar
          setState(() {
            currentFilter = filter;
            isSidebarOpen = false;
          });
        }
      },
    );
  }
}

// -------------------------------------------------------------
// SEPARATE WIDGET FOR COMPLAINT CARD (with Status Buttons)
// -------------------------------------------------------------
class ComplaintCard extends StatelessWidget {
  final String complaintId;
  final Map<String, dynamic> complaintData;
  final String status;
  final Color Function(String) getStatusColor;
  final Future<void> Function(String, String) updateStatus;

  const ComplaintCard({
    required this.complaintId,
    required this.complaintData,
    required this.status,
    required this.getStatusColor,
    required this.updateStatus,
    super.key,
  });

  Widget _buildImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return const SizedBox.shrink();
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
      return const Text('Error loading image proof');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 4,
      child: ExpansionTile(
        title: Text(
          complaintData['title'] ?? 'N/A',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Status: $status",
          style: TextStyle(color: getStatusColor(status)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(complaintData['image_base64'] as String?),
                Text("Description: ${complaintData['description'] ?? 'N/A'}"),
                const SizedBox(height: 8),
                Text("Submitted On: ${complaintData['date'] ?? 'N/A'}"),
                Text("Reporter: ${complaintData['name'] ?? 'N/A'}"),
                Text("Mobile Number: ${complaintData['mobile'] ?? 'N/A'}"),
                Text("Location: ${complaintData['location'] ?? 'N/A'}"),
                const SizedBox(height: 12),
                
                // Status Update Buttons Section
                const Text(
                  "Change Status:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Button 1: Mark Working (for Pending or Completed to revisit)
                    if (status == 'Pending')
                      ElevatedButton.icon(
                        icon: const Icon(Icons.engineering, size: 18),
                        label: const Text("Mark Working"),
                        onPressed: () => updateStatus(complaintId, "Working"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),

                    // Button 2: Mark Completed (for Working complaints)
                    if (status == 'Working')
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text("Mark Completed"),
                        onPressed: () => updateStatus(complaintId, "Completed"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
                
                // Show a message if it's already completed and no further action is expected
                if (status == 'Completed')
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'This complaint is marked as Completed.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}