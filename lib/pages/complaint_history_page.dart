import 'package:flutter/material.dart';

class MyComplaintsPage extends StatelessWidget {
  final List<Map<String, dynamic>> complaints = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 60, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Welcome!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_box),
              title: Text('Complaint Box'),
              onTap: () {
                Navigator.pushNamed(context, '/complaint');
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('My Complaints'),
              onTap: () {
                Navigator.pop(context); // Already on this page
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("My Complaints"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: ExpansionTile(
              title: Text(
                complaint['title'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Status: ${complaint['status']}",
                  style: TextStyle(color: _getStatusColor(complaint['status']))),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description: ${complaint['description']}"),
                      SizedBox(height: 8),
                      Text("Submitted On: ${complaint['submittedAt']}"),
                      SizedBox(height: 8),
                      Text(
                        "Current Status: ${complaint['status']}",
                        style: TextStyle(
                          color: _getStatusColor(complaint['status']),
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
      ),
    );
  }
}
