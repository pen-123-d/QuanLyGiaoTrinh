// File: profile_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_model.dart';

class ProfileController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. HÀM LẤY THÔNG TIN NGƯỜI DÙNG HIỆN TẠI
  Future<UserModel?> getUserProfile() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    // Chui vào kho 'users' tìm cái file có tên là ID của mình
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      // Có dữ liệu rồi thì lấy ra xài
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } else {
      // Nếu tìm không thấy (Tức là mới đăng nhập lần đầu) -> Tạo hồ sơ mới tự động
      UserModel newUser = UserModel(
        uid: uid,
        phoneNumber: _auth.currentUser?.phoneNumber ?? '',
        fullName: 'Người dùng mới',
        address: 'Chưa cập nhật địa chỉ',
        avatarUrl: '', // Mốt thích thì mình gắn Cloudinary vào cho user đổi Avatar luôn
      );

      // Lưu cái hồ sơ mới tạo này lên Firebase
      await _firestore.collection('users').doc(uid).set(newUser.toMap());
      return newUser;
    }
  }

  Future<Map<String, dynamic>?> getUserById(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // 2. HÀM LƯU THAY ĐỔI THÔNG TIN CÁ NHÂN
  Future<void> updateProfile({
    required String fullName,
    required String address,
    String? avatarUrl, // Optional: Có ảnh mới thì truyền, không thì thôi
  }) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Chưa đăng nhập!");

    // Cập nhật lại các trường dữ liệu trên mây
    Map<String, dynamic> updateData = {
      'fullName': fullName,
      'address': address,
    };

    // Nếu có truyền link ảnh mới vào thì cập nhật luôn
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      updateData['avatarUrl'] = avatarUrl;
    }

    await _firestore.collection('users').doc(uid).update(updateData);
  }
}