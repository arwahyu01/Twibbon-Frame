import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_share/social_share.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../controller/AdsController.dart';
import '../service/api.dart';

class ImageScreen extends StatefulWidget {
  ImageScreen(this.image, {super.key});
  var image = "";

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
   final ctrlAds = Get.put(AdsController());
  @override
  void initState() {
    super.initState();
    ApiService.requestReviewApp();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Twibbon Creator'),
        actions: [
          IconButton(
            onPressed: () => shareImage(),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ctrlAds.showNativeAds(ApiService.adsSetting['size_home'] ?? Get.width.toInt()),
            const SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.width,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(Uri.parse(widget.image).path))
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
              child: ElevatedButton(
                onPressed: () => shareImage(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.share),
                    SizedBox(width: 10),
                    Text('Share Image'),
                  ],
                )
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Text("Your file in: ${Uri.parse(widget.image).path} (Internal Storage)",style: const TextStyle(fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }

  void shareImage() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    SocialShare.shareOptions(
      "This is my twibbon from ${packageInfo.appName} App. Download it now: https://play.google.com/store/apps/details?id=${packageInfo.packageName}",
      imagePath: Uri.parse(widget.image).path,
    );
  }
}
