import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapStatus {
  pending,
  accepted,
  rejected;

  String get displayName {
    switch (this) {
      case SwapStatus.pending:
        return 'Pending';
      case SwapStatus.accepted:
        return 'Accepted';
      case SwapStatus.rejected:
        return 'Rejected';
    }
  }
}

class SwapModel {
  final String id;
  final String bookId;
  final Map<String, dynamic> book;
  final String senderId;
  final String senderEmail;
  final String recipientId;
  final String recipientEmail;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SwapModel({
    required this.id,
    required this.bookId,
    required this.book,
    required this.senderId,
    required this.senderEmail,
    required this.recipientId,
    required this.recipientEmail,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SwapModel.fromMap(Map<String, dynamic> map, String id) {
    return SwapModel(
      id: id,
      bookId: map['bookId'] ?? '',
      book: map['book'] ?? {},
      senderId: map['senderId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      recipientId: map['recipientId'] ?? '',
      recipientEmail: map['recipientEmail'] ?? '',
      status: SwapStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SwapStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'book': book,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'recipientId': recipientId,
      'recipientEmail': recipientEmail,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
