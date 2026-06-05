// File: book_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'book_model.dart'; // Import cái khuôn đúc dữ liệu ở bước 1

class BookController {
  // Gọi 2 dịch vụ của Firebase: Database (Lưu dữ liệu) và Auth (Lấy ID người dùng)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // HÀM ĐĂNG BÁN SÁCH
  Future<void> addBook({
    required BuildContext context,
    required String title,
    required String major,
    required String status,
    required double price,
    required String description,
    required String imageUrl,
    required Function(bool) toggleLoading, // Bật/tắt hiệu ứng xoay xoay
    required VoidCallback onSuccess,       // Hàm chạy khi thành công
  }) async {
    toggleLoading(true); // Bật loading

    try {
      // 1. Lấy ID của người đang đăng nhập
      // (Phải biết ai là người bán để mốt còn hiện trong tab "Đã đăng")
      String? userId = _auth.currentUser?.uid;

      if (userId == null) {
        throw Exception("Không tìm thấy thông tin tài khoản. Vui lòng đăng nhập lại!");
      }

      // 2. Đổ dữ liệu bạn nhập vào khuôn BookModel
      BookModel newBook = BookModel(
        title: title,
        major: major,
        status: status,
        price: price,
        description: description,
        imageUrl: imageUrl,
        sellerId: userId,
        createdAt: DateTime.now(), // Tự động lấy giờ hiện tại
      );

      // 3. Đẩy lên Cloud Firestore
      // Lệnh này sẽ tạo một thư mục (collection) tên là 'books' trên Firebase
      // và quăng cục dữ liệu JSON vào đó.
      await _firestore.collection('books').add(newBook.toMap());

      toggleLoading(false); // Tắt loading
      onSuccess();          // Kích hoạt báo thành công trên UI

    } catch (e) {
      toggleLoading(false);
      // Báo lỗi nếu rớt mạng hoặc Firebase có vấn đề
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng bán: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // HÀM SỬA THÔNG TIN SÁCH
  Future<void> updateBook({
    required BuildContext context,
    required String bookId, // Cần ID để biết sửa cuốn nào
    required String title,
    required String major,
    required String status,
    required double price,
    required String description,
    required Function(bool) toggleLoading,
    required VoidCallback onSuccess,
  }) async {
    toggleLoading(true);
    try {
      await _firestore.collection('books').doc(bookId).update({
        'title': title,
        'major': major,
        'status': status,
        'price': price,
        'description': description,
      });
      toggleLoading(false);
      onSuccess();
    } catch (e) {
      toggleLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi sửa bài: $e'), backgroundColor: Colors.red),
      );
    }
  }
}