# BookSwap - Flutter App

A marketplace where students can exchange textbooks. Built with Flutter and Firebase.

## Features

- **Authentication**: Sign up, login, logout with Firebase Auth and email verification
- **Book Listings**: Create, read, update, and delete book listings
- **Swap Functionality**: Initiate swap offers with real-time status updates (Pending, Accepted, Rejected)
- **Chat System**: Real-time messaging between users
- **State Management**: Provider pattern for reactive state management
- **Navigation**: Bottom navigation bar with 4 main screens

## Setup Instructions

### 1. Firebase Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication with Email/Password
3. Create a Firestore database
4. Enable Firebase Storage
5. Run `flutterfire configure` to generate `firebase_options.dart` with your Firebase credentials

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user_model.dart
│   ├── book_model.dart
│   ├── swap_model.dart
│   └── chat_message_model.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── book_provider.dart
│   ├── swap_provider.dart
│   └── chat_provider.dart
└── screens/                  # UI screens
    ├── splash_screen.dart
    ├── auth/
    │   ├── login_screen.dart
    │   └── signup_screen.dart
    ├── home_screen.dart
    ├── browse_listings_screen.dart
    ├── my_listings_screen.dart
    ├── post_book_screen.dart
    ├── book_detail_screen.dart
    ├── chats_screen.dart
    ├── chat_screen.dart
    └── settings_screen.dart
```

## Database Schema

### Collections

#### `users`
- `uid` (string)
- `email` (string)
- `displayName` (string, optional)
- `photoUrl` (string, optional)
- `createdAt` (timestamp)

#### `books`
- `title` (string)
- `author` (string)
- `condition` (string: newBook, likeNew, good, used)
- `imageUrl` (string, optional)
- `userId` (string)
- `userEmail` (string)
- `swapFor` (string, optional)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)

#### `swaps`
- `bookId` (string)
- `book` (map: full book object)
- `senderId` (string)
- `senderEmail` (string)
- `recipientId` (string)
- `recipientEmail` (string)
- `status` (string: pending, accepted, rejected)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)

#### `chats`
- `participants` (array of strings)
- `createdAt` (timestamp)
- `updatedAt` (timestamp)
- `messages` (subcollection)
  - `chatId` (string)
  - `senderId` (string)
  - `senderEmail` (string)
  - `message` (string)
  - `timestamp` (timestamp)
  - `isRead` (boolean)

## State Management

The app uses the Provider pattern for state management:
- `AuthProvider`: Handles authentication state
- `BookProvider`: Manages book listings CRUD operations
- `SwapProvider`: Handles swap offers and status updates
- `ChatProvider`: Manages chat messages

## Firestore Security Rules

Make sure to set up appropriate security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    match /swaps/{swapId} {
      allow read: if request.auth != null && 
        (resource.data.senderId == request.auth.uid || 
         resource.data.recipientId == request.auth.uid);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        resource.data.recipientId == request.auth.uid;
    }
    
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
  }
}
```

## Dependencies

- `firebase_core`: ^2.24.2
- `firebase_auth`: ^4.15.3
- `cloud_firestore`: ^4.13.6
- `firebase_storage`: ^11.5.6
- `provider`: ^6.1.1
- `image_picker`: ^1.0.7
- `cached_network_image`: ^3.3.0
- `intl`: ^0.18.1
- `uuid`: ^4.2.1

## Notes

- Make sure to configure Firebase properly before running the app
- The app requires internet connection for Firebase services
- Email verification is required before users can use the app
- Image uploads require Firebase Storage to be configured
