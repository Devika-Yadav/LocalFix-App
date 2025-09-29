import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ComplaintPage extends StatefulWidget {
  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final titleController = TextEditingController();
  final complaintController = TextEditingController();
  final locationController = TextEditingController();

  File? selectedImage;
  String selectedCategory = 'Garbage';
  bool isLoading = false;

  final List<String> categories = ['Garbage', 'Road', 'Water', 'Lighting', 'Others'];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate() || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields & select an image")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      // Upload image to Firebase Storage
      final fileName = 'complaints/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uploadTask = FirebaseStorage.instance.ref(fileName).putFile(selectedImage!);
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Save to Firestore
      await FirebaseFirestore.instance.collection('complaints').add({
        'title': titleController.text.trim(),
        'description': complaintController.text.trim(),
        'category': selectedCategory,
        'location': locationController.text.trim(),
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'email': emailController.text.trim(),
        'image_url': imageUrl,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
        'date': DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Complaint submitted successfully ✅")),
      );

      // Reset form
      _formKey.currentState!.reset();
      setState(() {
        selectedImage = null;
        selectedCategory = 'Garbage';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(207, 48, 152, 243),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Complaint Form",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Image Picker
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: selectedImage == null
                          ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                          : Image.file(selectedImage!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Fields
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Problem Title"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: complaintController,
                    maxLines: 4,
                    decoration: InputDecoration(labelText: "Problem Description"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(labelText: "Category"),
                    items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val!),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(labelText: "Location", suffixIcon: Icon(Icons.location_on)),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 16),

                  // Reporter Info
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Your Name"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: "Mobile Number"),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email (optional)"),
                  ),
                  SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Submit Complaint", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
