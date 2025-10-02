import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'privacy_policy_page.dart'; 
import 'terms_of_service_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // We use late variables initialized by the StreamBuilder
  late bool _isDarkTheme;
  late bool _complaintStatusNotifications;
  late bool _adminUpdatesNotifications;
  
  // Get the current user ID for Firestore operations
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Branding Colors (These are fixed, the rest change based on state)
  final Color _primaryColor = Colors.deepPurple;
  final Color _activeSwitchColor = const Color(0xFF00C49A); 

  // --- Theme Helper Functions for Local Simulation (Visuals on this page) ---
  Color _getScaffoldBackgroundColor() => _isDarkTheme ? const Color(0xFF121212) : Colors.white;
  Color _getCardColor() => _isDarkTheme ? const Color(0xFF1F1F1F) : Colors.white;
  Color _getTextColor() => _isDarkTheme ? Colors.white : Colors.black87;
  Color _getSecondaryTextColor() => _isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade600;

  // --- Core Functions ---

  // Function to save a single setting change to Firestore
  Future<void> _saveSetting(String key, bool value) async {
    if (_currentUser == null) return;
    
    try {
      // Use update to save the setting to the user's document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
            key: value,
          });
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${key} updated successfully!')),
      );
    } catch (e) {
      print('Error updating setting $key: $e'); 
    }
  }

  // NOTE: The _handleLogout function has been removed as requested.

  // --- Utility Widgets ---

  Widget _buildSwitchListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: _isDarkTheme ? _activeSwitchColor : _primaryColor),
      title: Text(
        title,
        style: TextStyle(color: _getTextColor()),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: _getSecondaryTextColor()),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: _activeSwitchColor,
        inactiveThumbColor: _getSecondaryTextColor(),
        inactiveTrackColor: _getSecondaryTextColor().withOpacity(0.3),
      ),
    );
  }

  Widget _buildActionListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _isDarkTheme ? _activeSwitchColor : _primaryColor),
      title: Text(
        title,
        style: TextStyle(color: _getTextColor()),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: Text('Please log in to manage settings.')),
      );
    }

    // Use a StreamBuilder to listen for real-time changes to the settings document
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        
        // Handle loading and errors
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            appBar: null, // Don't show app bar during initial load
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
           return Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: Center(child: Text('Error loading settings: ${snapshot.error}')),
          );
        }

        // Extract data, using safe defaults if the document or fields are missing
        final data = snapshot.data?.data() as Map<String, dynamic>?;

        // Set state variables based on fetched data or defaults
        // Default to false for Dark Mode, true for Complaint Notifications, false for Admin
        _isDarkTheme = data?['isDarkTheme'] ?? false;
        _complaintStatusNotifications = data?['complaintNotifications'] ?? true;
        _adminUpdatesNotifications = data?['adminNotifications'] ?? false;

        return Scaffold(
          backgroundColor: _getScaffoldBackgroundColor(),
          appBar: AppBar(
            title: const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: _primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              // --- Section 1: General Settings (Theme) ---
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text('General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
              ),
              Card(
                elevation: 4,
                color: _getCardColor(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    // Dark Mode Switch Implementation (Saves to Firestore)
                    _buildSwitchListTile(
                      icon: _isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                      title: 'Dark Mode',
                      value: _isDarkTheme,
                      onChanged: (bool value) {
                        // Use local setState for visual change
                        // The stream builder will handle global theme change
                        setState(() { _isDarkTheme = value; });
                        _saveSetting('isDarkTheme', value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- Section 2: Notification Settings (Persistence) ---
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
              ),
              Card(
                elevation: 4,
                color: _getCardColor(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildSwitchListTile(
                      icon: Icons.info_outline,
                      title: 'Complaint Status Updates',
                      subtitle: 'Get notified when your complaint status changes.',
                      value: _complaintStatusNotifications,
                      onChanged: (bool value) {
                        setState(() { _complaintStatusNotifications = value; });
                        _saveSetting('complaintNotifications', value);
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _buildSwitchListTile(
                      icon: Icons.campaign,
                      title: 'Receive Admin Announcements',
                      subtitle: 'Updates on new features or community projects.',
                      value: _adminUpdatesNotifications,
                      onChanged: (bool value) {
                        setState(() { _adminUpdatesNotifications = value; });
                        _saveSetting('adminNotifications', value);
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // --- Section 3: Legal & About ---
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text('About LocalFix', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor)),
              ),
              Card(
                elevation: 4,
                color: _getCardColor(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildActionListTile(
                      icon: Icons.lock,
                      title: 'Privacy Policy',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage(isDarkTheme: _isDarkTheme)));
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _buildActionListTile(
                      icon: Icons.description,
                      title: 'Terms of Service',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TermsOfServicePage(isDarkTheme: _isDarkTheme)));
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    _buildActionListTile(
                      icon: Icons.code,
                      title: 'App Version',
                      trailing: Text('1.0.0 (Build 42)', style: TextStyle(color: _getSecondaryTextColor())),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
