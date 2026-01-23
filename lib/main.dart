import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:phone_cleaner_2/services/app_lifecycle.dart';
import 'package:phone_cleaner_2/src.dart';
import 'package:provider/provider.dart';

import 'core/providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final AppLifecycleManager lifecycleManager = AppLifecycleManager();
  lifecycleManager.initialize();
  runApp(MultiProvider(providers: globalProviders, child: MyApp()));
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
