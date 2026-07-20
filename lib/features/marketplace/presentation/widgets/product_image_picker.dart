import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../application/providers/marketplace_providers.dart';

/// Widget for picking and uploading product images
class ProductImagePicker extends ConsumerStatefulWidget {
  const ProductImagePicker({
    super.key,
    required this.productId,
    this.initialImages = const [],
    this.maxImages = 10,
    this.onImagesChanged,
  });

  final String productId;
  final List<String> initialImages;
  final int maxImages;
  final ValueChanged<List<String>>? onImagesChanged;

  @override
  ConsumerState<ProductImagePicker> createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends ConsumerState<ProductImagePicker> {
  final ImagePicker _picker = ImagePicker();
  late List<String> _images;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  Future<void> _pickImages() async {
    if (_images.length >= widget.maxImages) return;

    final remainingSlots = widget.maxImages - _images.length;
    final List<XFile> pickedFiles = await _picker.pickMultiImage(limit: remainingSlots);

    if (pickedFiles.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final files = pickedFiles.map((f) => File(f.path)).toList();
      final imageService = ref.read(productImageServiceProvider);
      final urls = await imageService.uploadImages(
        productId: widget.productId,
        imageFiles: files,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      setState(() {
        _images.addAll(urls);
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      widget.onImagesChanged?.call(_images);
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_images.length >= widget.maxImages) return;

    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
    );

    if (photo == null) return;

    setState(() => _isUploading = true);

    try {
      final imageService = ref.read(productImageServiceProvider);
      final url = await imageService.uploadImage(
        productId: widget.productId,
        imageFile: File(photo.path),
      );

      setState(() {
        _images.add(url);
        _isUploading = false;
      });
      widget.onImagesChanged?.call(_images);
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onImagesChanged?.call(_images);
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Ürün Görselleri', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              if (_images.length < widget.maxImages) ...[
                FilledButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  label: const Text('Fotoğraf Çek'),
                  onPressed: _isUploading ? null : _takePhoto,
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  icon: const Icon(Icons.photo_library_outlined, size: 20),
                  label: const Text('Galeriden Seç'),
                  onPressed: _isUploading ? null : _pickImages,
                ),
              ],
            ],
          ),
          if (_isUploading) ...[
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(value: _uploadProgress, backgroundColor: AppColors.border),
            const SizedBox(height: AppSpacing.xs),
            Text('Yükleniyor... %${(_uploadProgress * 100).toInt()}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
          ],
          const SizedBox(height: AppSpacing.md),
          if (_images.isEmpty)
            _buildEmptyState()
          else
            _buildImageGrid(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return InkWell(
      onTap: _isUploading ? null : _pickImages,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text('Görsel Ekle', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('İlk görseli yüklemek için tıklayın', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: _images.length + (_images.length < widget.maxImages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _images.length) {
          return _buildAddButton();
        }
        return _buildImageItem(index);
      },
    );
  }

  Widget _buildImageItem(int index) {
    final imageUrl = _images[index];
    return Stack(
      key: ValueKey(imageUrl),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.card.withValues(alpha: 0.2),
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.error.withValues(alpha: 0.1),
              child: const Icon(Icons.broken_image, color: AppColors.error),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _removeImage(index),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('ANA', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: _isUploading ? null : _pickImages,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.textTertiary),
            const SizedBox(height: 4),
            Text('Ekle', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

/// Simple image gallery viewer for product details
class ProductImageGallery extends StatelessWidget {
  const ProductImageGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.heroTagPrefix = 'product_image',
  });

  final List<String> images;
  final int initialIndex;
  final String heroTagPrefix;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return _buildPlaceholder(context);
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: images.length,
          controller: PageController(initialPage: initialIndex),
          itemBuilder: (context, index) {
            final imageUrl = images[index];
            return Hero(
              tag: '${heroTagPrefix}_$index',
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
              ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == 0 ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: index == 0 ? 1.0 : 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppColors.card.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 64, color: AppColors.textTertiary),
      ),
    );
  }
}