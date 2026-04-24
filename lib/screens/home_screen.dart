import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (4, 5);

  @override
  String get name => '4x5(customized)';
}
class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  /// 从相机/相册选择图片并裁剪
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80, // 压缩图片质量，减少体积
    );

    if (pickedFile != null) {
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        // 美国证件照 4:5 比例
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 5),
        // ✅ 完全对齐官方示例的 uiSettings 数组写法
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop ID Photo',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square, // 用 square 替代 original
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPresetCustom(),
            ],
          ),
          IOSUiSettings(
            title: 'Crop ID Photo',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPresetCustom(),
            ],
          ),
        ],
      );

      // ✅ 修复异步上下文警告
      if (!mounted) return;

      if (cropped != null) {
        setState(() {
          // ✅ CroppedFile 转 File
          _imageFile = File(cropped.path);
        });
      }
    }
  }

  /// 保存裁剪后的图片到文档目录
  Future<void> _savePhoto() async {
    if (_imageFile == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'us_id_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savePath = '${dir.path}/$fileName';

    await _imageFile!.copy(savePath);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo saved successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 分享图片
  Future<void> _sharePhoto() async {
    if (_imageFile == null) return;
    Share.shareXFiles([XFile(_imageFile!.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('US ID Photo Maker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _imageFile == null
                ? const Center(child: Text('No image selected'))
                : Image.file(_imageFile!, fit: BoxFit.contain),
          ),
          const Divider(height: 1),
          _buildButtonBar(),
        ],
      ),
    );
  }

  Widget _buildButtonBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
          ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo),
            label: const Text('Gallery'),
          ),
          if (_imageFile != null)
            ElevatedButton.icon(
              onPressed: _savePhoto,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          if (_imageFile != null)
            ElevatedButton.icon(
              onPressed: _sharePhoto,
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
        ],
      ),
    );
  }
}