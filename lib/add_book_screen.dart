// File: add_book_screen.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'book_controller.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookController _bookController = BookController();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedMajor;
  String? _selectedStatus;
  bool _isLoading = false;

  // HAI BIẾN NÀY LƯU ẢNH VÀ LINK ẢNH
  File? _imageFile;
  String _imageUrl = '';

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
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

  // HÀM MỞ CAMERA/THƯ VIỆN & ĐẨY ẢNH LÊN CLOUDINARY
  Future<void> _pickAndUploadImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Nút 1: MỞ CAMERA CHỤP ẢNH
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Colors.blue),
                title: const Text('Chụp ảnh trực tiếp'),
                onTap: () {
                  Navigator.pop(context); // Đóng menu
                  _processImage(ImageSource.camera); // Gọi hàm xử lý ảnh với Camera
                },
              ),
              const Divider(height: 1),
              // Nút 2: MỞ THƯ VIỆN ẢNH
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.green),
                title: const Text('Chọn ảnh từ thư viện'),
                onTap: () {
                  Navigator.pop(context); // Đóng menu
                  _processImage(ImageSource.gallery); // Gọi hàm xử lý ảnh với Thư viện
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // HÀM XỬ LÝ LẤY ẢNH VÀ ĐẨY LÊN CLOUDINARY
  Future<void> _processImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80, // Giảm chất lượng ảnh một xíu để up lên Cloudinary cho nhanh
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isLoading = true; // Bật xoay lúc đang tải ảnh
      });

      try {
        final url = Uri.parse('https://api.cloudinary.com/v1_1/dwv2tosaa/image/upload');
        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'flutter_upload'
          ..files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

        final response = await request.send();
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);

        if (response.statusCode == 200) {
          setState(() {
            _imageUrl = jsonMap['secure_url']; // Đã lấy được link ảnh trên mây!
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tải ảnh lên thành công!'), backgroundColor: Colors.green),
            );
          }
        } else {
          throw Exception('Lỗi Server Cloudinary');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi tải ảnh lên. Vui lòng thử lại!'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng bán giáo trình')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KHU VỰC TẢI ẢNH BÌA
              GestureDetector(
                onTap: _isLoading ? null : _pickAndUploadImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                    // Hiển thị ảnh vừa chọn
                    image: _imageFile != null
                        ? DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                      // Đè màu đen mờ nếu đang xoay tải ảnh
                      colorFilter: _isLoading && _imageUrl.isEmpty
                          ? ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken)
                          : null,
                    )
                        : null,
                  ),
                  child: _isLoading && _imageUrl.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : (_imageFile == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Nhấn để chọn ảnh bìa sách',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  )
                      : const SizedBox.shrink()),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Thông tin cơ bản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Tên sách
              TextFormField(
                controller: _titleController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Tên sách *',
                  prefixIcon: const Icon(Icons.menu_book_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: _buildInputBorder(context),
                  enabledBorder: _buildInputBorder(context),
                  focusedBorder: _buildInputBorder(context, isFocused: true),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên sách' : null,
              ),
              const SizedBox(height: 16),

              // Chuyên ngành
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Chuyên ngành *',
                  prefixIcon: const Icon(Icons.school_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: _buildInputBorder(context),
                  enabledBorder: _buildInputBorder(context),
                  focusedBorder: _buildInputBorder(context, isFocused: true),
                ),
                value: _selectedMajor,
                items: ['Công nghệ thông tin', 'Kinh tế', 'Ngoại ngữ', 'Cơ điện tử', 'Đại cương']
                    .map((major) => DropdownMenuItem(value: major, child: Text(major)))
                    .toList(),
                onChanged: _isLoading ? null : (value) => setState(() => _selectedMajor = value),
                validator: (value) => value == null ? 'Vui lòng chọn chuyên ngành' : null,
              ),
              const SizedBox(height: 16),

              // Tình trạng
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tình trạng *',
                  prefixIcon: const Icon(Icons.info_outline_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: _buildInputBorder(context),
                  enabledBorder: _buildInputBorder(context),
                  focusedBorder: _buildInputBorder(context, isFocused: true),
                ),
                value: _selectedStatus,
                items: ['Mới 100%', 'Mới > 90%', 'Cũ (Có ghi chú)', 'Sách photo']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: _isLoading ? null : (value) => setState(() => _selectedStatus = value),
                validator: (value) => value == null ? 'Vui lòng chọn tình trạng sách' : null,
              ),
              const SizedBox(height: 16),

              // Giá bán
              TextFormField(
                controller: _priceController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá bán (VNĐ) *',
                  prefixIcon: const Icon(Icons.payments_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: _buildInputBorder(context),
                  enabledBorder: _buildInputBorder(context),
                  focusedBorder: _buildInputBorder(context, isFocused: true),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập giá bán';
                  if (double.tryParse(value) == null) return 'Giá bán phải là số hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mô tả chi tiết
              TextFormField(
                controller: _descController,
                enabled: !_isLoading,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Mô tả chi tiết',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: _buildInputBorder(context),
                  enabledBorder: _buildInputBorder(context),
                  focusedBorder: _buildInputBorder(context, isFocused: true),
                ),
              ),
              const SizedBox(height: 32),

              // 3. NÚT ĐĂNG BÁN KẾT NỐI FIREBASE
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    // Ràng buộc bắt buộc phải up ảnh
                    if (_imageUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng chọn ảnh bìa sách!'), backgroundColor: Colors.red),
                      );
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      _bookController.addBook(
                        context: context,
                        title: _titleController.text.trim(),
                        major: _selectedMajor!,
                        status: _selectedStatus!,
                        price: double.parse(_priceController.text.trim()),
                        description: _descController.text.trim(),
                        imageUrl: _imageUrl, // TRUYỀN LINK ẢNH VÀO ĐÂY
                        toggleLoading: (status) {
                          setState(() {
                            _isLoading = status;
                          });
                        },
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đăng bán thành công!'), backgroundColor: Colors.green),
                          );
                          // Xóa trắng form
                          _titleController.clear();
                          _priceController.clear();
                          _descController.clear();
                          setState(() {
                            _selectedMajor = null;
                            _selectedStatus = null;
                            _imageFile = null;
                            _imageUrl = '';
                          });
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading && _imageUrl.isNotEmpty
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('ĐĂNG BÁN GIÁO TRÌNH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}