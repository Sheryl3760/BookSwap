import 'package:cloud_firestore/cloud_firestore.dart';

enum BookCondition {
  newBook,
  likeNew,
  good,
  used;

  String get displayName {
    switch (this) {
      case BookCondition.newBook:
        return 'New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.good:
        return 'Good';
      case BookCondition.used:
        return 'Used';
    }
  }
}

class BookModel {
  final String id;
  final String userId;
  final String userEmail;
  final String title;
  final String author;
  final BookCondition condition;
  final String? imageUrl;
  final String? swapFor;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    this.swapFor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String id) {
    return BookModel(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: BookCondition.values.firstWhere(
        (e) => e.name == map['condition'],
        orElse: () => BookCondition.good,
      ),
      imageUrl: map['imageUrl'],
      swapFor: map['swapFor'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'title': title,
      'author': author,
      'condition': condition.name,
      'imageUrl': imageUrl,
      'swapFor': swapFor,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
