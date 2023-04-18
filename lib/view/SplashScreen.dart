import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controller/SplashController.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  final ctrl = Get.put(SplashController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: const [
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 5,
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Icon(Icons.filter_frames_outlined, size: 100, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
