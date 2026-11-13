# Foshol-AI Update Guide (Bangla / Roman Bangla)

Ei updated version-e original project-er existing screen, API, weather, provider, pagination, CRUD, assets ebong UI files rakha hoyeche. Notun kore Hive cache ebong gallery image picker add kora hoyeche.

## 1. VS Code-e open koro
1. ZIP extract koro.
2. VS Code > File > Open Folder > `FosholAI` select koro.
3. Terminal > New Terminal.

## 2. Dependencies install
```bash
flutter pub get
```
`pubspec.yaml`-e `hive_flutter` ebong `image_picker` add kora ache.

## 3. Chrome-e run
```bash
flutter run -d chrome
```

## 4. Hive Local Cache test
1. Internet on rekhe Market tab open koro.
2. Product load howa porjonto wait koro.
3. App close kore abar open koro.
4. Internet off kore app abar run koro.
5. Market tab-e age cache kora products dekhabe.
6. Gallery theke add kora local products, edit/delete state ebong favorites Hive-e save thake.

Note: Market cache device-local. Weather API-r data ei cache-e rakha hoyni; weather-er jonno internet lagbe. DummyJSON nijer server-e POST/PUT/DELETE permanent kore na, tai app-er local snapshot nijer device-e changes preserve kore.

## 5. Gallery image test
1. Market > Add item.
2. `Choose from Gallery` click koro.
3. Ekta image select koro.
4. Preview dekho.
5. Title, category, price, stock, description fill kore Add item.
6. Product detail-e image dekho.
7. App restart kore product abar ache kina check koro.

Gallery image device-er Hive data-te Base64 data URI hisebe save hoy. Eta cloud upload noy. Onno phone/device-e automatically sync hobe na.

## 6. Android setup
Ei archive-e Android platform folder/APK generate kora hoyni, karon build environment-e Flutter SDK available chilo na. Nijer PC-te Flutter SDK install thakle project root-e:
```bash
flutter create .
flutter pub get
flutter devices
flutter run
```
Android Studio Device Manager theke emulator start korte paro. APK build:
```bash
flutter build apk --release
```
APK path:
`build/app/outputs/flutter-apk/app-release.apk`

## 7. Common troubleshooting
- `flutter` command not found: Flutter SDK PATH configure koro.
- Package resolve error: internet on kore `flutter pub get` abar chalao.
- Hive cache corrupted/old: app-er local app data clear korle fresh cache create hobe.
- Gallery picker browser-e kaj na korle Chrome permission/file chooser allow koro.
- Android build error: `flutter doctor` run kore Android toolchain-er missing dependency install koro.

## 8. Important honesty note for viva
- Local cache: Hive persistent market snapshot.
- Gallery: image_picker + local Base64 storage; no cloud upload.
- CRUD: DummyJSON demo endpoint; permanent server-side write noy. App local changes Hive-e persist kore.
- Weather/crop advice: Open-Meteo weather + local rule-based crop advice, trained AI prediction noy.
