import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_detail_screen.dart';

class ManageBooksScreen extends StatelessWidget {
  const ManageBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý sách của tôi')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('sellerId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final books = snapshot.data!.docs;
          if (books.isEmpty) return const Center(child: Text('Bạn chưa đăng cuốn sách nào.'));

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookData = books[index].data() as Map<String, dynamic>;
              bookData['id'] = books[index].id;

              // Kiểm tra xem sách đã bán chưa
              final isSold = bookData['status'] == 'Đã bán';

              return Opacity(
                opacity: isSold ? 0.6 : 1.0, // Làm mờ 60% nếu đã bán
                child: Card(
                  elevation: isSold ? 0 : 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isSold ? Colors.grey.shade100 : Colors.white,
                  child: ListTile(
                    leading: Stack(
                      children: [
                        SizedBox(width: 50, height: 70, child: Image.network(bookData['imageUrl'] ?? '', fit: BoxFit.cover)),
                        if (isSold)
                          Container(
                            width: 50, height: 70,
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 20)),
                          )
                      ],
                    ),
                    title: Text(
                      bookData['title'] ?? 'Tên sách',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isSold ? TextDecoration.lineThrough : null, // Gạch ngang tên nếu đã bán
                      ),
                    ),
                    subtitle: Text(
                      isSold ? 'ĐÃ BÁN' : '${bookData['price']} đ',
                      style: TextStyle(
                        color: isSold ? Colors.red : Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailScreen(bookData: bookData)));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}