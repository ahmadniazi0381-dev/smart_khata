# pubspec.yaml & l10n.yaml Additions — Smart Khata

> [!IMPORTANT]
> These snippets assume you have already run `flutter create .` (or equivalent)
> inside `e:\My Project\Smart Khata\` so that a base `pubspec.yaml` exists.
> Merge the sections below into the existing file — do **not** replace the
> entire file.

---

## 1 — `pubspec.yaml` — dependencies to add

Add these under the `dependencies:` key:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:   # ships with Flutter SDK
    sdk: flutter

  # Navigation
  go_router: ^14.0.0

  # State management
  flutter_riverpod: ^2.5.1

  # (Database — added by the database agent)
  # drift: ^2.18.0
  # sqlite3_flutter_libs: ^0.5.0
  # path_provider: ^2.1.0
  # path: ^1.9.0
```

---

## 2 — `pubspec.yaml` — `flutter:` section

Merge the following into the existing `flutter:` section (keep any existing
keys already present):

```yaml
flutter:
  uses-material-design: true
  generate: true          # enables flutter gen-l10n

  assets:
    - assets/fonts/       # font README + actual .ttf files go here

  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700

    - family: NotoNastaliqUrdu
      fonts:
        - asset: assets/fonts/NotoNastaliqUrdu-Regular.ttf
          weight: 400
        - asset: assets/fonts/NotoNastaliqUrdu-Bold.ttf
          weight: 700
```

---

## 3 — Create `l10n.yaml` at the project root

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

---

## 4 — Generate localisation code

After updating `pubspec.yaml` and creating `l10n.yaml`, run:

```bash
flutter pub get
flutter gen-l10n
```

This generates `lib/l10n/app_localizations.dart` (and per-locale delegates).
Commit the generated file to version control.

---

## 5 — Download fonts

Before running the app, download the required `.ttf` files into
`assets/fonts/` (see `assets/fonts/README.md` for direct links):

| Font file | URL |
|---|---|
| Inter-*.ttf | https://fonts.google.com/specimen/Inter |
| NotoNastaliqUrdu-*.ttf | https://fonts.google.com/noto/specimen/Noto+Nastaliq+Urdu |

---

## 6 — Run the app

```bash
flutter run
```
