import Flutter
import UIKit
import google_mobile_ads // Keep this for NativeAdViewFactory
import GoogleMobileAds // Keep this for the main SDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ STEP 1: Register all plugins FIRST.
    // This ensures the Google Mobile Ads plugin is initialized and ready.
    GeneratedPluginRegistrant.register(with: self)

    let registry = self as! FlutterPluginRegistry

    // ✅ STEP 2: Now that the plugin is ready, register your native ad factories.
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        registry,
        factoryId: "nativeSmallLight",
        nativeAdFactory: NativeAdViewFactory(adScaleType: .small)
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        registry,
        factoryId: "nativeMediumLight",
        nativeAdFactory: NativeAdViewFactory(adScaleType: .medium)
    )
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        registry,
        factoryId: "nativeLargeLight",
        nativeAdFactory: NativeAdViewFactory(adScaleType: .large)
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // This unregister method is correct, no changes needed.
  override func applicationWillTerminate(_ application: UIApplication) {
    let registry = self as! FlutterPluginRegistry
    [
      "nativeSmallLight", "nativeMediumLight", "nativeLargeLight",
    ].forEach { factoryId in
      FLTGoogleMobileAdsPlugin.unregisterNativeAdFactory(registry, factoryId: factoryId)
    }
  }
}
