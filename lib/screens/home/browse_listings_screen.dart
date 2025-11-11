import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/book_card.dart';
import 'post_book_screen.dart';

class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid;

    final otherUsersBooks = bookProvider.allBooks
        .where((book) => book.userId != currentUserId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
        centerTitle: true,
      ),
      body: otherUsersBooks.isEmpty
          ? const Center(
              child: Text(
                'No books available yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                // Data updates automatically via Stream
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: otherUsersBooks.length,
                itemBuilder: (context, index) {
                  return BookCard(book: otherUsersBooks[index]);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PostBookScreen()),
          );
        },
        backgroundColor: const Color(0xFFFFBF3F),
        foregroundColor: const Color(0xFF1E1E3F),
        icon: const Icon(Icons.add),
        label: const Text('Post Book'),
      ),
    );
  }
}
