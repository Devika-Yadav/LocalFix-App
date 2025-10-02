import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  final bool isDarkTheme;
  // Non-constant constructor for StatelessWidget
  TermsOfServicePage({super.key, required this.isDarkTheme}); 

  // Theme colors based on the settings page
  Color get _backgroundColor => isDarkTheme ? const Color(0xFF121212) : Colors.white;
  Color get _textColor => isDarkTheme ? Colors.white : Colors.black87;
  Color get _headerColor => isDarkTheme ? const Color(0xFF00C49A) : Colors.deepPurple;
  
  // Mock Policy Content for a simple college student app
  final Map<String, String> tosSections = {
    "Acceptance of Terms": 
        "By accessing or using the LocalFix application (the \"Service\"), you agree to be bound by these Terms of Service. If you disagree with any part of the terms, then you may not access the Service.",
    "User Responsibility": 
        "You are solely responsible for all content (complaints, images, comments) that you submit. You agree not to post any content that is false, defamatory, abusive, obscene, or violates any laws.",
    "Content and Complaints": 
        "All complaints and associated data posted to LocalFix are considered public and may be used by the college administration for problem resolution. Do not post sensitive or private information.",
    "Limitations of Service": 
        "LocalFix is provided on an \"AS IS\" and \"AS AVAILABLE\" basis. We make no guarantees regarding the timeliness or success of resolving reported issues.",
    "Termination": 
        "We may terminate or suspend your account immediately, without prior notice, for any breach of these Terms, particularly if you misuse the complaint system or harass others.",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
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
              "LocalFix Terms of Service",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _headerColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Effective Date: October 2, 2025",
              style: TextStyle(
                fontSize: 14,
                color: _textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 25),
            
            // Generate sections dynamically
            ...tosSections.entries.map((entry) {
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
