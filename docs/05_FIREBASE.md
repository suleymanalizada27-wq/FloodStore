# Firebase

## Project

- Project ID: `floodstore-fbece`
- Configured platforms: Android, Web (per `firebase.json` / `flutterfire configure` output in
  `lib/firebase_options.dart`)
- iOS/macOS/Windows/Linux Flutter scaffolds exist but Firebase per-platform config should be
  double-checked (`flutterfire configure` should be re-run if new platforms are targeted)

## Services in use

| Service | Used? | Where |
|---|---|---|
| Firebase Auth | ✅ | `features/auth/data/repositories/firebase_auth_repository.dart` |
| Cloud Firestore | ✅ | every `firestore_*_repository.dart` across features |
| Cloud Storage | ✅ (declared) | `firebase_storage` in `pubspec.yaml`, used for product images (`product_image_service.dart`) |
| Cloud Functions | ❌ **not used at all** | commented out in `pubspec.yaml` (`# firebase_functions`) |
| Firebase Cloud Messaging (push) | ❌ not integrated | needed for `modules/CHAT.md` notifications |
| App Check | ❌ not configured | should be added before payments ship |

## Why Cloud Functions matters (read before building payments, KYC, or payouts)

Everything today runs **client-side against Firestore directly**, gated only by (currently
nonexistent — see `06_FIREBASE_RULES.md`) security rules. This is fine for catalog browsing,
carts, and wishlists. It is **not safe** for:
- Payment processing / webhook verification
- Marking an order "paid"
- Releasing a seller payout
- Approving KYC/KYB
- Anything computing a trust/fraud score

Those need Cloud Functions (or an equivalent server) as the only writer for the relevant
fields. See `08_PAYMENT_ARCHITECTURE.md` and `10_SECURITY.md`.

## Local development

The Firebase Emulator Suite is configured in `firebase.json` with the following services:
- Auth: port 9099
- Firestore: port 8080
- Storage: port 9199
- UI: port 4000 (enabled)

To start the emulators, run:
```
firebase emulators:start
```

This will start all configured emulators and make them available at their respective ports.
The Emulator Suite UI will be available at http://localhost:4000.

Using the emulators is recommended for development and testing to avoid accidentally
modifying production data.
