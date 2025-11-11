import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookswap/models/swap_model.dart';
import 'package:bookswap/models/book_model.dart';

class SwapProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SwapModel> _myOffers = [];
  List<SwapModel> _receivedOffers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SwapModel> get myOffers => _myOffers;
  List<SwapModel> get receivedOffers => _receivedOffers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SwapProvider() {
    loadMyOffers();
    loadReceivedOffers();
  }

  Stream<List<SwapModel>> getMyOffersStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('swaps')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<SwapModel>> getReceivedOffersStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('swaps')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> loadMyOffers() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('swaps')
          .where('senderId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _myOffers = snapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading offers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReceivedOffers() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('swaps')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _receivedOffers = snapshot.docs
          .map((doc) => SwapModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading received offers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSwapOffer(BookModel book) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      if (user.uid == book.userId) {
        _errorMessage = 'You cannot swap your own book';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      notifyListeners();

      // Check if swap already exists
      final existingSwap = await _firestore
          .collection('swaps')
          .where('bookId', isEqualTo: book.id)
          .where('senderId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingSwap.docs.isNotEmpty) {
        _errorMessage = 'You have already sent a swap offer for this book';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final swapData = {
        'bookId': book.id,
        'book': book.toMap(),
        'senderId': user.uid,
        'senderEmail': user.email ?? '',
        'recipientId': book.userId,
        'recipientEmail': book.userEmail,
        'status': SwapStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('swaps').add(swapData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error creating swap offer: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSwapStatus(String swapId, SwapStatus status) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      notifyListeners();

      final swapRef = _firestore.collection('swaps').doc(swapId);
      final swapDoc = await swapRef.get();

      if (!swapDoc.exists) {
        _errorMessage = 'Swap offer not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final swapData = swapDoc.data()!;
      if (status == SwapStatus.accepted || status == SwapStatus.rejected) {
        if (swapData['recipientId'] != user.uid) {
          _errorMessage = 'You can only accept/reject offers sent to you';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      await swapRef.update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating swap status: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

