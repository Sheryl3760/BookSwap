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
  final String title;
  final String author;
  final BookCondition condition;
  final String? imageUrl;
  final String userId;
  final String userEmail;
  final String? swapFor;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    required this.userId,
    required this.userEmail,
    this.swapFor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookModel.fromMap(Map<String, dynamic> map, String id) {
    return BookModel(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: BookCondition.values.firstWhere(
        (e) => e.name == map['condition'],
        orElse: () => BookCondition.good,
      ),
      imageUrl: map['imageUrl'],
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      swapFor: map['swapFor'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition.name,
      'imageUrl': imageUrl,
      'userId': userId,
      'userEmail': userEmail,
      'swapFor': swapFor,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    BookCondition? condition,
    String? imageUrl,
    String? userId,
    String? userEmail,
    String? swapFor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      swapFor: swapFor ?? this.swapFor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

