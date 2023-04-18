import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_v3/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:external_path/external_path.dart';
import 'ImageScreen.dart';
import '../controller/AdsController.dart';

class ImageEditor extends StatefulWidget {
  const ImageEditor({super.key});

  @override
  _ImageEditorState createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  Offset _offset = Offset.zero;
  final GlobalKey _imageKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  final ctrlAds = Get.put(AdsController());
  var _imageScale = 1.0;
  var url = Get.arguments;
  List<XFile>? _imageFileList;
  static BoxDecoration boxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    gradient: const LinearGradient(
      colors: [Colors.green, Colors.blue],
    ),
  );

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Your Twibbon'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RepaintBoundary(
            key: _imageKey,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() => _offset += details.delta);
              },
              child: Stack(
                key: const Key('imageStack'),
                children: [
                  if(_imageFileList != null)
                  Transform.scale(
                    key: const Key('imageScale'),
                    scale: _imageScale,
                    child: Transform.translate(
                      offset: _offset,
                      child: Image.file(
                        File(_imageFileList![0].path),
                        width: 300,
                        height: 300,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return const Text('Image not found');
                        },
                      ),
                    ),
                  ),
                  Image.network(
                    url,
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      return const Text('Image not found');
                    },
                    height: MediaQuery.of(context).size.width,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () => setState(() => _imageScale += 0.1),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            height: 50,
                            decoration: boxDecoration,
                            child: Row(
                              children: const [
                                Icon(Icons.zoom_in),
                                SizedBox(width: 10),
                                Text('Zoom in', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _imageScale -= 0.1),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            height: 50,
                            decoration: boxDecoration,
                            child: Row(
                              children: const [
                                Icon(Icons.zoom_out),
                                SizedBox(width: 10),
                                Text('Zoom out', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () => openGallery(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            height: 50,
                            decoration: boxDecoration,
                            child: Row(
                              children: const [
                                Icon(Icons.cloud_upload),
                                SizedBox(width: 10),
                                Text('Upload Image', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => takePhoto(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            height: 50,
                            decoration: boxDecoration,
                            child: Row(
                              children: const [
                                Icon(Icons.camera_alt),
                                SizedBox(width: 10),
                                Text('Take a photo', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        showLoaderDialog(context);
                        renderImage();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(colors: [Colors.green, Colors.orange]),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.save),
                            SizedBox(width: 10),
                            Text('Save to gallery', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(padding: const EdgeInsets.all(5), child: ctrlAds.showNativeAds(100)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _requestPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted) {
        await Permission.storage.request();
      }
    }
  }

  saveToGallery(Uint8List? pngBytes) async {
    var uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
    final result = await ImageGallerySaver.saveImage(pngBytes!, quality: 80, name: "image-$uniqueName");
    if (result['isSuccess'] == true) {
      Get.back();
      ctrlAds.showInterstitialAd();
      Future.delayed(const Duration(seconds: 2), () async {
        if(File(result['filePath']).existsSync()){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ImageScreen(result['filePath'])));
        }else{
          var tempDir = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_PICTURES);
          var filePath = '${tempDir.toString()}/image-$uniqueName.jpg';
          if(File(filePath).existsSync()) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ImageScreen(filePath)));
          }else{
            const SnackBar(content: Text('Image not saved to gallery'));
          }
        }
      });
    } else {
      Get.back();
      const SnackBar(content: Text('Image not saved to gallery'));
    }
  }

  Future<void> renderImage() async {
    RenderRepaintBoundary boundary = _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    await saveToGallery(pngBytes);
  }

  void openGallery(BuildContext context) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _setImageFileListFromFile(pickedFile));
    }
  }

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  void takePhoto(BuildContext context) {
    _picker.pickImage(source: ImageSource.camera).then((XFile? value) {
      setState(() => _setImageFileListFromFile(value));
    });
  }

  void showLoaderDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
  }
}
