# SMC Healthcare App

A Flutter application with Firebase backend integration for healthcare management.

## 🔥 Firebase Integration

This app has been fully integrated with Firebase backend services:

- ✅ **Firebase Core** - Initialized and ready
- ✅ **Firebase Authentication** - Email/password auth
- ✅ **Cloud Firestore** - NoSQL database
- ✅ **Firebase Storage** - File storage

### Quick Links
- 📖 [Firebase Integration Guide](FIREBASE_INTEGRATION.md)
- 📋 [Integration Checklist](CHECKLIST.md)
- 📝 [Integration Summary](INTEGRATION_SUMMARY.md)
- 💡 [Code Examples](lib/services/firebase_examples.dart)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.10.8)
- Android Studio / VS Code
- Firebase account

### Installation

```bash
# Clone the repository
cd c:\SMC\smc

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Setup

1. **Enable Firebase Services** in Firebase Console:
   - Authentication → Enable Email/Password
   - Firestore Database → Create Database
   - Storage → Enable Storage

2. **Configure Security Rules** (see `FIREBASE_INTEGRATION.md`)

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point (Firebase initialized)
└── services/                    # Firebase services
    ├── firebase_service.dart    # Core Firebase singleton
    ├── auth_service.dart        # Authentication
    ├── firestore_service.dart   # Database operations
    ├── storage_service.dart     # File storage
    └── firebase_examples.dart   # Usage examples
```

## 🔧 Firebase Services

### Authentication
```dart
final authService = AuthService();
await authService.signInWithEmail(email: email, password: password);
```

### Firestore
```dart
final firestoreService = FirestoreService();
await firestoreService.createDocument(collection: 'users', data: {...});
```

### Storage
```dart
final storageService = StorageService();
await storageService.uploadFile(filePath: path, storagePath: 'uploads/file.jpg');
```

## 📚 Documentation

- **Firebase Integration**: See [FIREBASE_INTEGRATION.md](FIREBASE_INTEGRATION.md)
- **Code Examples**: See [lib/services/firebase_examples.dart](lib/services/firebase_examples.dart)
- **Flutter Docs**: [flutter.dev](https://docs.flutter.dev/)
- **Firebase Docs**: [firebase.google.com](https://firebase.google.com/docs)

## 🎯 Firebase Project Info

- **Project ID**: `smc-healthcare`
- **Package Name**: `in.gov.smc.smc_app`
- **Storage Bucket**: `smc-healthcare.firebasestorage.app`

## 📝 Notes

- All Firebase services are production-ready and null-safe
- UI/UX has been preserved - no design changes made
- Services use singleton pattern for efficiency
- All operations include error handling and debug logs

## 🤝 Contributing

When adding new screens:
1. Import required services
2. Wire Firebase logic to existing widgets
3. Maintain UI/UX consistency
4. Add error handling

See [FIREBASE_INTEGRATION.md](FIREBASE_INTEGRATION.md) for integration patterns.

## 📄 License

This project is private and confidential.

