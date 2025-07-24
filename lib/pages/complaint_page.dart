import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ComplaintPage extends StatefulWidget {
  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  File? selectedImage;
  String selectedCategory = 'Garbage';

  final List<String> categories = ['Garbage', 'Road', 'Water', 'Lighting', 'Others'];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  void _submitComplaint(BuildContext context) {
    if (nameController.text.isEmpty ||
        mobileController.text.isEmpty ||
        titleController.text.isEmpty ||
        complaintController.text.isEmpty ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all mandatory fields")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Complaint submitted (dummy)!")),
    );

    // Clear all fields
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    titleController.clear();
    complaintController.clear();
    locationController.clear();
    setState(() {
      selectedImage = null;
      selectedCategory = 'Garbage';
    });
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Complaint Form",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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

                // Problem Info
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Problem Title"),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: complaintController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Problem Description",
                    alignLabelWithHint: true,
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(labelText: "Category"),
                  items: categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedCategory = val!),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: "Location (required)",
                    suffixIcon: Icon(Icons.location_on),
                  ),
                ),
                SizedBox(height: 16),

                // Reporter Info
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Your Name"),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: "Mobile Number"),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email (optional)"),
                ),
                SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submitComplaint(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Submit Complaint",
                      style: TextStyle(color: Colors.white), // Button text is white
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
