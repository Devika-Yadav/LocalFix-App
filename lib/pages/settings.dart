import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Mock state for settings (In a real app, these would be saved to SharedPreferences or Firestore)
  bool _isDarkTheme = false;
  bool _complaintStatusNotifications = true;
  bool _adminUpdatesNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // --- Section 1: General Settings ---
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              'General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: _isDarkTheme,
                    onChanged: (bool value) {
                      setState(() {
                        _isDarkTheme = value;
                      });
                      // Placeholder: Apply theme change globally in a real app
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dark Mode: ${value ? 'On' : 'Off'}')),
                      );
                    },
                    activeColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- Section 2: Notification Settings ---
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Complaint Status Updates'),
                  subtitle: const Text('Get notified when your complaint status changes.'),
                  trailing: Switch(
                    value: _complaintStatusNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        _complaintStatusNotifications = value;
                      });
                    },
                    activeColor: Colors.deepPurple,
                  ),
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.campaign),
                  title: const Text('Receive Admin Announcements'),
                  subtitle: const Text('Updates on new features or community projects.'),
                  trailing: Switch(
                    value: _adminUpdatesNotifications,
                    onChanged: (bool value) {
                      setState(() {
                        _adminUpdatesNotifications = value;
                      });
                    },
                    activeColor: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // --- Section 3: Legal & About ---
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              'About LocalFix',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),

          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Privacy Policy...')),
                    );
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Terms of Service...')),
                    );
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(Icons.code),
                  title: Text('App Version'),
                  trailing: Text('1.0.0 (Build 42)', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}