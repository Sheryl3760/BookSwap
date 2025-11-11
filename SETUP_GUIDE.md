# BookSwap - Setup Guide

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase account
- Android Studio / VS Code with Flutter extensions
- Android device/emulator or iOS device/simulator

## Step 1: Firebase Project Setup

### 1.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard to create your project

### 1.2 Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Email/Password** authentication
4. (Optional) Configure email templates for verification

### 1.3 Create Firestore Database

1. Go to **Firestore Database**
2. Click "Create database"
3. Start in **test mode** (we'll add security rules later)
4. Choose a location for your database
5. Click "Enable"

### 1.4 Enable Firebase Storage

1. Go to **Storage**
2. Click "Get started"
3. Start in **test mode**
4. Choose a location (preferably same as Firestore)
5. Click "Done"

### 1.5 Configure Firestore Indexes

Go to **Firestore Database** > **Indexes** and create these composite indexes:

1. **books collection:**
   - Collection: `books`
   - Fields: `userId` (Ascending), `createdAt` (Descending)
   - Query scope: Collection

2. **swaps collection:**
   - Collection: `swaps`
   - Fields: `senderId` (Ascending), `createdAt` (Descending)
   - Query scope: Collection

3. **swaps collection:**
   - Collection: `swaps`
   - Fields: `recipientId` (Ascending), `createdAt` (Descending)
   - Query scope: Collection

4. **swaps collection:**
   - Collection: `swaps`
   - Fields: `bookId` (Ascending), `senderId` (Ascending), `status` (Ascending)
   - Query scope: Collection

5. **chats collection:**
   - Collection: `chats`
   - Fields: `participants` (Array), `updatedAt` (Descending)
   - Query scope: Collection

### 1.6 Set Up Security Rules

Go to **Firestore Database** > **Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Books: anyone authenticated can read, only owner can write
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Swaps: users can read their own swaps, create new ones, update received ones
    match /swaps/{swapId} {
      allow read: if request.auth != null && 
        (resource.data.senderId == request.auth.uid || 
         resource.data.recipientId == request.auth.uid);
      allow create: if request.auth != null && 
        request.resource.data.senderId == request.auth.uid;
      allow update: if request.auth != null && 
        resource.data.recipientId == request.auth.uid;
    }
    
    // Chats: users can read/write chats they're participants in
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
      
      // Messages subcollection
      match /messages/{messageId} {
        allow read: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
        allow create: if request.auth != null && 
          request.auth.uid == request.resource.data.senderId;
        allow update: if request.auth != null;
      }
    }
  }
}
```

Go to **Storage** > **Rules** and paste:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 2: Flutter Project Setup

### 2.1 Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 2.2 Configure Firebase for Flutter

1. Make sure you're in the project root directory
2. Run:
```bash
flutterfire configure
```

3. Select your Firebase project
4. Select platforms (Android, iOS, etc.)
5. This will generate `lib/firebase_options.dart` with your Firebase credentials

### 2.3 Install Dependencies

```bash
flutter pub get
```

### 2.4 Create Assets Directory

```bash
mkdir -p assets/images
```

## Step 3: Platform-Specific Setup

### Android Setup

1. Open `android/app/build.gradle`
2. Ensure `minSdkVersion` is at least 21:
```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

3. No additional configuration needed if you used `flutterfire configure`

### iOS Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Ensure deployment target is iOS 11.0 or higher
3. No additional configuration needed if you used `flutterfire configure`

## Step 4: Run the App

### 4.1 Check Connected Devices

```bash
flutter devices
```

### 4.2 Run the App

```bash
flutter run
```

## Step 5: Testing the App

### 5.1 Create Test Accounts

1. Run the app
2. Sign up with a test email
3. Check your email for verification link
4. Verify the email
5. Sign in

### 5.2 Test Features

1. **Authentication:**
   - Sign up with new account
   - Verify email
   - Sign in
   - Sign out

2. **Book Listings:**
   - Post a book with image
   - View all listings
   - Edit your book
   - Delete your book

3. **Swap Functionality:**
   - Create a swap offer
   - View sent offers
   - View received offers
   - Accept/reject offers

4. **Chat:**
   - Open chat from book detail
   - Send messages
   - View chat list

## Troubleshooting

### Common Issues

1. **Firebase not initialized:**
   - Make sure `firebase_options.dart` is properly generated
   - Check that Firebase is initialized in `main.dart`

2. **Permission denied errors:**
   - Check Firestore security rules
   - Verify user is authenticated
   - Check Storage rules for image uploads

3. **Image picker not working:**
   - Android: Check `android/app/src/main/AndroidManifest.xml` for permissions
   - iOS: Check `ios/Runner/Info.plist` for permissions

4. **Build errors:**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Delete `pubspec.lock` and run `flutter pub get` again

### Getting Dart Analyzer Report

1. Open the project in VS Code or Android Studio
2. Run the analyzer:
   ```bash
   flutter analyze
   ```
3. Save the output to a file:
   ```bash
   flutter analyze > analyzer_report.txt
   ```

## Next Steps

- Customize the UI colors and styling
- Add more features (search, filters, etc.)
- Set up Firebase Cloud Messaging for push notifications
- Deploy to Google Play Store / App Store

## Support

For issues or questions:
- Check Flutter documentation: https://flutter.dev/docs
- Check Firebase documentation: https://firebase.google.com/docs
- Review the code comments in the project

