import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:social_share/social_share.dart';

import '../controller/homeController.dart';
import '../service/api.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);
  final homeCtrl = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        openDialog();
        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
          appBar: AppBar(
            elevation: 0,
            foregroundColor: Colors.white,
            title: const Text('Twibbon Creator'),
            titleSpacing: 0,
            leading: const Icon(Icons.import_contacts_sharp),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.blue],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Get.toNamed('/favorite'),
                icon: const Icon(Icons.favorite),
              ),
              IconButton(
                onPressed: () => shareApp(),
                icon: const Icon(Icons.share),
              ),
              IconButton(
                onPressed: () => homeCtrl.reviewApp(),
                icon: const Icon(Icons.star),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
               homeCtrl.getListTwibbon();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  homeCtrl.ctrlAds.showNativeAds(ApiService.adsSetting['size_home'] ?? Get.width.toInt()),
                  const SizedBox(height: 10),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        const Icon(Icons.search,color: Colors.white,),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            controller: homeCtrl.searchController,
                            onSubmitted: (value) {
                              homeCtrl.searchTwibbon();
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search your favorite frame',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Obx((){
                      if(homeCtrl.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        } else {
                          if(homeCtrl.twibbonList.isNotEmpty) {
                            return GridView.builder(
                              scrollDirection: Axis.vertical,
                              controller: homeCtrl.scrollController,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                              itemCount: homeCtrl.twibbonList.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (homeCtrl.twibbonList[index].uuid == 'ADS') {
                                  return homeCtrl.ctrlAds.showNativeAds(Get.width.toInt());
                                } else {
                                  return InkWell(
                                    onTap: () {
                                      showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
                                      homeCtrl.getDetailTwibbon(homeCtrl.twibbonList[index].url);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(homeCtrl
                                              .twibbonList[index].thumbnail),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }else{
                            return const Center(child: Text('Data not found, please try with another keyword',style: TextStyle(color: Colors.white)));
                          }
                        }
                      }),
                  ),
                ],
              )
            ),
          )
        ),
    );
  }

  Future<void> shareApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    SocialShare.shareOptions("Share App from ${packageInfo.appName}, Download Now https://play.google.com/store/apps/details?id=${packageInfo.packageName}", imagePath: null);
  }

  void openDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: (){
              Get.back();
              openDialogRate();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  openDialogRate() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Rate App'),
        content: const Text('Please rate our app, it will help us to improve our app in the future :)'),
        actions: [
          TextButton(
            onPressed: () => exit(0),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => homeCtrl.reviewApp(),
            child: const Text('Ok, Rate Now'),
          ),
        ],
      ),
    ).then((value) {
      if (value == true) {
        Get.back(result: true);
      }
    });
  }
}
