import 'package:applovin_max/applovin_max.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'service/api.dart';
import 'view/Maintenance.dart';
import 'view/SplashScreen.dart';
import 'view/home.dart';
import 'view/ImageScreen.dart';
import 'view/imageDetail.dart';
import 'view/imageEditor.dart';
import 'view/favorite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  ApiService.slugPackageName = packageInfo.packageName.replaceAll('.', '-');
  MobileAds.instance.initialize();
  FacebookAudienceNetwork.init();
  await AppLovinMAX.initialize("MmyzbHrdywErwt8s9pRxJRX44QONi_ZPX-a290U_oATcD31doIZWrT69_4VvT7vi_tGfohSVq0CydaB1ftFz34");
  OneSignal.shared.setAppId("92d1a75d-e533-4400-b1ee-cd3b5ba21e41");
  ApiService.getAppInfo();
  ApiService.getAds();
  runApp(GetMaterialApp(
    title: 'Twibbon Creator App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    initialRoute: '/splashscreen',
    routes: {
      '/splashscreen': (context) =>  SplashScreen(),
      '/home': (context) => Home(),
      '/imageDetail': (context) => ImageDetail(),
      '/imageEditor': (context) =>  const ImageEditor(),
      '/imageScreen': (context) => ImageScreen(ModalRoute.of(context)!.settings.arguments as String),
      '/favorite': (context) => const Favorite(),
      '/maintenance': (context) => const Maintenance(),
    },
  ));
}