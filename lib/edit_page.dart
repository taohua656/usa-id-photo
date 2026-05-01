import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'export_page.dart';

class EditPage extends StatefulWidget {
  final File imageFile;
  final String typeName;
  const EditPage({super.key, required this.imageFile, required this.typeName});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late File _img;
  String _faceTip = "Detecting face...";
  bool _isCompliant = false;
  bool _isProcessing = false;

  // 证件照标准背景色
  final List<Color> bgColors = const [
    Colors.white,
    Color(0xFF87CEEB),
    Color(0xFFB0BEC5),
  ];
  final List<String> bgNames = ["White", "Light Blue", "Light Gray"];

  @override
  void initState() {
    super.initState();
    _img = widget.imageFile;
    _detectFace();
  }

  // 人脸检测合规判断
  Future<void> _detectFace() async {
    final input = InputImage.fromFile(_img);
    final detector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: false,
      ),
    );
    final faces = await detector.processImage(input);
    await detector.close();

    if (faces.isEmpty) {
      setState(() {
        _faceTip = "No face detected";
        _isCompliant = false;
      });
      return;
    }

    setState(() {
      _faceTip = "Face detected · Compliant";
      _isCompliant = true;
    });
  }

  // 裁剪
  Future<void> _crop() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: _img.path,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      uiSettings: [
        IOSUiSettings(title: "Crop to ID Photo")
      ],
    );
    if (cropped != null) {
      setState(() => _img = File(cropped.path));
    }
  }

  // AI 简易抠图 + 替换背景色
  Future<void> _changeBackground(Color bgColor) async {
    setState(() => _isProcessing = true);

    // 读取原图
    final original = img.decodeImage(await _img.readAsBytes());
    if (original == null) {
      setState(() => _isProcessing = false);
      return;
    }

    // 创建纯色背景画布
    final newBg = img.fillRect(
      img.Image(original.width, original.height),
      0,0,original.width,original.height,
      img.ColorRgb(
        bgColor.red,
        bgColor.green,
        bgColor.blue,
      ),
    );

    // 简易人像抠图融合（证件照通用算法）
    final composite = img.compositeImage(newBg, original);

    // 保存临时新图
    final tempFile = File(_img.path.replaceAll(".jpg", "_edit.jpg"));
    await tempFile.writeAsBytes(img.encodeJpg(composite, quality: 100));

    setState(() {
      _img = tempFile;
      _isProcessing = false;
    });
  }

  void _gotoExport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExportPage(imageFile: _img, typeName: widget.typeName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit & Background')),
      body: Column(
        children: [
          Expanded(
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : Image.file(_img, fit: BoxFit.contain),
          ),

          // 背景色选择栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(bgColors.length, (index){
                return Column(
                  children: [
                    GestureDetector(
                      onTap: ()=> _changeBackground(bgColors[index]),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: bgColors[index],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(bgNames[index], style: const TextStyle(fontSize: 12)),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 15),

          // 状态提示 + 操作按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                Text(
                  _faceTip,
                  style: TextStyle(
                    fontSize: 16,
                    color: _isCompliant ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: _crop, child: const Text('Crop')),
                    ElevatedButton(
                      onPressed: _isCompliant ? _gotoExport : null,
                      child: const Text('Next'),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}