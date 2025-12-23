import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class CloudinaryService {
  // Replace these with your actual Cloudinary credentials
  static const String cloudName = 'ddwmcikmw';
  static const String uploadPreset = 'safe-voice';
  
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));

  /// Upload image to Cloudinary with progress callback
  /// Returns the secure URL of the uploaded image
  Future<String> uploadImage(File imageFile, {Function(double)? onProgress}) async {
    try {
      print('CloudinaryService: Starting upload to Cloudinary');
      print('CloudinaryService: File path: ${imageFile.path}');
      print('CloudinaryService: File exists: ${await imageFile.exists()}');
      print('CloudinaryService: File size: ${await imageFile.length()} bytes');
      
      // Get file name and extension
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final extension = fileName.split('.').last.toLowerCase();
      
      print('CloudinaryService: File name: $fileName');
      print('CloudinaryService: Extension: $extension');
      
      // Determine content type
      String contentType = 'image/jpeg';
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'gif') {
        contentType = 'image/gif';
      } else if (extension == 'webp') {
        contentType = 'image/webp';
      }

      print('CloudinaryService: Content type: $contentType');
      print('CloudinaryService: Cloud name: $cloudName');
      print('CloudinaryService: Upload preset: $uploadPreset');

      // Create form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
        'upload_preset': uploadPreset,
        'folder': 'safe_voice/reports', // Organize uploads in folders
      });

      print('CloudinaryService: Form data created, starting upload...');

      // Upload to Cloudinary
      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
        onSendProgress: (sent, total) {
          final progress = sent / total;
          print('CloudinaryService: Upload progress: ${(progress * 100).toStringAsFixed(1)}% ($sent / $total bytes)');
          if (onProgress != null) {
            onProgress(progress * 0.9); // Reserve 10% for processing
          }
        },
      );

      print('CloudinaryService: Upload complete, status code: ${response.statusCode}');
      print('CloudinaryService: Response: ${response.data}');

      if (response.statusCode == 200) {
        // Extract secure URL from response
        final secureUrl = response.data['secure_url'] as String;
        final publicId = response.data['public_id'] as String;
        
        print('CloudinaryService: ✅ SUCCESS!');
        print('CloudinaryService: Image URL: $secureUrl');
        print('CloudinaryService: Public ID: $publicId');

        if (onProgress != null) {
          onProgress(1.0); // 100% complete
        }

        return secureUrl;
      } else {
        throw Exception('Upload failed with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('CloudinaryService: ❌ DioException occurred');
      print('CloudinaryService: Error type: ${e.type}');
      print('CloudinaryService: Error message: ${e.message}');
      if (e.response != null) {
        print('CloudinaryService: Response status: ${e.response?.statusCode}');
        print('CloudinaryService: Response data: ${e.response?.data}');
        final errorMsg = e.response?.data is Map 
            ? (e.response?.data['error']?['message'] ?? e.response?.data['message'] ?? 'Unknown error')
            : 'Upload failed';
        throw Exception('Upload failed: $errorMsg');
      } else {
        print('CloudinaryService: Network error - no response received');
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('CloudinaryService: ❌ Unexpected error occurred');
      print('CloudinaryService: Error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload multiple images to Cloudinary with overall progress
  Future<List<String>> uploadMultipleImages(List<File> imageFiles, {Function(double)? onProgress}) async {
    final List<String> uploadedUrls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      print('CloudinaryService: Uploading image ${i + 1} of ${imageFiles.length}');
      try {
        final url = await uploadImage(
          imageFiles[i],
          onProgress: (progress) {
            // Calculate overall progress across all images
            final overallProgress = (i + progress) / imageFiles.length;
            if (onProgress != null) {
              onProgress(overallProgress);
            }
          },
        );
        uploadedUrls.add(url);
        print('CloudinaryService: Image ${i + 1} uploaded successfully');
      } catch (e) {
        print('CloudinaryService: ❌ Failed to upload image ${i + 1}: $e');
        // Continue with other images even if one fails
      }
    }
    
    print('CloudinaryService: Upload complete. ${uploadedUrls.length} of ${imageFiles.length} images uploaded');
    return uploadedUrls;
  }

  /// Delete image from Cloudinary (optional - requires authenticated API)
  /// You would need to implement server-side deletion for security
  Future<void> deleteImage(String publicId) async {
    // This typically requires your API secret, which should NOT be in client code
    // Implement this on your backend instead
    throw UnimplementedError('Delete should be implemented on backend for security');
  }
}
