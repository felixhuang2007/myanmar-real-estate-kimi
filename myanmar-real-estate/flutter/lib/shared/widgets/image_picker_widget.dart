/**
 * 公共组件 - 图片选择/上传组件
 */
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';

class ImagePickerWidget extends StatefulWidget {
  final List<String> initialImages;
  final int maxImages;
  final int? imageWidth;
  final int? imageHeight;
  final double? compressQuality;
  final Function(List<File>) onImagesChanged;
  final List<String>? requiredLabels;

  const ImagePickerWidget({
    super.key,
    this.initialImages = const [],
    this.maxImages = 9,
    this.imageWidth,
    this.imageHeight,
    this.compressQuality,
    required this.onImagesChanged,
    this.requiredLabels,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ..._buildImageItems(),
        if (_images.length < widget.maxImages) _buildAddButton(),
      ],
    );
  }

  List<Widget> _buildImageItems() {
    return _images.asMap().entries.map((entry) {
      final index = entry.key;
      final image = entry.value;
      final label = widget.requiredLabels != null && index < widget.requiredLabels!.length
          ? widget.requiredLabels![index]
          : null;

      return Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 删除按钮
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.red600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          // 必传标签
          if (label != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      );
    }).toList();
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.gray300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: AppColors.gray500),
            const SizedBox(height: 4),
            Text(
              '${_images.length}/${widget.maxImages}',
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: widget.imageWidth?.toDouble() ?? 1920,
        maxHeight: widget.imageHeight?.toDouble() ?? 1080,
        imageQuality: (widget.compressQuality ?? 0.8 * 100).toInt(),
      );

      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
        widget.onImagesChanged(_images);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onImagesChanged(_images);
  }
}

/**
 * 图片预览组件
 */
class ImagePreviewWidget extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const ImagePreviewWidget({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: PageView.builder(
        itemCount: images.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                images[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.gray800,
                  child: Icon(Icons.broken_image, color: AppColors.gray500),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
