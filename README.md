# Sambal

**Sambal (संबल)** is a Hindi-first, privacy-conscious Flutter app that helps bereaved Indian families understand and prepare for death-certificate registration and related next steps.

> **हर कदम पर साथ** — support at every step.

Sambal provides a calm, guided experience for collecting case details, checking document requirements, understanding fees and timelines, finding official portals, and preparing a local document pack. It is not a lawyer, government authority, or replacement for emergency services.

## Features

- Guided death-certificate journey with saved progress
- Hindi and English interface support
- State and district coverage with verification status
- Document checklists for hospital, home, and accident circumstances
- Fee and late-registration guidance with source links
- Local document scanning, OCR, encrypted storage, and PDF preparation
- Offline caching for previously loaded guidance
- Optional PIN lock and biometric authentication
- Privacy screen for reviewing and deleting locally stored data
- Emergency and government helpline shortcuts

## Privacy and safety

- Case details, scans, and generated PDFs are kept on the device unless the user explicitly shares them.
- Sensitive documents are encrypted at rest on supported Android devices.
- The assistant should not receive names, phone numbers, Aadhaar numbers, document images, or other personal details.
- Government information is shown with verification status and source links where available.
- Sambal does not invent fees, deadlines, office addresses, document requirements, or official URLs.

## Getting started

### Requirements

- Flutter SDK compatible with Dart 3.13 or later
- Android Studio or an Android device/emulator
- The optional Sambal API running locally for assistant and guided certificate data

### Run the app

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

To use a different API host:

```bash
flutter run --dart-define=API_HOST=http://127.0.0.1:3000
```

The default local API host is `http://127.0.0.1:3000`. If using a physical Android device with a locally running API, configure USB reverse port forwarding as appropriate for the device.

## Project structure

```text
lib/
├── core/       # Theme, services, storage, and shared utilities
├── data/       # Models and data sources
└── features/   # Onboarding, home, certificate, documents, assistant, and settings
```

## Development notes

- Verify official sources before presenting government requirements as fact.
- State-wide information may not apply to every local body.
- Keep scans local unless the user explicitly chooses to share them.
- Never commit API keys, signing keys, or personal documents.

## Status

Sambal is an active pre-release project (`0.1.0`). The Flutter app includes the core guided journey, local document workflow, privacy controls, and security features. Coverage and official-data verification continue to expand.

## License

No open-source license has been declared yet.
