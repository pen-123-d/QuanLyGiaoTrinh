// File: auth_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_navigation.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Biến lưu trữ ID lượt gửi OTP (Firebase dùng để khớp với mã 6 số người dùng nhập)
  static String _verificationId = "";

  // 1. HÀM GỬI MÃ OTP VỀ SỐ ĐIỆN THOẠI
  Future<void> sendOTP({
    required BuildContext context,
    required String phoneNumber,
    required Function(bool) toggleLoading,
    required VoidCallback onCodeSent,
  }) async {
    print("Đã bao send otp");
    toggleLoading(true); // Bật vòng xoay loading trên UI

    try {
      print("Đang chạy lệnh tắt recap");
       _auth.setSettings(appVerificationDisabledForTesting: true);
      print(' Đang xử lý: $phoneNumber');
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60), // Thêm thời gian chờ rõ ràng

        // Trường hợp 1: Tự động xác thực nếu Firebase đọc được SMS
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            toggleLoading(false); // Thành công thì tắt xoay
            _goToHomeScreen(context);
          } catch (e) {
            toggleLoading(false); // Lỗi đăng nhập tự động cũng phải tắt xoay
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi tự động đăng nhập: ${e.toString()}'), backgroundColor: Colors.red),
            );
          }
        },

        // Trường hợp 2: Lỗi từ hệ thống gửi SMS (VD: Sai định dạng SĐT)
        verificationFailed: (FirebaseAuthException e) {
          toggleLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi từ Firebase: ${e.message}'), backgroundColor: Colors.red),
          );
        },

        // Trường hợp 3: Khi Firebase đã gửi SMS thành công
        codeSent: (String verId, int? resendToken) {
          _verificationId = verId;
          toggleLoading(false);
          onCodeSent(); // Kích hoạt chuyển sang trang nhập mã 6 số
        },

        // Trường hợp 4: Hết thời gian chờ OTP (Timeout)
        codeAutoRetrievalTimeout: (String verId) {
          _verificationId = verId;
          toggleLoading(false); // BẮT BUỘC PHẢI TẮT XOAY Ở ĐÂY
        },
      );
    } catch (e) {
      // Bắt các lỗi vặt hệ thống khác
      toggleLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi hệ thống: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // 2. HÀM XÁC THỰC MÃ OTP 6 SỐ NGƯỜI DÙNG NHẬP
  Future<void> verifyOTP({
    required BuildContext context,
    required String smsCode,
    required Function(bool) toggleLoading,
  }) async {
    toggleLoading(true);

    try {
      // Gói mã OTP và ID lượt gửi thành một chứng chỉ xác thực
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      // Tiến hành đăng nhập vào Firebase bằng chứng chỉ trên
      await _auth.signInWithCredential(credential);

      toggleLoading(false);
      _goToHomeScreen(context);

    } on FirebaseAuthException catch (e) {
      toggleLoading(false);

      // Phân loại lỗi rõ ràng cho người dùng dễ hiểu
      String errorMessage = 'Mã OTP không chính xác hoặc đã hết hạn!';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Mã OTP bạn nhập không đúng. Vui lòng thử lại!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      toggleLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi không xác định: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm tiện ích chuyển hướng vào thẳng trang chủ và xóa lịch sử trang trước
  void _goToHomeScreen(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
    );
  }
}