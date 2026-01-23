import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';

class AppLifecycleManager {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();

  factory AppLifecycleManager() => _instance;

  AppLifecycleManager._internal();

  bool _isInitialized = false;
  StreamSubscription<FGBGType>? _subscription;

  void initialize() {
    if (!_isInitialized) {
      _subscription = FGBGEvents.instance.stream.listen((event) {
        _handleFGBGEvent(event);
      });
      _isInitialized = true;
      debugPrint('AppLifecycleManager: Initialized with flutter_fgbg');
    }
  }

  void dispose() {
    if (_isInitialized) {
      _subscription?.cancel();
      _subscription = null;
      _isInitialized = false;
      debugPrint('AppLifecycleManager: Disposed');
    }
  }

  void _handleFGBGEvent(FGBGType event) {
    debugPrint('AppLifecycleManager: FGBG Event: $event');

    switch (event) {
      case FGBGType.background:
        debugPrint('AppLifecycleManager: App went to background');
        break;

      case FGBGType.foreground:
        _handleAppResume();
        break;
    }
  }

  void _handleAppResume() async {
    // debugPrint('AppLifecycleManager: App resumed');

    // final context = rootNavigatorKey.currentContext;
    // if (context != null) LoadingOverlay.show(context);

    // try {
    //   // Race between ad loading/showing and a 10s timeout
    //   final shown = await Future.any([
    //     _adManager.loadAndShowImmediately(),
    //     Future.delayed(const Duration(seconds: 10), () => false),
    //   ]);

    //   debugPrint('AppLifecycleManager: Ad shown: $shown');
    // } catch (e) {
    //   debugPrint('AppLifecycleManager: Error showing ad: $e');
    // } finally {
    //   // Always hide overlay after ad or timeout
    //   if (context != null) LoadingOverlay.hide(context);
    // }
  }
}
