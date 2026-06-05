// File: user_activity_screen.dart
import 'package:flutter/material.dart';

class UserActivityScreen extends StatelessWidget {
  final int initialTab;
  const UserActivityScreen({super.key, required this.initialTab});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTab,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hoạt động của tôi'),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'Đã đăng', icon: Icon(Icons.upload_file_rounded)),
              Tab(text: 'Đã mua', icon: Icon(Icons.shopping_bag_rounded)),
              Tab(text: 'Đã bán', icon: Icon(Icons.monetization_on_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Đã đăng
            BookListPlaceholder(
              icon: Icons.inventory_2_rounded,
              title: 'Bạn chưa đăng cuốn sách nào',
              subtitle: 'Hãy dọn dẹp giá sách và chia sẻ những cuốn giáo trình bạn không còn dùng đến nhé!',
              actionText: 'Đăng bán ngay',
              onActionPressed: () {
                // Thoát trang Lịch sử để về lại Trang chủ (người dùng tự bấm sang tab Đăng bán ở Navigation)
                Navigator.pop(context);
              },
            ),

            // Tab 2: Đã mua
            BookListPlaceholder(
              icon: Icons.shopping_basket_rounded,
              title: 'Lịch sử mua hàng trống',
              subtitle: 'Bạn chưa chốt đơn cuốn giáo trình nào. Rất nhiều sách rẻ đang chờ bạn!',
              actionText: 'Khám phá ngay',
              onActionPressed: () {
                Navigator.pop(context);
              },
            ),

            // Tab 3: Đã bán
            const BookListPlaceholder(
              icon: Icons.storefront_rounded,
              title: 'Chưa có đơn hàng thành công',
              subtitle: 'Các cuốn giáo trình bạn bán thành công sẽ được thống kê tại đây.',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget thiết kế riêng cho Trạng thái trống (Empty State)
class BookListPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const BookListPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon được bọc trong vòng tròn màu mờ trang trí
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 70,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Nút bấm Kêu gọi hành động (Chỉ hiện nếu có truyền actionText vào)
          if (actionText != null && onActionPressed != null)
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary, // Nút màu Cam nổi bật
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // Bo tròn dạng viên thuốc
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}