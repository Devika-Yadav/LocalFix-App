import 'package:flutter/material.dart';

class AdminComplaintsPage extends StatefulWidget {
  @override
  _AdminComplaintsPageState createState() => _AdminComplaintsPageState();
}

class _AdminComplaintsPageState extends State<AdminComplaintsPage> {
  bool isSidebarOpen = false;

  List<Map<String, dynamic>> complaints = [
    {
      'title': 'Broken Street Light',
      'description': 'The light near my house has been broken for 3 days.',
      'status': 'In Progress',
      'submittedAt': '2025-08-01',
    },
    {
      'title': 'Potholes on Road',
      'description': 'Huge potholes causing traffic jams.',
      'status': 'Resolved',
      'submittedAt': '2025-07-30',
    },
    {
      'title': 'Garbage not collected',
      'description': 'Garbage is not picked up from Sector 7A for 5 days.',
      'status': 'Pending',
      'submittedAt': '2025-08-03',
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _updateStatus(int index, String newStatus) {
    setState(() {
      complaints[index]['status'] = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    double sidebarWidth = 250;
    Duration duration = Duration(milliseconds: 300);

    return Scaffold(
      backgroundColor: Color(0xFFF8EDF9),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                    child: Text(
                      'LocalFix',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildDrawerItem(Icons.person, 'Profile'),
                  _buildDrawerItem(Icons.settings, 'Settings'),
                  Spacer(),
                  _buildDrawerItem(Icons.logout, 'Logout'),
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
              borderRadius:
                  isSidebarOpen ? BorderRadius.circular(16) : BorderRadius.zero,
              child: Column(
                children: [
                  // Top App Bar
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
                          'Admin Complaints',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Complaint List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: complaints.length,
                      itemBuilder: (context, index) {
                        final complaint = complaints[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          elevation: 4,
                          child: ExpansionTile(
                            title: Text(
                              complaint['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Status: ${complaint['status']}",
                              style: TextStyle(
                                color: _getStatusColor(complaint['status']),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Description: ${complaint['description']}"),
                                    SizedBox(height: 8),
                                    Text("Submitted On: ${complaint['submittedAt']}"),
                                    SizedBox(height: 12),
                                    Text(
                                      "Change Status:",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              _updateStatus(index, "In Progress"),
                                          child: Text("In Progress"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _updateStatus(index, "Resolved"),
                                          child: Text("Resolved"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
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

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: () {
        if (title == 'Logout') {
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
