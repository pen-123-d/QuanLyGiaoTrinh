// File: user_model.dart
class UserModel {
  final String uid;          // ID tài khoản (Lấy từ hệ thống Auth)
  final String phoneNumber;  // Số điện thoại đăng nhập
  final String fullName;     // Họ và tên
  final String address;      // Địa chỉ giao dịch
  final String avatarUrl;    // Link ảnh đại diện

  UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.fullName,
    required this.address,
    required this.avatarUrl,
  });

  // HÀM ĐÓNG GÓI (Để đẩy lên Firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'address': address,
      'avatarUrl': avatarUrl,
    };
  }

  // HÀM MỞ HỘP (Tải từ Firebase về nhét vào App)
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      phoneNumber: map['phoneNumber'] ?? '',
      fullName: map['fullName'] ?? 'Người dùng ẩn danh',
      address: map['address'] ?? 'Chưa cập nhật địa chỉ',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }
}