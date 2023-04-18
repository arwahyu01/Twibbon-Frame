import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/AdsController.dart';
import '../service/api.dart';

class HomeController extends GetxController {
  var twibbonList = [].obs;
  var page = 1.obs;
  var limit = 10;
  var onSearch = false.obs;
  var isLoading = false.obs;
  final ScrollController scrollController = ScrollController();
  final searchController = TextEditingController();
  final ctrlAds = Get.put(AdsController());

  @override
  void onInit() {
    super.onInit();
    ctrlAds.createInterAds();
    getListTwibbon();
    scrollController.addListener(_scrollListener);
    checkUpdate();
  }

  Future<void> checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (packageInfo.version.toString() != ApiService.appVersion.toString()) {
      if (ApiService.appAlertStatus != 0) {
        Get.defaultDialog(
          title: ApiService.appAlertTitle.toString(),
          middleText: ApiService.appAlertContent.toString(),
          confirmTextColor: Colors.white,
          barrierDismissible: false,
          onWillPop: () async => false,
          actions: [
            TextButton(
              onPressed: () async {
                await launchUrl(Uri.parse(ApiService.appAlertLink.toString()), mode: LaunchMode.externalApplication);
              },
              child: const Text('Ok'),
            ),
            if (ApiService.appAlertStatus != 2)
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel'))
          ],
        );
      }
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void getListTwibbon() {
    isLoading.value = true;
    onSearch.value = false;
    searchController.clear();
    twibbonList.clear();
    ApiService.getListTrending(1, limit).then((value) {
      if(value != null) {
        for (var element in value.results) {
          twibbonList.add(element);
        }
        isLoading.value = false;
      }
    });
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      page.value += 1;
      if (onSearch.value) {
        ApiService.searchTwibbon(searchController.text, page, limit)
            .then((value) {
          if (value != null) {
            for (var element in value.results) {
              twibbonList.add(element);
            }
          }
        });
      } else {
        ApiService.getListTrending(page, limit).then((value) {
          if (value != null) {
            for (var element in value.results) {
              twibbonList.add(element);
            }
          }
        });
      }
    }
  }

  void searchTwibbon() {
    onSearch.value = true;
    isLoading.value = true;
    twibbonList.clear();
    page.value = 1;
    if(searchController.text.isEmpty) {
      getListTwibbon();
    }else{
      ApiService.searchTwibbon(searchController.text,page,limit).then((value) {
        if (value != null) {
          for (var element in value.results) {
            twibbonList.add(element);
          }
        }
        isLoading.value = false;
      });
    }
  }

  void getDetailTwibbon(code) {
    ApiService.getDetailTwibbon(code).then((value) {
      Get.back();
      ctrlAds.showInterstitialAd();
      Future.delayed(const Duration(seconds: 2), () {
        if (value != null) {
          Get.toNamed('/imageDetail', arguments: {'data': value.results, 'code': code});
        } else {
          Get.snackbar('Error', 'Something went wrong',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      });
    });
  }

  Future<void> reviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.openStoreListing();
    } else {
      Get.snackbar('Error', 'Failed to open link review', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }
}
