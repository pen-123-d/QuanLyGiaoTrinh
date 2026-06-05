import 'package:flutter/material.dart';
import 'main_navigation.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'phone_auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Giáo Trình Cũ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Bật ngôn ngữ thiết kế Material 3 mới nhất của Google
        useMaterial3: true,

        // Phối lại hệ màu: Xanh Indigo kết hợp Cam nổi bật
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFEA580C),
        ),

        // Nền app xám nhạt để làm nổi bật các thẻ Card màu trắng
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),

        // Đồng bộ AppBar toàn ứng dụng
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      //home: const MainNavigation(),
      home: const PhoneAuthScreen(),
    );
  }
}