import 'package:auto_injector/auto_injector.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prior_list/controllers/ad_mob_controller.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/home_controller.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/repositories/notification_repository.dart';
import 'package:prior_list/theme/theme_app.dart';
import 'package:prior_list/views/home/home_page.dart';

final autoInjector = AutoInjector();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  autoInjector.addSingleton(PriorListController.new);
  autoInjector.addSingleton(HomeController.new);
  autoInjector.addSingleton(AdMobController.new);
  autoInjector.addSingleton(CoinsController.new);
  autoInjector.commit();

  NotificationRepository().initialize();
  MobileAds.instance.initialize();

  await EasyLocalization.ensureInitialized();

    runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('pt')],
      path: 'assets/translations',
      fallbackLocale: Locale('pt'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.setLocale(Locale('pt'));
    return MaterialApp(
      title: 'Prior List',
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      theme: ThemeApp.theme,
      home: const HomePage(),
    );
  }
}
