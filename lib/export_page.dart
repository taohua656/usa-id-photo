import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;

class ExportPage extends StatefulWidget {
  final File imageFile;
  final String typeName;
  const ExportPage({super.key, required this.imageFile, required this.typeName});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  File? _layout4File;
  bool _layoutLoading = false;

  // 生成4宫格排版证件照
  Future<void> _generate4Layout() async {
    setState(() => _layoutLoading = true);
    final bytes = await widget.imageFile.readAsBytes();
    final srcImg = img.decodeImage(bytes);
    if (srcImg == null) {
      setState(() => _layoutLoading = false);
      return;
    }

    // 统一缩放到标准2寸证件照尺寸
       const int w = 826;
    const int h = 1158;
    final resizeImg = img.copyResize(srcImg, width: w, height: h);

    // 整张画布留白边
       final canvasW = 1732;
    final canvasH = 2396;
    final canvas = img.Image(canvasW, canvasH);
    img.fill(canvas, img.ColorRgb(255, 255, 255));

    // 四张摆放位置
    img.copyInto(canvas, resizeImg, dstX: 20, dstY: 20);
    img.copyInto(canvas, resizeImg, dstX: w + 40, dstY: 20);
    img.copyInto(canvas, resizeImg, dstX: 20, dstY: h + 40);
    img.copyInto(canvas, resizeImg, dstX: w + 40, dstY: h + 40);

    // 保存排版图到临时文件
    final layoutPath = widget.imageFile.path.replaceAll(".jpg", "_4layout.jpg");
    final layoutFile = File(layoutPath);
    await layoutFile.writeAsBytes(img.encodeJpg(canvas, quality: 100));

    setState(() {
      _layout4File = layoutFile;
      _layoutLoading = false;
    });
  }

  Future<void> _saveToAlbum(File file) async {
    await ImageGallerySaver.saveFile(file.path);
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to Album')),
      );
    }
  }

  Future<void> _shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)],
        subject: '${widget.typeName} ID Photo');
  }

  @override
  void initState() {
    super.initState();
    // 进入页面自动生成4宫格
    _generate4Layout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export & Print Layout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Single ID Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(height: 220, child: Image.file(widget.imageFile)),

            const SizedBox(height: 30),
            const Text("4-Print Layout（For Printing）", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _layoutLoading
                ? const SizedBox(height: 220, child: Center(CircularProgressIndicator()))
                : _layout4File != null
                    ? SizedBox(height: 220, child: Image.file(_layout4File!))
                    : const Text("Generate failed"),

            const SizedBox(height: 30),

            // 单张保存/分享
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: ()=>_saveToAlbum(widget.imageFile),
                icon: const Icon(Icons.save_alt),
                label: const Text('Save Single Photo'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: ()=>_shareFile(widget.imageFile),
                icon: const Icon(Icons.share),
                label: const Text('Share Single Photo'),
              ),
            ),

            // 排版图保存/分享
            if(_layout4File != null)
              const SizedBox(height: 20),
            if(_layout4File != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: ()=>_saveToAlbum(_layout4File!),
                  icon: const Icon(Icons.print),
                  label: const Text('Save 4-Print Layout'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}