import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import '../model/imagesDetail.dart';
import '../model/appInfo.dart';
import '../model/homeTrending.dart';
class ApiService extends GetxController{
  static const String _baseUrl = 'https://panel.footballuwu.site/api';
  static String slugPackageName = '';
  static String? appName = 'Twibbon Creator App';
  static int? appVersion = 1;
  static String? appStatus = '1';

  static String? appAlertTitle = 'Alert';
  static String? appAlertContent = 'Content';
  static int? appAlertStatus = 0;
  static String? appAlertLink = '';
  static String typeAds = '';
  static dynamic adsSetting = '';
  static dynamic adsUnitId = '';
  static dynamic appAlert;

  static Future<bool> checkInternet() async {
    try {
      final connect = await InternetAddress.lookup('google.com');
      if (connect.isNotEmpty && connect[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  static Future<AppInfo?> getAppInfo() async {
    var response = await http.get(Uri.parse('$_baseUrl/app/$slugPackageName'));
    if (response.statusCode == 200) {
      var res = AppInfo.fromJson(jsonDecode(response.body));
      appName = res.name;
      appVersion = res.version;
      appStatus = res.status;
      appAlertTitle = res.alert.title;
      appAlertContent = res.alert.content;
      appAlertStatus = res.alert.status;
      appAlertLink = res.alert.link;
    }
    return null;
  }

  static Future<void> getAds() async {
    final response = await http.get(Uri.parse('$_baseUrl/iklan/$slugPackageName'));
    if (response.statusCode == 200) {
      var decode = jsonDecode(response.body);
      adsUnitId = decode;
      typeAds = decode['code']; // admob, facebook, applovin
      adsSetting = decode['setting'];
    }
  }

  static Future<HomeTrending?> getListTrending(page,limit) async {
    var response = await http.get(Uri.parse('$_baseUrl/twib-trending/$page/$limit'));
    if (response.statusCode == 200) {
      var res = HomeTrending.fromJson(jsonDecode(response.body));
      return res;
    }
    return null;
  }

  static Future<HomeTrending?> searchTwibbon(String value,page,limit) async {
    var response = await http.get(Uri.parse('$_baseUrl/twib-search/$value/1/10'));
    if (response.statusCode == 200) {
      var res = HomeTrending.fromJson(jsonDecode(response.body));
      return res;
    }
    return null;
  }

  static Future<ImagesDetail?> getDetailTwibbon(code) async {
    var response = await http.get(Uri.parse('$_baseUrl/twib-detail/$code'));
    if (response.statusCode == 200) {
      var res = ImagesDetail.fromJson(jsonDecode(response.body));
      return res;
    }
    return null;
  }

  static Future<void> requestReviewApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      Get.snackbar('Error', 'Failed to open link review', snackPosition: SnackPosition.BOTTOM);
    }
  }

}