import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SV TimeStamp'**
  String get appTitle;

  /// No description provided for @initializingCamera.
  ///
  /// In en, this message translates to:
  /// **'Initializing camera...'**
  String get initializingCamera;

  /// No description provided for @imageCaptured.
  ///
  /// In en, this message translates to:
  /// **'Image captured successfully!'**
  String get imageCaptured;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet. Capture some first!'**
  String get noPhotosYet;

  /// No description provided for @recentPhotos.
  ///
  /// In en, this message translates to:
  /// **'Recent Photos'**
  String get recentPhotos;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @customizeWatermark.
  ///
  /// In en, this message translates to:
  /// **'Customize Watermark'**
  String get customizeWatermark;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size:'**
  String get textSize;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Flash Off'**
  String get flashOff;

  /// No description provided for @flashAuto.
  ///
  /// In en, this message translates to:
  /// **'Flash Auto'**
  String get flashAuto;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Flash On'**
  String get flashOn;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch Camera'**
  String get switchCamera;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @resetDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get resetDefaults;

  /// No description provided for @customLogo.
  ///
  /// In en, this message translates to:
  /// **'Custom Logo'**
  String get customLogo;

  /// No description provided for @customLogoSet.
  ///
  /// In en, this message translates to:
  /// **'Custom logo set'**
  String get customLogoSet;

  /// No description provided for @useDefaultLogo.
  ///
  /// In en, this message translates to:
  /// **'Use default logo'**
  String get useDefaultLogo;

  /// No description provided for @removeLogo.
  ///
  /// In en, this message translates to:
  /// **'Remove logo'**
  String get removeLogo;

  /// No description provided for @uploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload logo'**
  String get uploadLogo;

  /// No description provided for @logoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Logo updated successfully'**
  String get logoUpdated;

  /// No description provided for @logoUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error selecting logo'**
  String get logoUpdateError;

  /// No description provided for @removeLogoTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Custom Logo'**
  String get removeLogoTitle;

  /// No description provided for @removeLogoContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the custom logo?'**
  String get removeLogoContent;

  /// No description provided for @logoRemoved.
  ///
  /// In en, this message translates to:
  /// **'Logo removed successfully'**
  String get logoRemoved;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @cameraSettings.
  ///
  /// In en, this message translates to:
  /// **'Camera Settings'**
  String get cameraSettings;

  /// No description provided for @captureSound.
  ///
  /// In en, this message translates to:
  /// **'Capture Sound'**
  String get captureSound;

  /// No description provided for @captureSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play sound when taking photo'**
  String get captureSoundSubtitle;

  /// No description provided for @vibrationFeedback.
  ///
  /// In en, this message translates to:
  /// **'Vibration Feedback'**
  String get vibrationFeedback;

  /// No description provided for @vibrationFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on capture'**
  String get vibrationFeedbackSubtitle;

  /// No description provided for @watermarkSize.
  ///
  /// In en, this message translates to:
  /// **'Watermark Text Size'**
  String get watermarkSize;

  /// No description provided for @watermarkSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Size of watermark text'**
  String get watermarkSizeSubtitle;

  /// No description provided for @storageSettings.
  ///
  /// In en, this message translates to:
  /// **'Storage Settings'**
  String get storageSettings;

  /// No description provided for @storageUsage.
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get storageUsage;

  /// No description provided for @storageUsageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage storage'**
  String get storageUsageSubtitle;

  /// No description provided for @storageInfo.
  ///
  /// In en, this message translates to:
  /// **'Storage Information'**
  String get storageInfo;

  /// No description provided for @totalImages.
  ///
  /// In en, this message translates to:
  /// **'Total Images'**
  String get totalImages;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage Used'**
  String get storageUsed;

  /// No description provided for @storageNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Images are stored locally on your device.'**
  String get storageNote;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @clearAllPhotos.
  ///
  /// In en, this message translates to:
  /// **'Clear All Photos'**
  String get clearAllPhotos;

  /// No description provided for @clearAllPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all captured images'**
  String get clearAllPhotosSubtitle;

  /// No description provided for @deleteAllPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Photos?'**
  String get deleteAllPhotosTitle;

  /// No description provided for @deleteAllPhotosContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all captured images. This action cannot be undone.'**
  String get deleteAllPhotosContent;

  /// No description provided for @allImagesDeleted.
  ///
  /// In en, this message translates to:
  /// **'All images deleted'**
  String get allImagesDeleted;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @resetSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings?'**
  String get resetSettingsTitle;

  /// No description provided for @resetSettingsContent.
  ///
  /// In en, this message translates to:
  /// **'All settings will be reset to default values.'**
  String get resetSettingsContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @imageQuality.
  ///
  /// In en, this message translates to:
  /// **'Image quality'**
  String get imageQuality;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @ultra.
  ///
  /// In en, this message translates to:
  /// **'Ultra'**
  String get ultra;

  /// No description provided for @watermarkPosition.
  ///
  /// In en, this message translates to:
  /// **'Watermark position'**
  String get watermarkPosition;

  /// No description provided for @bottomRight.
  ///
  /// In en, this message translates to:
  /// **'Bottom Right'**
  String get bottomRight;

  /// No description provided for @bottomLeft.
  ///
  /// In en, this message translates to:
  /// **'Bottom Left'**
  String get bottomLeft;

  /// No description provided for @topRight.
  ///
  /// In en, this message translates to:
  /// **'Top Right'**
  String get topRight;

  /// No description provided for @topLeft.
  ///
  /// In en, this message translates to:
  /// **'Top Left'**
  String get topLeft;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get settingsReset;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @addressNotFound.
  ///
  /// In en, this message translates to:
  /// **'Address not found'**
  String get addressNotFound;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service is disabled'**
  String get locationServiceDisabled;

  /// No description provided for @datetimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Datetime:'**
  String get datetimeLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get addressLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get locationLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
