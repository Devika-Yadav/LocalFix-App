import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  final bool isDarkTheme;
  // REMOVED 'const' keyword from constructor
  PrivacyPolicyPage({super.key, required this.isDarkTheme}); 

  // Mock Policy Content - REMOVED 'final' to allow non-constant initialization
  final Map<String, String> policySections = {
    "Introduction": 
        "Welcome to LocalFix. We respect your privacy and are committed to protecting your personally identifiable information. This Privacy Policy explains what information we collect, how we use it, and your choices regarding your information.",
    "Information We Collect": 
        "We collect two types of information: (1) Personal Data (Name, Email, Mobile Number, User ID for account purposes) provided during registration and profile editing, and (2) Complaint Data (Location, description, images) which is publicly accessible to the relevant authorities and other users.",
    "How We Use Your Information": 
        "Your Personal Data is used to manage your account and send essential notifications (like status updates). Complaint Data is used solely for the purpose of addressing and tracking community issues.",
    "Data Sharing and Disclosure": 
        "We do not sell or rent your Personal Data to third parties. Complaint Data is shared with administrative bodies and is visible to the public within the app to foster transparency.",
    "Security": 
        "We implement security measures designed to protect your information from unauthorized access, alteration, disclosure, or destruction. However, no internet transmission is 100% secure.",
    "Your Rights": 
        "You have the right to access, correct, or delete your Personal Data at any time through the Profile page.",
  };

  // Theme colors based on the settings page
  Color get _backgroundColor => isDarkTheme ? const Color(0xFF121212) : Colors.white;
  Color get _textColor => isDarkTheme ? Colors.white : Colors.black87;
  Color get _headerColor => isDarkTheme ? const Color(0xFF00C49A) : Colors.deepPurple;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text( // Using const here is fine because the content is static
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LocalFix Privacy Policy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _headerColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Last updated: October 2, 2025",
              style: TextStyle(
                fontSize: 14,
                color: _textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 25),
            
            // Generate sections dynamically
            ...policySections.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _headerColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: _textColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
