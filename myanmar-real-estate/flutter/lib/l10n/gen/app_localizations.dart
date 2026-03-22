import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_my.dart';
import 'app_localizations_zh.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('my'),
    Locale('zh')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Myanmar Home'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendCode;

  /// No description provided for @getVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Get Verification Code'**
  String get getVerificationCode;

  /// No description provided for @pleaseEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhone;

  /// No description provided for @pleaseEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter verification code'**
  String get pleaseEnterCode;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidCode;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection failed'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed, please retry'**
  String get loadFailed;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get message;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @buyNewHome.
  ///
  /// In en, this message translates to:
  /// **'New Home'**
  String get buyNewHome;

  /// No description provided for @buySecondHand.
  ///
  /// In en, this message translates to:
  /// **'Resale'**
  String get buySecondHand;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @mapSearch.
  ///
  /// In en, this message translates to:
  /// **'Map Search'**
  String get mapSearch;

  /// No description provided for @mortgageCalc.
  ///
  /// In en, this message translates to:
  /// **'Mortgage'**
  String get mortgageCalc;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search area, community, listing...'**
  String get searchHint;

  /// No description provided for @houseDetail.
  ///
  /// In en, this message translates to:
  /// **'Property Detail'**
  String get houseDetail;

  /// No description provided for @contactAgent.
  ///
  /// In en, this message translates to:
  /// **'Contact Agent'**
  String get contactAgent;

  /// No description provided for @appointment.
  ///
  /// In en, this message translates to:
  /// **'Schedule Viewing'**
  String get appointment;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @bedroom.
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get bedroom;

  /// No description provided for @bathroom.
  ///
  /// In en, this message translates to:
  /// **'Bathroom'**
  String get bathroom;

  /// No description provided for @livingRoom.
  ///
  /// In en, this message translates to:
  /// **'Living Room'**
  String get livingRoom;

  /// No description provided for @kitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get kitchen;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @agentHome.
  ///
  /// In en, this message translates to:
  /// **'Workbench'**
  String get agentHome;

  /// No description provided for @houseManage.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get houseManage;

  /// No description provided for @clientList.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clientList;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @addHouse.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get addHouse;

  /// No description provided for @editHouse.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get editHouse;

  /// No description provided for @verificationTask.
  ///
  /// In en, this message translates to:
  /// **'Verification Tasks'**
  String get verificationTask;

  /// No description provided for @acnDeal.
  ///
  /// In en, this message translates to:
  /// **'ACN Deal'**
  String get acnDeal;

  /// No description provided for @pendingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Pending Appointments'**
  String get pendingAppointments;

  /// No description provided for @todaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get todaySchedule;

  /// No description provided for @cityYangon.
  ///
  /// In en, this message translates to:
  /// **'Yangon'**
  String get cityYangon;

  /// No description provided for @cityMandalay.
  ///
  /// In en, this message translates to:
  /// **'Mandalay'**
  String get cityMandalay;

  /// No description provided for @cityNaypyitaw.
  ///
  /// In en, this message translates to:
  /// **'Naypyitaw'**
  String get cityNaypyitaw;

  /// No description provided for @typeApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get typeApartment;

  /// No description provided for @typeHouse.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get typeHouse;

  /// No description provided for @typeTownhouse.
  ///
  /// In en, this message translates to:
  /// **'Townhouse'**
  String get typeTownhouse;

  /// No description provided for @typeLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get typeLand;

  /// No description provided for @typeCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get typeCommercial;

  /// No description provided for @transactionSale.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get transactionSale;

  /// No description provided for @transactionRent.
  ///
  /// In en, this message translates to:
  /// **'For Rent'**
  String get transactionRent;

  /// No description provided for @decorationRough.
  ///
  /// In en, this message translates to:
  /// **'Bare Shell'**
  String get decorationRough;

  /// No description provided for @decorationSimple.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get decorationSimple;

  /// No description provided for @decorationFine.
  ///
  /// In en, this message translates to:
  /// **'Refined'**
  String get decorationFine;

  /// No description provided for @decorationLuxury.
  ///
  /// In en, this message translates to:
  /// **'Luxury'**
  String get decorationLuxury;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get statusPending;

  /// No description provided for @statusVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying'**
  String get statusVerifying;

  /// No description provided for @statusOnline.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @statusSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get statusSold;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @appointmentPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get appointmentPending;

  /// No description provided for @appointmentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get appointmentConfirmed;

  /// No description provided for @appointmentRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get appointmentRejected;

  /// No description provided for @appointmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get appointmentCancelled;

  /// No description provided for @appointmentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get appointmentCompleted;

  /// No description provided for @appointmentNoShow.
  ///
  /// In en, this message translates to:
  /// **'No Show'**
  String get appointmentNoShow;

  /// No description provided for @roleEntrant.
  ///
  /// In en, this message translates to:
  /// **'Entry Agent'**
  String get roleEntrant;

  /// No description provided for @roleMaintainer.
  ///
  /// In en, this message translates to:
  /// **'Maintainer'**
  String get roleMaintainer;

  /// No description provided for @roleIntroducer.
  ///
  /// In en, this message translates to:
  /// **'Referrer'**
  String get roleIntroducer;

  /// No description provided for @roleAccompanier.
  ///
  /// In en, this message translates to:
  /// **'Showing Agent'**
  String get roleAccompanier;

  /// No description provided for @roleCloser.
  ///
  /// In en, this message translates to:
  /// **'Closer'**
  String get roleCloser;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get selectLanguageHint;

  /// No description provided for @langMyanmar.
  ///
  /// In en, this message translates to:
  /// **'Myanmar (မြန်မာ)'**
  String get langMyanmar;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get langChinese;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'my', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'my': return AppLocalizationsMy();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
