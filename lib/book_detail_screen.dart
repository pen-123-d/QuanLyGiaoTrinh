// File: book_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_controller.dart';
import 'edit_book_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> bookData;

  const BookDetailScreen({super.key, required this.bookData});

  @override
  Widget build(BuildContext context) {
    final tagBg = bookData['tagBg'] ?? const Color(0xFFDBEAFE);
    final tagText = bookData['tagText'] ?? const Color(0xFF1E40AF);

    // Kiểm tra xem ID người đang dùng app có khớp với ID người bán cuốn sách này không
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isMyBook = currentUserId == bookData['sellerId'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giáo trình'),
        actions: [
          // Nếu là sách của mình thì hiện nút Xóa (Thùng rác)
          if (isMyBook)
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 28),
              onPressed: () {
                // Hiện bảng cảnh báo trước khi xóa
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa giáo trình'),
                    content: const Text('Bạn có chắc chắn muốn xóa cuốn giáo trình này không? Hành động này không thể hoàn tác.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Hủy
                        child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Lệnh xóa data trên Firebase
                          await FirebaseFirestore.instance
                              .collection('books')
                              .doc(bookData['id'])
                              .delete();

                          if (context.mounted) {
                            Navigator.pop(context); // Đóng bảng cảnh báo
                            Navigator.pop(context); // Thoát khỏi màn hình Chi Tiết về lại Trang Chủ
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã xóa giáo trình!'), backgroundColor: Colors.green),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Xóa ngay', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          // Trong phần actions của AppBar:
          if (isMyBook)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditBookScreen(bookData: bookData)),
                );
              },
            ),
          // Nút Đánh dấu Đã bán (Chỉ hiện nếu là sách của mình và chưa bán)
          if (isMyBook && bookData['status'] != 'Đã bán')
            IconButton(
              tooltip: 'Đánh dấu Đã bán',
              icon: const Icon(Icons.sell_rounded, color: Colors.greenAccent, size: 26),
              onPressed: () async {
                // Lệnh cập nhật trạng thái trên Firebase
                await FirebaseFirestore.instance
                    .collection('books')
                    .doc(bookData['id'])
                    .update({'status': 'Đã bán'});

                if (context.mounted) {
                  Navigator.pop(context); // Quay về trang trước để dữ liệu tự làm mới
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật trạng thái Đã bán!'), backgroundColor: Colors.green),
                  );
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ẢNH BÌA SÁCH
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              ),
              child: Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. TÊN SÁCH & GIÁ TIỀN
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          bookData['title'] ?? 'Tên sách',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${bookData['price']} đ',
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // TAG TÌNH TRẠNG SÁCH
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bookData['status'] ?? 'Đang cập nhật',
                      style: TextStyle(
                        color: tagText,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. THÔNG TIN CHI TIẾT
                  const Text(
                    'Thông tin cơ bản',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.school_outlined, 'Chuyên ngành', bookData['major'] ?? 'Đang cập nhật'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(height: 1),
                          ),
                          _buildDetailRow(Icons.access_time_rounded, 'Ngày đăng', _formatDate(bookData['createdAt'])),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. MÔ TẢ TỪ NGƯỜI BÁN
                  const Text(
                    'Mô tả chi tiết',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (bookData['description'] == null || bookData['description'].toString().trim().isEmpty)
                        ? 'Người bán không cung cấp mô tả chi tiết.'
                        : bookData['description'],
                    style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                  ),

                  const SizedBox(height: 12),
                  // 5. THÔNG TIN NGƯỜI BÁN
                  const Text(
                    'Thông tin người bán',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // THAY THẾ TOÀN BỘ CARD CŨ BẰNG ĐOẠN NÀY:
                  FutureBuilder<Map<String, dynamic>?>(
                    future: ProfileController().getUserById(bookData['sellerId']),
                    builder: (context, snapshot) {
                      String userName = "Đang tải...";
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data != null) {
                          userName = snapshot.data!['fullName'] ?? "Người dùng";
                        } else {
                          userName = "Người dùng ẩn danh";
                        }
                      }

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.person, color: Colors.white, size: 28),
                          ),
                          title: Text(
                            userName, // Tên người bán thật sẽ hiện ở đây
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: const Text('Đã xác thực SĐT'),
                          trailing: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.green.withOpacity(0.1),
                            ),
                            icon: const Icon(Icons.phone, color: Colors.green),
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),


      // 6. 2 NÚT GỌI ĐIỆN VÀ ZALO BÁM ĐÁY MÀN HÌNH
      bottomNavigationBar: isMyBook
          ? const SizedBox.shrink()
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // NÚT GỌI ĐIỆN
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Lấy số điện thoại người bán từ database
                    final seller = await ProfileController().getUserById(bookData['sellerId']);
                    final phone = seller?['phoneNumber'] ?? '';

                    if (phone.isNotEmpty) {
                      final Uri url = Uri.parse('tel:$phone');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Người bán chưa cập nhật số điện thoại!')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.call_rounded),
                  label: const Text('Gọi ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // NÚT CHAT ZALO
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final seller = await ProfileController().getUserById(bookData['sellerId']);
                    final phone = seller?['phoneNumber'] ?? '';

                    if (phone.isNotEmpty) {
                      // Link mở trực tiếp app Zalo
                      final Uri url = Uri.parse('https://zalo.me/$phone');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Người bán chưa cập nhật số điện thoại!')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Chat Zalo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text('$title:', style: TextStyle(fontSize: 15, color: Colors.grey[700])),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Không rõ';
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}