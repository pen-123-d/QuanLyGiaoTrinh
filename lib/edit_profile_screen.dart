// File: edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'profile_controller.dart';
import 'user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel currentUser; // Nhận dữ liệu người dùng từ trang trước truyền sang

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController _profileController = ProfileController();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo ô nhập với dữ liệu có sẵn
    _nameController = TextEditingController(text: widget.currentUser.fullName);
    _addressController = TextEditingController(text: widget.currentUser.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  OutlineInputBorder _buildInputBorder(BuildContext context, {bool isFocused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isFocused ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
        width: isFocused ? 2 : 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KHU VỰC THAY ĐỔI AVATAR (Giao diện giữ nguyên, xử lý sau)
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      backgroundImage: widget.currentUser.avatarUrl.isNotEmpty
                          ? NetworkImage(widget.currentUser.avatarUrl)
                          : null,
                      child: widget.currentUser.avatarUrl.isEmpty
                          ? Icon(Icons.person_rounded, size: 50, color: Theme.of(context).colorScheme.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tính năng up ảnh đại diện đang phát triển!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. CÁC Ô NHẬP LIỆU
              const Text('Thông tin liên hệ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: _buildInputBorder(context),
                  enabledBorder: _buildInputBorder(context),
                  focusedBorder: _buildInputBorder(context, isFocused: true),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Không được để trống tên' : null,
              ),
              const SizedBox(height: 16),

              // Ô nhập SĐT khóa lại vì dùng SĐT để đăng nhập, không được đổi
              TextFormField(
                initialValue: widget.currentUser.phoneNumber,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại (Không thể đổi)',
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: _buildInputBorder(context),
                  disabledBorder: _buildInputBorder(context),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ nhận sách mặc định',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: _buildInputBorder(context),
                  enabledBorder: _buildInputBorder(context),
                  focusedBorder: _buildInputBorder(context, isFocused: true),
                ),
              ),
              const SizedBox(height: 32),

              // 3. NÚT LƯU THAY ĐỔI LÊN FIREBASE
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      try {
                        await _profileController.updateProfile(
                          fullName: _nameController.text.trim(),
                          address: _addressController.text.trim(),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
                          );
                          Navigator.pop(context); // Trở về trang trước
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                          );
                        }
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('LƯU THAY ĐỔI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}