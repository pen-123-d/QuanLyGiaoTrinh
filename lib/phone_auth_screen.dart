// File: phone_auth_screen.dart
import 'package:flutter/material.dart';
import 'otp_verify_screen.dart';
import 'auth_controller.dart'; // Import bộ xử lý backend

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController(); // Khởi tạo controller

  bool _isLoading = false; // Trạng thái đợi hệ thống gửi OTP

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phonelink_ring_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Đăng nhập / Đăng ký',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vui lòng nhập số điện thoại của bạn.\nChúng tôi sẽ gửi một mã OTP để xác thực.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading, // Khóa ô nhập khi đang loading
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixText: '+84  ',
                      prefixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      prefixIcon: const Icon(Icons.phone_android_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 9) {
                        return 'Vui lòng nhập số điện thoại hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null // Vô hiệu hóa nút khi đang loading
                          : () {
                        if (_formKey.currentState!.validate()) {
                          // Tiến hành cắt bớt số 0 ở đầu nếu người dùng quen tay nhập dạng 0907...
                          String phone = _phoneController.text.trim();
                          if (phone.startsWith('0')) {
                            phone = phone.substring(1);
                          }
                          final fullPhoneNumber = '+84$phone';

                          // Gọi Hàm gửi OTP thật lên Firebase Backend
                          _authController.sendOTP(
                            context: context,
                            phoneNumber: fullPhoneNumber,
                            toggleLoading: (status) {
                              setState(() {
                                _isLoading = status;
                              });
                            },
                            onCodeSent: () {
                              // Chuyển sang màn hình xác thực khi Firebase báo đã gửi thành công
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtpVerifyScreen(
                                    phoneNumber: fullPhoneNumber,
                                  ),
                                ),
                              );
                            },
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
                          : const Text('NHẬN MÃ OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}