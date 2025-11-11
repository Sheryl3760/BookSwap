# BookSwap - Design Summary

## Database Schema

### Firestore Collections

#### 1. `users` Collection
Stores user profile information.

**Schema:**
```javascript
{
  uid: string,
  email: string,
  displayName: string?,
  photoUrl: string?,
  createdAt: timestamp
}
```

**Indexes:** None required for basic queries.

#### 2. `books` Collection
Stores all book listings posted by users.

**Schema:**
```javascript
{
  title: string,
  author: string,
  condition: string, // "newBook" | "likeNew" | "good" | "used"
  imageUrl: string?,
  userId: string,
  userEmail: string,
  swapFor: string?,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Indexes:**
- `createdAt` (descending) - for ordering listings
- `userId` + `createdAt` (composite) - for user's own listings

#### 3. `swaps` Collection
Stores swap offers between users.

**Schema:**
```javascript
{
  bookId: string,
  book: object, // Full book object snapshot
  senderId: string,
  senderEmail: string,
  recipientId: string,
  recipientEmail: string,
  status: string, // "pending" | "accepted" | "rejected"
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**Indexes:**
- `senderId` + `createdAt` (composite) - for sent offers
- `recipientId` + `createdAt` (composite) - for received offers
- `bookId` + `senderId` + `status` (composite) - for preventing duplicate offers

#### 4. `chats` Collection
Stores chat conversations between users.

**Schema:**
```javascript
{
  participants: array<string>,
  createdAt: timestamp,
  updatedAt: timestamp,
  messages: subcollection {
    chatId: string,
    senderId: string,
    senderEmail: string,
    message: string,
    timestamp: timestamp,
    isRead: boolean
  }
}
```

**Indexes:**
- `participants` (array-contains) + `updatedAt` (descending) - for listing user's chats
- `timestamp` (ascending) - for ordering messages within a chat

## Swap State Modeling

### Swap Status Enum
The swap state is modeled using an enum with three states:

1. **Pending**: Initial state when a swap offer is created. The book listing remains visible but the offer is awaiting response.
2. **Accepted**: The recipient has accepted the swap offer. Both parties can proceed with the exchange.
3. **Rejected**: The recipient has rejected the swap offer. The sender is notified and can make other offers.

### State Transitions
```
[Pending] → [Accepted] (by recipient)
[Pending] → [Rejected] (by recipient)
```

### Implementation Details
- When a swap is created, the status is set to `pending`
- Only the recipient can change the status from `pending` to `accepted` or `rejected`
- The book object is stored as a snapshot in the swap document to preserve the book details at the time of the offer
- Real-time listeners update the UI when swap status changes

## State Management Implementation

### Provider Pattern
The app uses the Provider pattern for state management, which provides:
- Reactive updates across the app
- Separation of business logic from UI
- Easy testing and maintenance

### Providers

#### 1. `AuthProvider`
- Manages authentication state
- Handles sign up, sign in, sign out
- Manages email verification flow
- Listens to Firebase Auth state changes

#### 2. `BookProvider`
- Manages book listings CRUD operations
- Provides streams for real-time updates
- Handles image uploads to Firebase Storage
- Validates user permissions for edit/delete

#### 3. `SwapProvider`
- Manages swap offers
- Provides streams for sent and received offers
- Handles swap status updates
- Prevents duplicate swap offers

#### 4. `ChatProvider`
- Manages chat messages
- Generates chat IDs for user pairs
- Handles message sending and reading status
- Provides real-time message streams

### State Flow
1. User actions trigger provider methods
2. Providers interact with Firebase services
3. Firebase streams emit updates
4. Providers notify listeners
5. UI widgets rebuild with new state

## Design Trade-offs and Challenges

### Trade-offs

1. **Book Snapshot in Swaps**
   - **Decision**: Store full book object in swap document
   - **Rationale**: Preserves book details at time of offer, even if original listing is deleted
   - **Trade-off**: Data duplication, but ensures swap history integrity

2. **Real-time vs Polling**
   - **Decision**: Use Firestore streams for real-time updates
   - **Rationale**: Better UX with instant updates, no manual refresh needed
   - **Trade-off**: Higher Firebase costs, but better user experience

3. **Image Storage**
   - **Decision**: Store images in Firebase Storage, URLs in Firestore
   - **Rationale**: Efficient storage and CDN delivery
   - **Trade-off**: Additional service to manage, but better performance

4. **Chat ID Generation**
   - **Decision**: Generate deterministic chat IDs from sorted user IDs
   - **Rationale**: Ensures same chat ID for same user pair, prevents duplicates
   - **Trade-off**: Requires both user IDs, but simpler than querying

### Challenges

1. **Email Verification Flow**
   - **Challenge**: Users need to verify email before using the app
   - **Solution**: Created dedicated email verification screen with resend option
   - **Learning**: Clear user feedback is essential for verification flow

2. **Real-time Updates**
   - **Challenge**: Ensuring UI updates when data changes in Firestore
   - **Solution**: Used StreamBuilder widgets with Firestore streams
   - **Learning**: Proper stream management prevents memory leaks

3. **Image Upload**
   - **Challenge**: Handling image selection, upload, and error states
   - **Solution**: Used image_picker with Firebase Storage, added loading states
   - **Learning**: Always provide user feedback during async operations

4. **Swap State Management**
   - **Challenge**: Preventing duplicate swap offers and managing state transitions
   - **Solution**: Check for existing pending offers before creating new ones
   - **Learning**: Validate business rules at the provider level

5. **Navigation Structure**
   - **Challenge**: Managing 5 screens with bottom navigation
   - **Solution**: Used TabBar for My Offers (Sent/Received) to save navigation space
   - **Learning**: Group related screens to improve navigation UX

### Future Improvements

1. **Push Notifications**: Implement Firebase Cloud Messaging for swap offers and messages
2. **Search Functionality**: Add search and filter capabilities for book listings
3. **User Profiles**: Enhanced user profiles with ratings and reviews
4. **Swap History**: Detailed history of completed swaps
5. **Book Categories**: Organize books by subject/category
6. **Location-based**: Add location features for local swaps
7. **Image Compression**: Compress images before upload to reduce storage costs

