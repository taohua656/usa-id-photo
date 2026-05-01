import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_page.dart';

class CapturePage extends StatefulWidget {
  final String typeName;
  const CapturePage({super.key, required this.typeName});

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takeFromCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (file != null) _gotoEdit(File(file.path));
  }

  Future<void> _pickFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (file != null) _gotoEdit(File(file.path));
  }

  void _gotoEdit(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPage(imageFile: file, typeName: widget.typeName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.typeName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_camera, size: 100, color: Colors.blueGrey),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _takeFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}