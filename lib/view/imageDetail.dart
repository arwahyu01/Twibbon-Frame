import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/AdsController.dart';
import '../service/Api.dart';

class ImageDetail extends StatefulWidget {
  ImageDetail({Key? key}) : super(key: key);

  @override
  State<ImageDetail> createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
  final result = Get.arguments['data'];
  final code = Get.arguments['code'];
  var isFavorite = false.obs;
  final ctrlAds = Get.put(AdsController());

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(result.name),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
                height: 250,
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(result.thumbnail),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 10,
                      left: 10,
                      child: Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: InkWell(
                          child: Obx(() => isFavorite.value
                              ? const Icon(Icons.favorite, color: Colors.red)
                              : const Icon(Icons.favorite_border, color: Colors.red)),
                          onTap: () => addToFavorite(),
                        ),
                      ),
                    ),
                  ],
                )),
            if (result.description != "")
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  result.description,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if(result.frames[index] == "ADS"){
                      return ctrlAds.showNativeAds(Get.width.toInt());
                    }else{
                      return InkWell(
                        onTap: () {
                          showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
                          ctrlAds.showInterstitialAd();
                          Future.delayed(const Duration(seconds: 2), () {
                            Get.back();
                            Get.toNamed('/imageEditor', arguments: "https://frame.twibbonize.com/${result.frames[index]}");
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                              image: NetworkImage("https://frame.twibbonize.com/${result.frames[index]}"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  itemCount: result.frames.length),
            )
          ],
        ));
  }

  addToFavorite() {
    SharedPreferences.getInstance().then((prefs) {
      var list = prefs.getStringList('favorite') ?? [];
      if (isFavorite.value) {
        isFavorite.value = false;
        list.remove(code);
        Get.snackbar("Remove from favorite", "Success remove from favorite",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: const EdgeInsets.all(10));
      } else {
        isFavorite.value = true;
        list.add(code);
        Get.snackbar("Add to favorite", "Success add to favorite",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            margin: const EdgeInsets.all(10));
      }
      prefs.setStringList('favorite', list);
    });
  }

  void checkFavorite() {
    SharedPreferences.getInstance().then((prefs) {
      var list = prefs.getStringList('favorite') ?? [];
      isFavorite.value = list.contains(code);
    });
  }
}
