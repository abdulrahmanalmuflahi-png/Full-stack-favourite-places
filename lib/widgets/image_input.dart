import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
 
class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});
 
  final void Function(String base64Image) onPickImage;
 
  @override
  State<ImageInput> createState() => _ImageInputState();
}
 
class _ImageInputState extends State<ImageInput> {
  File? _selectedImageFile;       // للموبايل
  Uint8List? _selectedImageBytes; // للـ web
 
  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: source,
      maxWidth: 600,
      imageQuality: 60, // ضغط الصورة
    );
    if (pickedImage == null) return;
 
    String base64String;
 
    if (kIsWeb) {
      // على الـ web نقرأ الـ bytes مباشرة
      final bytes = await pickedImage.readAsBytes();
      base64String = base64Encode(bytes);
      setState(() {
        _selectedImageBytes = bytes;
      });
    } else {
      // على الموبايل نستخدم File
      final bytes = await File(pickedImage.path).readAsBytes();
      base64String = base64Encode(bytes);
      setState(() {
        _selectedImageFile = File(pickedImage.path);
      });
    }
 
    widget.onPickImage(base64String);
  }
 
  void _showPickerOptions() {
    // على الـ web الكاميرا مو دايمًا متاحة
    if (kIsWeb) {
      _pickImage(ImageSource.gallery);
      return;
    }
 
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      icon: const Icon(Icons.camera),
      label: Text(kIsWeb ? 'Pick Picture' : 'Take / Pick Picture'),
      onPressed: _showPickerOptions,
    );
 
    if (kIsWeb && _selectedImageBytes != null) {
      content = GestureDetector(
        onTap: _showPickerOptions,
        child: Image.memory(
          _selectedImageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else if (!kIsWeb && _selectedImageFile != null) {
      content = GestureDetector(
        onTap: _showPickerOptions,
        child: Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
 
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
 