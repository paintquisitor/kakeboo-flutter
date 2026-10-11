import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

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
    Locale('pl'),
  ];

  /// No description provided for @appName.
  ///
  /// In pl, this message translates to:
  /// **'Kakebo'**
  String get appName;

  /// No description provided for @brandName.
  ///
  /// In pl, this message translates to:
  /// **'kakebo'**
  String get brandName;

  /// No description provided for @japaneseName.
  ///
  /// In pl, this message translates to:
  /// **'家計簿'**
  String get japaneseName;

  /// No description provided for @plan.
  ///
  /// In pl, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @planMonth.
  ///
  /// In pl, this message translates to:
  /// **'Plan miesiąca'**
  String get planMonth;

  /// No description provided for @diary.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik'**
  String get diary;

  /// No description provided for @weeks.
  ///
  /// In pl, this message translates to:
  /// **'Tygodnie'**
  String get weeks;

  /// No description provided for @balance.
  ///
  /// In pl, this message translates to:
  /// **'Bilans'**
  String get balance;

  /// No description provided for @profile.
  ///
  /// In pl, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @previousMonth.
  ///
  /// In pl, this message translates to:
  /// **'Poprzedni miesiąc'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In pl, this message translates to:
  /// **'Następny miesiąc'**
  String get nextMonth;

  /// No description provided for @developmentVersion.
  ///
  /// In pl, this message translates to:
  /// **'Wersja deweloperska'**
  String get developmentVersion;

  /// No description provided for @developmentMessage.
  ///
  /// In pl, this message translates to:
  /// **'Przygotowujemy wspólną aplikację na Androida i iOS. Twoje dane pozostają w dotychczasowej aplikacji.'**
  String get developmentMessage;

  /// No description provided for @language.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In pl, this message translates to:
  /// **'Motyw'**
  String get theme;

  /// No description provided for @currency.
  ///
  /// In pl, this message translates to:
  /// **'Waluta'**
  String get currency;

  /// No description provided for @light.
  ///
  /// In pl, this message translates to:
  /// **'Jasny'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In pl, this message translates to:
  /// **'Ciemny'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In pl, this message translates to:
  /// **'Systemowy'**
  String get system;

  /// No description provided for @polish.
  ///
  /// In pl, this message translates to:
  /// **'Polski'**
  String get polish;

  /// No description provided for @english.
  ///
  /// In pl, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @settingsSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać ustawień.'**
  String get settingsSaveError;

  /// No description provided for @previewAmount.
  ///
  /// In pl, this message translates to:
  /// **'Przykładowa kwota'**
  String get previewAmount;

  /// No description provided for @bookName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa księgi'**
  String get bookName;
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
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
