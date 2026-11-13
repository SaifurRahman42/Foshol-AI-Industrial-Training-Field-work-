# Foshol-AI (ফসল-AI) — কৃষকের সহযোগী

A Flutter app for farmers with two parts:

1. **Weather**: live weather for 10 Bangladeshi districts, rule-based crop risk advice
   (rice, potato, tomato) and a 7-day forecast.
2. **Market**: a browsable list of farm produce with search, sorting, favorites,
   detail page and add / edit / delete.

## APIs used
- **Open-Meteo** (https://open-meteo.com): weather and forecast. No key needed.
- **DummyJSON** (https://dummyjson.com): produce list (`/products/category/groceries`),
  search, add, update and delete. No key needed.

Both are listed in the public-apis repository.

## Prices
DummyJSON returns US-dollar prices. The app shows Bangladeshi market prices in taka (৳) with units
(kg, litre, dozen...) using `lib/utils/bd_pricing.dart`; unknown items fall back to USD × 120.

## Features
- Splash screen, then bottom navigation (Weather / Market)
- Home list with image, title, subtitle and short description
- Detail screen with image gallery, price, rating, tags, info and reviews
- Debounced search
- Pagination: infinite scroll plus a "Load more" button (API `limit` / `skip`)
- Sorting (price, rating, A to Z) and favorites filter
- Add, edit and delete items (DummyJSON simulates write responses; local changes are persisted in the app's Hive cache)
- Persistent product cache: previously fetched products, local changes and favorites are restored on app startup
- Gallery image selection with image preview; image bytes are stored locally as a data URI
- Pull to refresh
- Loading skeletons, empty state, error state with retry, no-internet handling
- Dark mode toggle
- Responsive layout (list on phones, grid on tablets / wide screens)
- Animations: hero image, fade-slide lists, animated favorite icon, page indicator

## Packages used
- `http` for API calls
- `provider` for state management
- `hive_flutter` for persistent local market cache and favorites
- `image_picker` for selecting product photos from the device gallery

## Project structure
```
lib/
├── main.dart
├── models/       district.dart, weather_model.dart, product.dart
├── providers/    market_provider.dart, theme_provider.dart
├── services/     api_client.dart, weather_service.dart, product_service.dart
├── screens/      splash, main_shell, weather, forecast, market, product_detail, product_form
├── widgets/      weather_card, advice_card, error_view, product_card, ...
└── utils/        weather_utils.dart, risk_advisor.dart
```

## How to run
1. Install Flutter and run `flutter doctor`.
2. Generate the platform folders (one time): `flutter create .`  (keeps lib/ and assets/)
3. `flutter pub get`
4. `flutter run -d chrome` (or pick an Android device)

## Build APK
After generating the Android platform folder, ensure this permission exists inside `<manifest>` in `android/app/src/main/AndroidManifest.xml` (before `<application>`):
```
<uses-permission android:name="android.permission.INTERNET"/>
```
Then run `flutter build apk --release`. The APK is at
`build/app/outputs/flutter-apk/app-release.apk`.

## Screenshots
Add your screenshots here.

## Update and testing guide
See `UPDATE_GUIDE_BN.md` for step-by-step setup, offline-cache testing, gallery-image testing and Android build instructions.

## Offline cache and image notes
- Hive stores the market snapshot on the device. The app restores cached market data before attempting a fresh API request.
- Gallery-selected images are encoded and stored in the local product record. This is local device storage, not an upload to a public image host.
- DummyJSON is a demo API: POST/PUT/DELETE responses are simulated and do not permanently change its public dataset. This app preserves its local CRUD changes in Hive on the current device.
- Weather data still requires an internet connection; this cache enhancement is for the Market section.

## Note
Crop advice is general and weather-based only. It does not give pesticide or fertilizer doses.
