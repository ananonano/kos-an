import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Image Service
/// Mengelola operasi image picker dan upload
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal memilih gambar: ${e.toString()}');
    }
  }

  /// Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil foto: ${e.toString()}');
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.length > maxImages) {
        throw Exception('Maksimal $maxImages gambar');
      }

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      throw Exception('Gagal memilih gambar: ${e.toString()}');
    }
  }

  /// Show image source selection dialog
  static Future<File?> showImageSourceDialog({
    required Function(ImageSource) onSourceSelected,
  }) async {
    // This will be called from UI with showDialog
    // Return null for now, implementation in UI layer
    return null;
  }

  /// Upload image to Firebase Storage
  static Future<String> uploadToFirebase({
    required File imageFile,
    required String storagePath,
    String? fileName,
  }) async {
    try {
      // Generate unique filename if not provided
      final String uploadFileName = fileName ?? 
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';

      // Create reference to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child(storagePath)
          .child(uploadFileName);

      // Upload file
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Gagal upload gambar: ${e.toString()}');
    }
  }

  /// Upload multiple images to Firebase Storage
  static Future<List<String>> uploadMultipleToFirebase({
    required List<File> imageFiles,
    required String storagePath,
  }) async {
    try {
      final List<String> downloadUrls = [];

      for (final imageFile in imageFiles) {
        final String url = await uploadToFirebase(
          imageFile: imageFile,
          storagePath: storagePath,
        );
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      throw Exception('Gagal upload gambar: ${e.toString()}');
    }
  }

  /// Delete image from Firebase Storage
  static Future<void> deleteFromFirebase(String imageUrl) async {
    try {
      final Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      throw Exception('Gagal menghapus gambar: ${e.toString()}');
    }
  }

  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    final int bytes = file.lengthSync();
    return bytes / (1024 * 1024);
  }

  /// Validate image file
  static bool validateImage(File file, {double maxSizeMB = 5.0}) {
    // Check file size
    final double sizeMB = getFileSizeInMB(file);
    if (sizeMB > maxSizeMB) {
      throw Exception('Ukuran file terlalu besar. Maksimal $maxSizeMB MB');
    }

    // Check file extension
    final String extension = path.extension(file.path).toLowerCase();
    final List<String> allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
    
    if (!allowedExtensions.contains(extension)) {
      throw Exception('Format file tidak didukung. Gunakan JPG, PNG, atau GIF');
    }

    return true;
  }
}
