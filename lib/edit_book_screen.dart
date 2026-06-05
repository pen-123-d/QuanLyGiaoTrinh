import 'package:flutter/material.dart';
import 'book_controller.dart';

class EditBookScreen extends StatefulWidget {
  final Map<String, dynamic> bookData;
  const EditBookScreen({super.key, required this.bookData});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookController _bookController = BookController();

  late TextEditingController _titleController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  String? _selectedMajor;
  String? _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bookData['title']);
    _priceController = TextEditingController(text: widget.bookData['price'].toString());
    _descController = TextEditingController(text: widget.bookData['description']);
    _selectedMajor = widget.bookData['major'];
    _selectedStatus = widget.bookData['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa giáo trình')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Tên sách')),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Giá bán')),
              TextFormField(controller: _descController, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (_formKey.currentState!.validate()) {
                    _bookController.updateBook(
                      context: context,
                      bookId: widget.bookData['id'],
                      title: _titleController.text,
                      major: _selectedMajor!,
                      status: _selectedStatus!,
                      price: double.parse(_priceController.text),
                      description: _descController.text,
                      toggleLoading: (val) => setState(() => _isLoading = val),
                      onSuccess: () => Navigator.pop(context),
                    );
                  }
                },
                child: const Text('LƯU THAY ĐỔI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}