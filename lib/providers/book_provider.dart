import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:bookswap/models/book_model.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<BookModel> _allBooks = [];
  List<BookModel> _myBooks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BookModel> get allBooks => _allBooks;
  List<BookModel> get myBooks => _myBooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BookProvider() {
    loadAllBooks();
    loadMyBooks();
  }

  Stream<List<BookModel>> getAllBooksStream() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<BookModel>> getMyBooksStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('books')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> loadAllBooks() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('books')
          .orderBy('createdAt', descending: true)
          .get();

      _allBooks = snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading books: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyBooks() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('books')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _myBooks = snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading my books: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = _storage.ref().child('book_images/$userId/$fileName');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      _errorMessage = 'Error uploading image: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> createBook({
    required String title,
    required String author,
    required BookCondition condition,
    File? imageFile,
    String? swapFor,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      notifyListeners();

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
      }

      final bookData = {
        'title': title,
        'author': author,
        'condition': condition.name,
        'imageUrl': imageUrl,
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'swapFor': swapFor,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('books').add(bookData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error creating book: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook({
    required String bookId,
    required String title,
    required String author,
    required BookCondition condition,
    File? imageFile,
    String? swapFor,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      notifyListeners();

      final bookRef = _firestore.collection('books').doc(bookId);
      final bookDoc = await bookRef.get();

      if (!bookDoc.exists || bookDoc.data()?['userId'] != user.uid) {
        _errorMessage = 'You can only edit your own books';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      Map<String, dynamic> updateData = {
        'title': title,
        'author': author,
        'condition': condition.name,
        'swapFor': swapFor,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (imageFile != null) {
        final imageUrl = await uploadImage(imageFile);
        if (imageUrl != null) {
          updateData['imageUrl'] = imageUrl;
        }
      }

      await bookRef.update(updateData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating book: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _errorMessage = 'User not authenticated';
        notifyListeners();
        return false;
      }

      _isLoading = true;
      notifyListeners();

      final bookRef = _firestore.collection('books').doc(bookId);
      final bookDoc = await bookRef.get();

      if (!bookDoc.exists || bookDoc.data()?['userId'] != user.uid) {
        _errorMessage = 'You can only delete your own books';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await bookRef.delete();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting book: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
