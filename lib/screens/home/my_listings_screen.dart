import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/swap_provider.dart';
import '../../models/swap_model.dart';
import '../../widgets/my_book_card.dart';
import 'post_book_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Listings'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFBF3F),
            labelColor: Color(0xFFFFBF3F),
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'My Books'),
              Tab(text: 'Swap Offers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MyBooksTab(),
            _SwapOffersTab(),
          ],
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
      ),
    );
  }
}

class _MyBooksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    if (bookProvider.myBooks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No books posted yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookProvider.myBooks.length,
        itemBuilder: (context, index) {
          return MyBookCard(book: bookProvider.myBooks[index]);
        },
      ),
    );
  }
}

class _SwapOffersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final swapProvider = Provider.of<SwapProvider>(context);

    final sentOffers = swapProvider.myOffers;
    final receivedOffers = swapProvider.receivedOffers;

    if (sentOffers.isEmpty && receivedOffers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No swap offers yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (receivedOffers.isNotEmpty) ...[
            const Text(
              'Received Offers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...receivedOffers.map((offer) => _SwapOfferCard(
                  offer: offer,
                  isReceived: true,
                )),
          ],
          if (receivedOffers.isNotEmpty && sentOffers.isNotEmpty)
            const SizedBox(height: 24),
          if (sentOffers.isNotEmpty) ...[
            const Text(
              'Sent Offers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...sentOffers.map((offer) => _SwapOfferCard(
                  offer: offer,
                  isReceived: false,
                )),
          ],
        ],
      ),
    );
  }
}

class _SwapOfferCard extends StatelessWidget {
  final dynamic offer;
  final bool isReceived;

  const _SwapOfferCard({
    required this.offer,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.bookTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReceived
                            ? 'From: ${offer.senderEmail}'
                            : 'To: ${offer.receiverEmail}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(offer.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    offer.status.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (isReceived && offer.status.name == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final success = await swapProvider.updateSwapStatus(
                          offer.id,
                          SwapStatus.accepted,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Swap offer accepted!'
                                    : 'Failed to accept offer',
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final success = await swapProvider.updateSwapStatus(
                          offer.id,
                          SwapStatus.rejected,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Swap offer rejected'
                                    : 'Failed to reject offer',
                              ),
                              backgroundColor:
                                  success ? Colors.orange : Colors.red,
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    switch (status.name) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
