import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myComplaints_page.dart';

class ComplaintSubmissionPage extends StatefulWidget {
  const ComplaintSubmissionPage({super.key});

  @override
  _ComplaintSubmissionPageState createState() =>
      _ComplaintSubmissionPageState();
}

class _ComplaintSubmissionPageState extends State<ComplaintSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  void _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('complaints').add({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint submitted successfully')),
        );

        // Go to My Complaints page after submission
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyComplaintsPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Complaint'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Complaint Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitComplaint,
                      child: Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
