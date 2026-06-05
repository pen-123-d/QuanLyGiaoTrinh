// File: book_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String? id;          // ID tự động của Firestore (Dùng để sửa/xóa sách sau này)
  final String title;        // Tên sách
  final String major;        // Chuyên ngành
  final String status;       // Tình trạng sách
  final double price;        // Giá bán
  final String description;  // Mô tả chi tiết
  final String imageUrl;     // Link ảnh (Tạm thời để trống, mốt học up ảnh lên Storage sau)
  final String sellerId;     // ID của người dùng đăng bán (Để biết sách này của ai)
  final DateTime createdAt;  // Thời gian đăng bán (Để sắp xếp sách mới nhất lên đầu)

  BookModel({
    this.id,
    required this.title,
    required this.major,
    required this.status,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.sellerId,
    required this.createdAt,
  });

  // 1. HÀM ĐÓNG GÓI: Chuyển dữ liệu từ App thành định dạng Map (JSON) để đẩy lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'major': major,
      'status': status,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'createdAt': Timestamp.fromDate(createdAt), // Firestore xài kiểu Timestamp riêng
    };
  }

  // 2. HÀM MỞ HỘP: Đọc dữ liệu từ Firebase tải về và ép ngược lại thành BookModel cho App xài
  factory BookModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookModel(
      id: documentId,
      title: map['title'] ?? 'Chưa có tên',
      major: map['major'] ?? 'Chưa phân loại',
      status: map['status'] ?? 'Không rõ',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      sellerId: map['sellerId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}