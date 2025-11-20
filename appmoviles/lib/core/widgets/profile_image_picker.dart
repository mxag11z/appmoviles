import 'dart:io';
import 'package:flutter/material.dart';



// Widget para seleccionar la imagen 
class ProfileImagePicker extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onPickImage;
  final double size;

  const ProfileImagePicker({
    super.key,
    required this.imageFile,
    required this.onPickImage,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          color: Colors.grey.shade200,
          image: imageFile != null
              ? DecorationImage(
                  image: FileImage(imageFile!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imageFile == null
            ? const Icon(Icons.camera_alt_outlined, size: 34)
            : null,
      ),
    );
  }
}
