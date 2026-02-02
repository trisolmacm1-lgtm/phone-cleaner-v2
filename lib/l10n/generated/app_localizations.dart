import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('zh'),
  ];

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK ALL FEATURES'**
  String get unlockAllFeatures;

  /// No description provided for @smartCleaning.
  ///
  /// In en, this message translates to:
  /// **'Smart Cleaning'**
  String get smartCleaning;

  /// No description provided for @removeAllAds.
  ///
  /// In en, this message translates to:
  /// **'Remove All Ads & Limits'**
  String get removeAllAds;

  /// No description provided for @saveStorage.
  ///
  /// In en, this message translates to:
  /// **'Save Storage & Time'**
  String get saveStorage;

  /// No description provided for @phoneCleaner.
  ///
  /// In en, this message translates to:
  /// **'Phone Cleaner'**
  String get phoneCleaner;

  /// No description provided for @storageUsage.
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get storageUsage;

  /// No description provided for @startSmartClean.
  ///
  /// In en, this message translates to:
  /// **'Start Smart Clean'**
  String get startSmartClean;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @compress.
  ///
  /// In en, this message translates to:
  /// **'Compress'**
  String get compress;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @noDuplicateVideos.
  ///
  /// In en, this message translates to:
  /// **'No Duplicate Videos found!'**
  String get noDuplicateVideos;

  /// No description provided for @videoLibraryClean.
  ///
  /// In en, this message translates to:
  /// **'Your video library is clean'**
  String get videoLibraryClean;

  /// No description provided for @noDuplicateImages.
  ///
  /// In en, this message translates to:
  /// **'No Duplicate Images found!'**
  String get noDuplicateImages;

  /// No description provided for @imageLibraryClean.
  ///
  /// In en, this message translates to:
  /// **'Your image library is clean'**
  String get imageLibraryClean;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @deleteContacts.
  ///
  /// In en, this message translates to:
  /// **'Delete Contacts'**
  String get deleteContacts;

  /// No description provided for @deleteConfirmContacts.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {value} selected contacts? This action cannot be undone.'**
  String deleteConfirmContacts(Object value);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @chooseVideo.
  ///
  /// In en, this message translates to:
  /// **'Choose Video'**
  String get chooseVideo;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get deselectAll;

  /// No description provided for @uploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload Your Video'**
  String get uploadVideo;

  /// No description provided for @tapChooseVideo.
  ///
  /// In en, this message translates to:
  /// **'Tap the ‘Upload’ Button to\n  select your video'**
  String get tapChooseVideo;

  /// No description provided for @basicCompression.
  ///
  /// In en, this message translates to:
  /// **'Basic Compression'**
  String get basicCompression;

  /// No description provided for @mediumSizeHighQuality.
  ///
  /// In en, this message translates to:
  /// **'Medium Size, High Quality'**
  String get mediumSizeHighQuality;

  /// No description provided for @mediumCompression.
  ///
  /// In en, this message translates to:
  /// **'Medium Compression'**
  String get mediumCompression;

  /// No description provided for @strongCompression.
  ///
  /// In en, this message translates to:
  /// **'Strong Compression'**
  String get strongCompression;

  /// No description provided for @smallSizeBestQuality.
  ///
  /// In en, this message translates to:
  /// **'Small Size, Best Quality'**
  String get smallSizeBestQuality;

  /// No description provided for @continuee.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuee;

  /// No description provided for @compressed.
  ///
  /// In en, this message translates to:
  /// **'Compressed'**
  String get compressed;

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get saveToGallery;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @downloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved Successfully'**
  String get downloadSuccess;

  /// No description provided for @videoDownloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your Compressed video has been\n saved successfully.'**
  String get videoDownloadSuccess;

  /// No description provided for @compressedNextVideo.
  ///
  /// In en, this message translates to:
  /// **'Compressed Next Video'**
  String get compressedNextVideo;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @setPin.
  ///
  /// In en, this message translates to:
  /// **'Set Your Privacy PIN'**
  String get setPin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your PIN'**
  String get confirmPin;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @saveImage.
  ///
  /// In en, this message translates to:
  /// **'Save Image'**
  String get saveImage;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get deleteImage;

  /// No description provided for @imageDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Your image has been downloaded\n successfully.'**
  String get imageDownloaded;

  /// No description provided for @deletion.
  ///
  /// In en, this message translates to:
  /// **'Deletion!'**
  String get deletion;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get deleteConfirm;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @unlockFullPower.
  ///
  /// In en, this message translates to:
  /// **'Unlock full Power'**
  String get unlockFullPower;

  /// No description provided for @getUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Get unlimited cleaning & premium \nfeatures'**
  String get getUnlimited;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @dayfree.
  ///
  /// In en, this message translates to:
  /// **'3 Day Free Trial'**
  String get dayfree;

  /// No description provided for @smartclean.
  ///
  /// In en, this message translates to:
  /// **'Smart Clean'**
  String get smartclean;

  /// No description provided for @occupiesSpace.
  ///
  /// In en, this message translates to:
  /// **'Occupies Storage Space'**
  String get occupiesSpace;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @smartlyRemoveDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Remove Duplicates'**
  String get smartlyRemoveDuplicates;

  /// No description provided for @smartlyRemoveDuplicatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Instantly find and remove all duplicate\nphotos and videos.'**
  String get smartlyRemoveDuplicatesDesc;

  /// No description provided for @instantCleanBoost.
  ///
  /// In en, this message translates to:
  /// **'Instant Clean & Boost'**
  String get instantCleanBoost;

  /// No description provided for @instantCleanBoostDesc.
  ///
  /// In en, this message translates to:
  /// **'One-Tap Smart Clear for instant space \nand performance boost.'**
  String get instantCleanBoostDesc;

  /// No description provided for @unlimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlimited access to all features'**
  String get unlimitedAccess;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority customer support'**
  String get prioritySupport;

  /// No description provided for @advancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics & insights'**
  String get advancedAnalytics;

  /// No description provided for @adFree.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get adFree;

  /// No description provided for @newBenefits.
  ///
  /// In en, this message translates to:
  /// **'Your new benefits'**
  String get newBenefits;

  /// No description provided for @successfullyUpgraded.
  ///
  /// In en, this message translates to:
  /// **'You\'ve successfully upgraded to'**
  String get successfullyUpgraded;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get congratulations;

  /// No description provided for @photoLibraryAccess.
  ///
  /// In en, this message translates to:
  /// **'Photo Library Access'**
  String get photoLibraryAccess;

  /// No description provided for @photoLibraryAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'To find and clean duplicate files, the app needs access to your photo library. Please enable access in your device settings.'**
  String get photoLibraryAccessDesc;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No Contacts Found'**
  String get noContactsFound;

  /// No description provided for @subscriptionNote.
  ///
  /// In en, this message translates to:
  /// **'Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period. Account will be charged for renewal within 24-hours prior to the end of the current period.'**
  String get subscriptionNote;

  /// No description provided for @restoredPurchases.
  ///
  /// In en, this message translates to:
  /// **'Restored Purchases'**
  String get restoredPurchases;

  /// No description provided for @noPaymentNow.
  ///
  /// In en, this message translates to:
  /// **'No payment now'**
  String get noPaymentNow;

  /// No description provided for @cancelNoCharges.
  ///
  /// In en, this message translates to:
  /// **'Cancel without any charges'**
  String get cancelNoCharges;

  /// No description provided for @twoTapsToStart.
  ///
  /// In en, this message translates to:
  /// **'2 taps to start.'**
  String get twoTapsToStart;

  /// No description provided for @startFreeNow.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial Now'**
  String get startFreeNow;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @threeDaysFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Three Days Free Trial'**
  String get threeDaysFreeTrial;

  /// No description provided for @scanningDuplicateVideos.
  ///
  /// In en, this message translates to:
  /// **'Scanning for duplicate videos…'**
  String get scanningDuplicateVideos;

  /// No description provided for @scanningDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Scanning for duplicates…'**
  String get scanningDuplicates;

  /// No description provided for @noImagesDeleted.
  ///
  /// In en, this message translates to:
  /// **'No images were deleted.'**
  String get noImagesDeleted;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noDuplicateContacts.
  ///
  /// In en, this message translates to:
  /// **'No duplicate contacts found!'**
  String get noDuplicateContacts;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @compressingVideo.
  ///
  /// In en, this message translates to:
  /// **'Compressing video...'**
  String get compressingVideo;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @defaultColor.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultColor;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// No description provided for @orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @enterYourPin.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Pin'**
  String get enterYourPin;

  /// No description provided for @tapToUpload.
  ///
  /// In en, this message translates to:
  /// **'Tap to \"Upload\" Button to'**
  String get tapToUpload;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Images'**
  String get uploadImage;

  /// No description provided for @compressVideo.
  ///
  /// In en, this message translates to:
  /// **'Compress Video'**
  String get compressVideo;

  /// No description provided for @withoutLosingQuality.
  ///
  /// In en, this message translates to:
  /// **'Without Losing Quality'**
  String get withoutLosingQuality;

  /// No description provided for @onlyMp4Supported.
  ///
  /// In en, this message translates to:
  /// **'Only MP4 File Are Supported'**
  String get onlyMp4Supported;

  /// No description provided for @clean.
  ///
  /// In en, this message translates to:
  /// **'CLEAN'**
  String get clean;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @smart_clean_complete.
  ///
  /// In en, this message translates to:
  /// **'Smart Clean Completed'**
  String get smart_clean_complete;

  /// No description provided for @wrong_pin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN, please try again'**
  String get wrong_pin;

  /// No description provided for @continue_to_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Continue to Dashboard'**
  String get continue_to_dashboard;

  /// No description provided for @your_video_is.
  ///
  /// In en, this message translates to:
  /// **'Your Video is'**
  String get your_video_is;

  /// No description provided for @smaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller!'**
  String get smaller;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @onb_title_1.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Detection'**
  String get onb_title_1;

  /// No description provided for @onb_subtitle_1.
  ///
  /// In en, this message translates to:
  /// **'Find and group similar photos easily.'**
  String get onb_subtitle_1;

  /// No description provided for @onb_title_2.
  ///
  /// In en, this message translates to:
  /// **'Video Compression'**
  String get onb_title_2;

  /// No description provided for @onb_subtitle_2.
  ///
  /// In en, this message translates to:
  /// **'Reduce video size in seconds with one tap.'**
  String get onb_subtitle_2;

  /// No description provided for @onb_title_3.
  ///
  /// In en, this message translates to:
  /// **'Keep Photos Private'**
  String get onb_title_3;

  /// No description provided for @onb_subtitle_3.
  ///
  /// In en, this message translates to:
  /// **'Hide your personal photos securely.'**
  String get onb_subtitle_3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
