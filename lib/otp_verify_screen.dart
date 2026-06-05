// File: otp_verify_screen.dart
import 'package:flutter/material.dart';
import 'auth_controller.dart'; // Import bộ xử lý backend

class OtpVerifyScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerifyScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  final AuthController _authController = AuthController(); // Khởi tạo controller

  bool _isLoading = false; // Trạng thái đợi hệ thống xác thực mã OTP

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực OTP'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black, // Nút mũi tên quay lại màu đen
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Nhập mã xác thực',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
                  children: [
                    const TextSpan(text: 'Mã OTP gồm 6 số đã được gửi đến SĐT\n'),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Ô nhập mã OTP 6 số
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                enabled: !_isLoading, // Khóa ô nhập khi đang kiểm tra mã
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 16,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 16),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Nút Xác nhận kết nối Firebase thật
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null // Vô hiệu hóa nút khi đang loading
                      : () {
                    String otpCode = _otpController.text.trim();
                    if (otpCode.length == 6) {
                      // Gọi hàm verifyOTP từ Backend Controller
                      _authController.verifyOTP(
                        context: context,
                        smsCode: otpCode,
                        toggleLoading: (status) {
                          setState(() {
                            _isLoading = status;
                          });
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập đủ 6 số OTP'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                      : const Text('XÁC NHẬN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),

              // Nút Gửi lại mã
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Chưa nhận được mã? ', style: TextStyle(color: Colors.grey[600])),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      // Ở đây bạn có thể gọi lại hàm sendOTP nếu muốn làm chức năng gửi lại mã thật
                    },
                    child: Text(
                      'Gửi lại',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}