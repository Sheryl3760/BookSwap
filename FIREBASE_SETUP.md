# Firebase Setup Instructions

## Step 1: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## Step 2: Configure Firebase

Run the following command in your project root:

```bash
flutterfire configure
```

This will:
1. Ask you to select your Firebase project (or create a new one)
2. Select the platforms you want to support (Android, iOS, Web, etc.)
3. Automatically generate and update `lib/firebase_options.dart` with your project's configuration

## Step 3: Verify Configuration

After running `flutterfire configure`, check that `lib/firebase_options.dart` has been updated with your actual Firebase project credentials (not placeholder values).

## Step 4: Enable Firebase Services

In the Firebase Console (https://console.firebase.google.com/):

1. **Authentication**: 
   - Go to Authentication > Sign-in method
   - Enable "Email/Password" provider

2. **Firestore Database**:
   - Go to Firestore Database
   - Create database in test mode (or production mode with proper security rules)

3. **Storage** (optional, for book images):
   - Go to Storage
   - Get started with default security rules

## Step 5: Run the App

After configuration, you can run the app:

```bash
flutter run
```

## Troubleshooting

If you still get the "No Firebase App" error:
1. Make sure you ran `flutterfire configure`
2. Check that `lib/firebase_options.dart` has real values (not "YOUR_PROJECT_ID")
3. Run `flutter clean` and `flutter pub get`
4. Restart your emulator/device

