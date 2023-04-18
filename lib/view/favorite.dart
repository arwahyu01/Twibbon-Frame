import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/AdsController.dart';
import '../service/api.dart';

class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  var favoriteList = [].obs;
  final ctrlAds = Get.put(AdsController());

  @override
  void initState() {
    super.initState();
    getFavoriteList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Favorite Twibbon'),
        ),
        body: Column(
          children: [
            Padding(padding: const EdgeInsets.all(10), child: ctrlAds.showNativeAds(ApiService.adsSetting['size_home'] ?? Get.width.toInt())),
            Expanded(
              child: Obx(() {
                if (favoriteList.isEmpty) {
                  return const Center(child: Text('No Favorite Twibbon'));
                } else {
                  return GridView(
                    padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,crossAxisSpacing: 10,mainAxisSpacing: 10),
                      children: favoriteList.map((e) => InkWell(
                            onTap: () {
                              Get.dialog(const Center(child: SizedBox(height: 50, width: 50, child: CircularProgressIndicator())));
                              getDetailTwibbon(e);
                            },
                            child: Card(
                                  child: Stack(
                                    children: [
                                      Expanded(child: getThumbnail(e)),
                                      const SizedBox(height: 10),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: ElevatedButton(
                                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white), shape: MaterialStateProperty.all(const CircleBorder())),
                                            onPressed: () => removeFavorite(e),
                                            child: const Icon(Icons.delete_forever, color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ),
                          ))
                          .toList());
                }
              }),
            ),
          ],
        ));
  }

  void getFavoriteList() {
    favoriteList.clear();
    SharedPreferences.getInstance().then((prefs) {
      var list = prefs.getStringList('favorite');
      if (list != null) {
        favoriteList.addAll(list);
      }
    });
  }

  void removeFavorite(value) {
    SharedPreferences.getInstance().then((prefs) {
      var list = prefs.getStringList('favorite');
      if (list != null) {
        list.remove(value);
        prefs.setStringList('favorite', list);
        getFavoriteList();
      }
    });
  }

  Widget getThumbnail(code) {
    return FutureBuilder(
      future: ApiService.getDetailTwibbon(code),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.network("${snapshot.data?.results.thumbnail}");
        } else {
          return const Center(
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  void getDetailTwibbon(code) {
    ApiService.getDetailTwibbon(code).then((value) {
      Get.back();
      if(value != null) {
        Get.toNamed('/imageDetail', arguments: {'data': value.results, 'code': code});
      }
      else{
        Get.snackbar('Error', 'Something went wrong',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    });
  }
}
