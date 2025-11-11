# How to Run the BookSwap App

## Prerequisites

✅ Flutter is already installed and working on your system
✅ Dependencies are installed (`flutter pub get` completed)
✅ Code analysis shows no critical errors

## Important: Firebase Setup Required

⚠️ **The app requires Firebase to be configured before it can run!**

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Enable **Authentication** with Email/Password
4. Create a **Firestore Database** (start in test mode)
5. Enable **Firebase Storage**

### Step 2: Configure FlutterFire

Run this command in your terminal:

```bash
flutterfire configure
```

This will:
- Ask you to select your Firebase project
- Generate `lib/firebase_options.dart` with your credentials
- Configure Firebase for your platforms

### Step 3: Run the App

Once Firebase is configured, you can run:

```bash
# For Android
flutter run

# For iOS (Mac only)
flutter run -d ios

# For Web
flutter run -d chrome

# For Windows
flutter run -d windows
```

## Current Project Status

✅ All Flutter code is written and ready
✅ UI matches the design screenshots
✅ Dependencies installed
✅ Code compiles (only style warnings, no errors)
⚠️ **Waiting for Firebase configuration**

## UI Features Implemented

- ✅ Splash screen with BookSwap branding
- ✅ Login/Signup screens with dark blue background
- ✅ Browse Listings with light grey header
- ✅ Post Book screen with condition buttons (matching design)
- ✅ My Listings screen
- ✅ My Offers screen (Sent/Received tabs)
- ✅ Chat screens
- ✅ Settings screen
- ✅ Bottom navigation bar

## Next Steps

1. **Set up Firebase** (see Step 1-2 above)
2. **Run the app** to see it in action
3. **Test all features**:
   - Sign up/Login
   - Post books
   - Create swap offers
   - Chat functionality
   - Settings

## Note About Repository

This project is currently in the `Reflexar` directory. If you want it in a **new repository**, you can:

1. Create a new GitHub repository
2. Copy all the Flutter files to a new directory
3. Initialize git: `git init`
4. Add remote: `git remote add origin <your-repo-url>`
5. Commit and push

Or I can help you set up a clean new directory structure if needed!

