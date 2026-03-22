# Flutter i18n Design — Myanmar Real Estate Platform

**Date:** 2026-03-20
**Scope:** Full internationalization of Buyer App (C端) and Agent App (B端)
**Languages:** Myanmar `my` (default), English `en`, Chinese `zh`
**Approach:** Flutter gen-l10n (official)

---

## 1. Architecture Overview

```
flutter/
├── l10n.yaml                          # gen-l10n config
└── lib/
    ├── l10n/
    │   ├── app_en.arb                 # template (all keys defined here)
    │   ├── app_my.arb                 # Myanmar translations
    │   ├── app_zh.arb                 # Chinese translations
    │   └── gen/
    │       └── app_localizations.dart # auto-generated — COMMIT to VCS
    └── core/
        └── providers/
            └── locale_provider.dart   # Riverpod locale state
```

**Flow:** `.arb` files → `flutter gen-l10n` → `AppLocalizations` class → used in widgets via `AppLocalizations.of(context).key`

> **Note on `lib/l10n/gen/`:** Commit the generated files to version control. This is the Flutter-recommended practice when using a custom `output-dir` without the `flutter_gen` package setup, and ensures the app builds without running codegen in CI.

---

## 2. l10n.yaml Configuration

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n/gen
synthetic-package: false
nullable-getter: false
```

**`synthetic-package: false` is required.** Without it, `flutter gen-l10n` defaults to generating a synthetic package and places output under `.dart_tool/flutter_gen/`, ignoring `output-dir`. With `synthetic-package: false`, the file is generated at `lib/l10n/gen/app_localizations.dart` and imported as `package:myanmarhome/l10n/gen/app_localizations.dart`.

**`nullable-getter: false`** changes the return type of `AppLocalizations.of(context)` from `AppLocalizations?` to `AppLocalizations`, eliminating `!` operators throughout widget code. Trade-off: if `.of(context)` is called outside a widget tree that has `localizationsDelegates` configured (e.g. in unit tests with a bare `MaterialApp`), it throws a `StateError` at runtime instead of returning null. All widget tests must use `AppLocalizations.localizationsDelegates` in their test harness.

**`pubspec.yaml` must include `generate: true`** under the `flutter:` section for `flutter gen-l10n` to run automatically during `flutter build`/`flutter run`:

```yaml
flutter:
  generate: true   # ← required for flutter gen-l10n with custom output-dir
  uses-material-design: true
  # ...
```

---

## 3. ARB Files

### Supported keys (`app_en.arb` as template — defines all keys)

**Auth & Common**
- `appTitle`, `welcome`, `login`, `register`, `logout`
- `phoneNumber`, `verificationCode`, `sendCode`, `resendCode`, `getVerificationCode`
- `pleaseEnterPhone`, `pleaseEnterCode`, `invalidPhone`, `invalidCode`
- `loginSuccess`, `loginFailed`, `networkError`, `serverError`
- `loading`, `confirm`, `cancel`, `save`, `delete`, `edit`, `search`, `retry`
- `noData`, `loadMore`, `pullToRefresh`, `termsOfService`, `privacyPolicy`
- `loadFailed`

**Navigation (Bottom Tabs)**
- `home`, `message`, `favorites`, `profile`, `notification`, `settings`

**Buyer App**
- `buyNewHome`, `buySecondHand`, `rent`, `mapSearch`, `mortgageCalc`
- `recommended`, `searchHint`, `more`
- `houseDetail`, `contactAgent`, `appointment`, `price`, `area`
- `bedroom`, `bathroom`, `livingRoom`, `kitchen`, `location`

**Agent App**
- `agentHome`, `houseManage`, `clientList`, `schedule`, `performance`
- `addHouse`, `editHouse`, `verificationTask`, `acnDeal`
- `pendingAppointments`, `todaySchedule`

**Cities**
- `cityYangon`, `cityMandalay`, `cityNaypyitaw`

> District names (`DistrictCodes.districtNames`) are already in English and do not require localization.

**House Types**
- `typeApartment`, `typeHouse`, `typeTownhouse`, `typeLand`, `typeCommercial`

**Transaction Types**
- `transactionSale`, `transactionRent`

**Decoration Types**
- `decorationRough`, `decorationSimple`, `decorationFine`, `decorationLuxury`

**House Status**
- `statusPending`, `statusVerifying`, `statusOnline`, `statusOffline`, `statusSold`, `statusRejected`

**Appointment Status**
- `appointmentPending`, `appointmentConfirmed`, `appointmentRejected`, `appointmentCancelled`, `appointmentCompleted`, `appointmentNoShow`

**ACN Roles**
- `roleEntrant`, `roleMaintainer`, `roleIntroducer`, `roleAccompanier`, `roleCloser`

**Language Selection (Onboarding)**
- `selectLanguage`, `selectLanguageHint`
- `langMyanmar`, `langEnglish`, `langChinese`
- `continueBtn`

The existing `assets/l10n/app_my.arb` covers ~60 keys. It will be moved to `lib/l10n/app_my.arb` and extended with the additional keys above.

---

## 4. Locale State Management

**File:** `lib/core/providers/locale_provider.dart`

The `LocaleNotifier` uses two new methods added to `LocalStorage` (following the existing `isFirstLaunch`/`setFirstLaunch` pattern):

```dart
// In local_storage.dart — new methods to add:
static String? getLocale() {
  return _prefs?.getString(StorageKeys.locale);
}

static Future<void> saveLocale(String languageCode) async {
  await _prefs?.setString(StorageKeys.locale, languageCode);
}
```

```dart
// locale_provider.dart
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = LocalStorage.getLocale();
    return Locale(saved ?? 'my');  // default: Myanmar
  }

  Future<void> setLocale(Locale locale) async {
    await LocalStorage.saveLocale(locale.languageCode);
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
```

**`LocalStorage.getLocale()` is synchronous** — `_prefs` is already initialized in `main()` before `runApp`, so `_prefs?.getString(...)` works synchronously in `Notifier.build()`.

`StorageKeys.locale = 'locale'` added to `app_constants.dart`.

**Default locale:** `my` (Myanmar) — target users are Burmese speakers.

---

## 5. App Entry Point Wiring

Both `main_buyer.dart` and `main_agent.dart` updated:

```dart
class BuyerApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(buyerRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Myanmar Home',
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
```

Same changes apply to `AgentApp` in `main_agent.dart`.

---

## 6. Language Selection UI

**Trigger:** First launch only, checked via `await LocalStorage.isFirstLaunch()`.

**Shared page:** `lib/shared/pages/language_selection_page.dart` — used by **both** Buyer and Agent apps (not duplicated).

**UI:**

```
┌─────────────────────────────┐
│   选择语言 / Select / ဘာသာ   │
│                             │
│  ┌─────────────────────┐    │
│  │ ✓  Myanmar (မြန်မာ) │    │  ← selected by default
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │    English          │    │
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │    中文              │    │
│  └─────────────────────┘    │
│                             │
│         [Continue →]         │
└─────────────────────────────┘
```

The page title shows all 3 language names simultaneously so users can identify it regardless of the device's current locale.

**After selection:**
1. Calls `ref.read(localeProvider.notifier).setLocale(selected)`
2. Calls `LocalStorage.setFirstLaunch(false)`
3. Navigates to the app's main flow (`/buyer/home` or `/agent/home`)

**Router wiring — complete merged `redirect` for `buyer_router.dart`:**

The existing redirect is synchronous and skips onboarding entirely. It must be made `async` and extended with the first-launch check. First-launch check runs **before** auth check:

```dart
redirect: (context, state) async {
  final isLoggedIn = ref.read(authProvider).isLoggedIn;

  final isSplash         = state.matchedLocation == RouteNames.splash;
  final isLanguageSelect = state.matchedLocation == RouteNames.languageSelect;
  final isOnboarding     = state.matchedLocation == RouteNames.onboarding;
  final isLogin          = state.matchedLocation == RouteNames.login ||
                            state.matchedLocation == RouteNames.register;

  // Splash: check first launch before auth
  if (isSplash) {
    final isFirst = await LocalStorage.isFirstLaunch();
    if (isFirst) return RouteNames.languageSelect;
    return isLoggedIn ? RouteNames.buyerHome : RouteNames.login;
  }

  // Language selection: always accessible (first-launch gateway + settings re-entry)
  if (isLanguageSelect) return null;

  // Onboarding / login pages: no auth required
  if (isOnboarding || isLogin) {
    return isLoggedIn ? RouteNames.buyerHome : null;
  }

  // All other pages require auth
  if (!isLoggedIn) return RouteNames.login;

  return null;
},
```

**Router wiring — Agent App (`agent_router.dart`):** Apply the same pattern (check the actual agent router and mirror the above changes).

**New route constant:**
```dart
// app_constants.dart
static const String languageSelect = '/language-select';
```

---

## 7. String Replacement Strategy

### Widget strings
All hardcoded Chinese/English strings in pages replaced with:
```dart
final l = AppLocalizations.of(context);
Text(l.home)
```

### app_constants.dart Maps → l10n extensions

Static Maps with hardcoded Chinese cannot use `context`. They are replaced with extension methods in `lib/core/extensions/l10n_extensions.dart`:

```dart
// Example
extension HouseTypeL10n on String {
  String localizedName(BuildContext context) {
    final l = AppLocalizations.of(context);
    switch (this) {
      case HouseTypes.apartment: return l.typeApartment;
      case HouseTypes.house:     return l.typeHouse;
      case HouseTypes.townhouse: return l.typeTownhouse;
      case HouseTypes.land:      return l.typeLand;
      case HouseTypes.commercial:return l.typeCommercial;
      default:                   return this;
    }
  }
}

extension DecorationTypeL10n on String { /* decorationRough, etc. */ }
extension HouseStatusL10n on String    { /* statusPending, etc. */ }
extension AppointmentStatusL10n on String { /* appointmentPending, etc. */ }
extension TransactionTypeL10n on String { /* transactionSale, etc. */ }
extension AcnRoleL10n on String        { /* roleEntrant, etc. */ }
extension CityL10n on String           { /* cityYangon, etc. */ }
```

Usage at call sites: `houseType.localizedName(context)`

The original static `typeNames` Maps in `app_constants.dart` are **removed** to prevent stale Chinese strings from creeping back in.

---

## 8. Font

NotoSansMyanmar font files (`NotoSansMyanmar-Regular.ttf`, `NotoSansMyanmar-Bold.ttf`) are referenced in `pubspec.yaml` but do not exist on disk. They must be downloaded from Google Fonts and placed in `assets/fonts/` before uncommenting the font config.

**Font download:**
```bash
# From flutter project root
mkdir -p assets/fonts
# Download NotoSansMyanmar-Regular.ttf and NotoSansMyanmar-Bold.ttf
# from https://fonts.google.com/noto/specimen/Noto+Sans+Myanmar
```

**pubspec.yaml** (uncomment):
```yaml
fonts:
  - family: NotoSansMyanmar
    fonts:
      - asset: assets/fonts/NotoSansMyanmar-Regular.ttf
      - asset: assets/fonts/NotoSansMyanmar-Bold.ttf
        weight: 700
```

The font is applied globally — Flutter will use it for Myanmar script characters automatically via Unicode fallback. No per-locale theme switching is needed.

---

## 9. Files Changed / Created

| File | Action |
|------|--------|
| `l10n.yaml` | Create |
| `pubspec.yaml` | Edit: add `generate: true`; uncomment NotoSansMyanmar font |
| `assets/fonts/NotoSansMyanmar-Regular.ttf` | Add (download) |
| `assets/fonts/NotoSansMyanmar-Bold.ttf` | Add (download) |
| `lib/l10n/app_en.arb` | Create |
| `lib/l10n/app_my.arb` | Create (move from `assets/l10n/` + extend) |
| `lib/l10n/app_zh.arb` | Create |
| `lib/l10n/gen/app_localizations.dart` | Auto-generated (commit to VCS) |
| `lib/core/providers/locale_provider.dart` | Create |
| `lib/core/storage/local_storage.dart` | Edit: add `getLocale()` + `saveLocale()` |
| `lib/core/constants/app_constants.dart` | Edit: add `StorageKeys.locale`, `RouteNames.languageSelect`; remove Chinese Maps |
| `lib/core/extensions/l10n_extensions.dart` | Create (localized Map lookups) |
| `lib/shared/pages/language_selection_page.dart` | Create (shared between both apps) |
| `lib/main_buyer.dart` | Edit: add locale + delegates |
| `lib/main_agent.dart` | Edit: add locale + delegates |
| `lib/core/router/buyer_router.dart` | Edit: add first-launch redirect |
| `lib/core/router/agent_router.dart` | Edit: add first-launch redirect |
| All `lib/buyer/presentation/pages/*.dart` | Edit: replace hardcoded strings |
| All `lib/agent/presentation/pages/*.dart` | Edit: replace hardcoded strings |
| `assets/l10n/app_my.arb` | Delete (moved to `lib/l10n/`) |

---

## 10. Out of Scope

- WeChat Mini Program localization
- Web Admin localization
- Backend API response localization (property names from DB)
- RTL layout support (Myanmar is LTR)
- District name localization (`DistrictCodes.districtNames` already in English)
