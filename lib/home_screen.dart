// File: home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Biến lưu trữ từ khóa tìm kiếm và danh mục đang chọn
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  // Cập nhật lại danh sách chuyên ngành cho khớp chính xác với trang Đăng bán
  final List<String> categories = [
    'Tất cả',
    'Công nghệ thông tin',
    'Kinh tế',
    'Ngoại ngữ',
    'Cơ điện tử',
    'Đại cương'
  ];

  Color _getTagBgColor(String status) {
    if (status.contains('Mới 100%')) return const Color(0xFFDCFCE7);
    if (status.contains('90%')) return const Color(0xFFDBEAFE);
    if (status.contains('Cũ')) return const Color(0xFFFEF3C7);
    return const Color(0xFFF3E8FF);
  }

  Color _getTagTextColor(String status) {
    if (status.contains('Mới 100%')) return const Color(0xFF166534);
    if (status.contains('90%')) return const Color(0xFF1E40AF);
    if (status.contains('Cũ')) return const Color(0xFF92400E);
    return const Color(0xFF6B21A8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giáo Trình Mới Đăng'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 2. THANH TÌM KIẾM
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: TextField(
              // Bắt sự kiện mỗi khi người dùng gõ phím
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase(); // Lưu lại chữ thường để dễ tìm
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm giáo trình bạn cần...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 3. DANH MỤC LỌC (Vuốt ngang)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                      ),
                    ),
                    onSelected: (bool selected) {
                      // Cập nhật lại danh mục đang chọn khi người dùng bấm vào
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // 4. DANH SÁCH GIÁO TRÌNH LẤY TỪ FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Chưa có giáo trình nào được đăng bán.', style: TextStyle(color: Colors.grey)),
                  );
                }

                // 5. BỘ LỌC DỮ LIỆU TẠI CHỖ
                final allBooks = snapshot.data!.docs;
                final filteredBooks = allBooks.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final major = data['major'] ?? '';
                  final status = data['status'] ?? '';

                  // Kiểm tra xem tên sách có chứa chữ người dùng gõ không
                  final matchesSearch = title.contains(_searchQuery);
                  // Kiểm tra xem chuyên ngành có khớp với nút đang bấm không
                  final matchesCategory = _selectedCategory == 'Tất cả' || major == _selectedCategory;
                  final isNotSold = status != 'Đã bán';

                  return matchesSearch && matchesCategory && isNotSold;
                }).toList();

                // Nếu lọc xong mà không có cuốn nào
                if (filteredBooks.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy giáo trình phù hợp.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final doc = filteredBooks[index];
                    final bookData = doc.data() as Map<String, dynamic>;

                    bookData['id'] = doc.id;
                    bookData['tagBg'] = _getTagBgColor(bookData['status'] ?? '');
                    bookData['tagText'] = _getTagTextColor(bookData['status'] ?? '');

                    // Lấy link ảnh từ dữ liệu
                    final imageUrl = bookData['imageUrl'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookDetailScreen(bookData: bookData)),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 6. ẢNH BÌA SÁCH THỰC TẾ
                            Expanded(
                              flex: 5,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                ),
                                child: imageUrl.isNotEmpty
                                    ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.broken_image_rounded,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                )
                                    : Icon(
                                  Icons.menu_book,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),

                            // Thông tin sách
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      bookData['title'] ?? 'Tên sách',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: bookData['tagBg'],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        bookData['status'] ?? '',
                                        style: TextStyle(
                                          color: bookData['tagText'],
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${bookData['price']} đ',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}