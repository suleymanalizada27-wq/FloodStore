# FloodStore — Construction Commerce Platform

A comprehensive construction commerce platform built with Flutter, Riverpod, GoRouter, and Firebase. The platform combines B2C marketplace functionality with B2B procurement capabilities, specifically tailored for the construction industry.

## 🏗️ Platform Overview

FloodStore is an Enterprise Construction Commerce Platform that combines:
- **B2C Marketplace**: retail construction materials and supplies
- **B2B Procurement**: RFQ, quotation, and purchasing workflows for contractors and businesses
- **Construction-Specific Features**: material tracking, project management, equipment rental
- **Enterprise Features**: company profiles, supplier management, invoice processing

## 🏗️ Architecture

Built with Clean Architecture principles and feature-based organization:

```
lib/
├── core/
│   ├── constants/
│   ├── enums/
│   ├── router/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── splash/
│   ├── auth/
│   ├── marketplace/          # B2C shopping: cart, wishlist, checkout, product browsing
│   ├── procurement/        # B2B/enterprise: RFQ, warehouse, inventory, bulk orders
│   ├── business/           # Company profiles, supplier/seller dashboard
│   ├── admin/              # Admin dashboard, roles, permissions, audit logs
│   └── chat/               # Cross-feature communication
└── main.dart
```

### Key Features Implemented
- ✅ Authentication Flow (Email/password, Google, Apple, Microsoft, Phone)
- ✅ Marketplace Home Screen with featured products, categories, and recommendations
- ✅ Product Listing with search and filtering capabilities
- ✅ Add to Cart functionality with persistence
- ✅ Product Detail viewing
- ✅ Category browsing
- ✅ Procurement module foundation (RFQ entities and repositories)
- ✅ Clean Architecture separation (domain/data/application/presentation layers)
- ✅ Firebase Authentication integration
- ✅ Riverpod state management
- ✅ GoRouter navigation
- ✅ Responsive UI with Glassmorphism design
- ✅ Product search with client-side filtering
- ✅ Structured project organization following TARGET FOLDER STRUCTURE

## 🛠️ Technical Stack

- **Framework**: Flutter 3.19+ with Dart 3
- **State Management**: Riverpod (hooks, providers, state notifiers)
- **Navigation**: GoRouter with typed routes
- **State Persistence**: SharedPreferences, planned Firestore persistence
- **UI Toolkit**: Material 3 with custom glassmorphic components
- **Backend**: Firebase (Auth, Firestore planned for production)
- **Dependency Injection**: Riverpod providers
- **Local Storage**: SharedPreferences for preferences/theme
- **Animations**: Hero transitions, fade/slide effects
- **Icons**: Material Icons

## 🏗️ Current Implementation Status

### Completed Features (Per PROGRESS.md)
- **Group 0 (Foundation)**: Structure cleanup completed
  - Removed backup files
  - Resolved duplicate enums (kept core/enums version)
  - Removed placeholder files
  - Migrated procurement code to dedicated feature module
  - Fixed import paths
- **Group 1 (Core B2C)**: In progress
  - ✅ Shopping Cart: Add to cart functionality implemented in home screen
  - ⏳ Wishlist: Not started
  - ⏳ Checkout: Not started
  - ⏳ Payments: Not started
  - ⏳ Orders: Not started
  - ⏳ Reviews/Ratings: Not started
  - ✅ Search: Client-side filtering implemented in Firestore product data source
  - ⏳ Advanced Filtering: Not started
  - ⏳ Coupons/Campaigns: Not started

### Core Architecture Components Completed
- **Authentication**: Complete email/password, social login ready
- **Marketplace Foundation**: Product browsing, search, cart basics
- **Procurement Foundation**: RFQ entities and repository interfaces migrated
- **UI Components**: GlassCard, PremiumButton, reusable widgets
- **Navigation**: GoRouter with proper route guards
- **State Management**: Riverpod providers for auth, theme

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.19+
- Dart SDK 3+
- Android Studio / VS Code with Flutter & Dart plugins
- Firebase account (for full backend functionality)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/suleymanalizada27-wq/FloodStore.git
cd FloodStore
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase** (for production features)
   - Run `flutterfire configure` 
   - Follow Firebase setup instructions in Firebase Console
   - This generates `lib/firebase_options.dart`

4. **Run the app**
```bash
flutter run
```

### Web Build
```bash
flutter build web
```

### APK Build (Development)
```bash
flutter build apk --debug
```

### APK Build (Release)
```bash
flutter build apk --release
```

## 🧪 Testing

Run all tests:
```bash
dart test
```

Format code:
```bash
dart format .
```

Analyze code:
```bash
flutter analyze
```

## 📱 Platform Support

- Mobile: Android, iOS
- Web: Chrome, Firefox, Safari, Edge
- Desktop: Windows, macOS, Linux (partial)

## 📚 Documentation

- [MARKETPLACE_ARCHITECTURE.md](MARKETPLACE_ARCHITECTURE.md) - Detailed marketplace architecture
- [PROCUREMENT_ARCHITECTURE.md](PROCUREMENT_ARCHITECTURE.md) - Procurement module architecture
- [ROADMAP.md](ROADMAP.md) - Feature implementation roadmap
- [PROGRESS.md](PROGRESS.md) - Development progress tracking
- [CLAUDE.md](CLAUDE.md) - Development guidelines and architecture rules

## 🔧 Development Guidelines

See [CLAUDE.md](CLAUDE.md) for:
- Clean Architecture principles
- Folder structure requirements
- Feature implementation order
- Firebase free tier constraints
- Code quality standards
- Testing requirements
- Performance optimization guidelines

## 📦 Firebase Free Tier Considerations

This project is designed to run entirely on Firebase's free Spark plan:
- ✅ Firestore reads/writes within free limits
- ✅ Firebase Auth within free limits
- ⚠️ Avoid Cloud Functions (require Blaze plan)
- ⚠️ Avoid third-party paid services (Algolia, etc.)
- ✅ Use Firestore-native queries instead of external search services
- ✅ Client-side filtering for search where appropriate
- ✅ Monitor Firestore reads to stay within 50K/day limit

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please read [CLAUDE.md](CLAUDE.md) for detailed contribution guidelines.

## 📄 License

This project is proprietary and confidential. All rights reserved.

## 🙏 Acknowledgments

- Flutter team for the excellent UI framework
- Riverpod team for the state management solution
- Firebase team for the backend infrastructure
- Material Design team for the design system
- Open source contributors whose packages we depend on