import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Service for handling product image uploads to Firebase Storage
class ProductImageService {
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  ProductImageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Upload a single image file
  Future<String> uploadImage({
    required String productId,
    required File imageFile,
    int quality = 85,
    int maxWidth = 1920,
  }) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage
          .ref()
          .child('products')
          .child(productId)
          .child(fileName);

      Uint8List bytes = await imageFile.readAsBytes();
      if (kIsWeb) {
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
      }

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload multiple images at once
  Future<List<String>> uploadImages({
    required String productId,
    required List<File> imageFiles,
    int quality = 85,
    int maxWidth = 1920,
    Function(double progress)? onProgress,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < imageFiles.length; i++) {
      final url = await uploadImage(
        productId: productId,
        imageFile: imageFiles[i],
        quality: quality,
        maxWidth: maxWidth,
      );
      urls.add(url);
      onProgress?.call((i + 1) / imageFiles.length);
    }
    return urls;
  }

  /// Upload image from bytes (for web)
  Future<String> uploadImageBytes({
    required String productId,
    required Uint8List bytes,
    String fileName = '',
  }) async {
    try {
      final name = fileName.isEmpty ? '${_uuid.v4()}.jpg' : fileName;
      final ref = _storage
          .ref()
          .child('products')
          .child(productId)
          .child(name);

      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete a single image by URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore if already deleted
    }
  }

  /// Delete all images for a product
  Future<void> deleteProductImages(String productId) async {
    try {
      final ref = _storage.ref().child('products').child(productId);
      final listResult = await ref.listAll();
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      // Ignore if already deleted
    }
  }

  /// Generate thumbnail URL (using Firebase Storage resize)
  String getThumbnailUrl(String imageUrl, {int width = 300, int height = 300}) {
    // Firebase Storage doesn't support dynamic resizing natively
    // This would need Cloud Functions or a separate thumbnail upload
    // For now, return original URL
    return imageUrl;
  }

  /// Get optimized image URLs for different sizes
  Map<String, String> getOptimizedUrls(String imageUrl) {
    return {
      'original': imageUrl,
      'thumbnail': imageUrl, // Would be generated via Cloud Function
      'medium': imageUrl,
      'large': imageUrl,
    };
  }
}