# 📚 ĐỒ ÁN: ỨNG DỤNG MUA BÁN GIÁO TRÌNH SINH VIÊN (C2C)

> **Mô tả:** Ứng dụng di động hỗ trợ sinh viên trao đổi, mua bán giáo trình cũ theo mô hình C2C (Customer to Customer). Dự án tập trung vào trải nghiệm người dùng tối giản, tốc độ nhanh và tính năng liên hệ trực tiếp hiệu quả.

---

## 🌟 1. Tính Năng Nổi Bật

### 🔐 Xác Thực & Người Dùng
*   **Đăng nhập/Đăng ký:** Xác thực an toàn bằng mã OTP gửi qua Số điện thoại (Firebase Phone Auth).
*   **Quản lý hồ sơ:** Hiển thị thông tin cá nhân và lịch sử đăng bán.

### 📦 Quản Lý Sản Phẩm (Giáo Trình)
*   **Đăng bán thông minh:** Chụp ảnh trực tiếp từ Camera thật, điền thông tin chi tiết (Giá, Chuyên ngành, Tình trạng).
*   **Tìm kiếm & Lọc:** Tìm kiếm theo tên sách và lọc theo chuyên ngành (Đại cương, Công nghệ thông tin, Kinh tế...).
*   **Quản lý trạng thái:** Chủ sách có thể đánh dấu **"Đã bán"**. Hệ thống sẽ tự động làm mờ sản phẩm, gạch ngang tên và ẩn khỏi Trang chủ để tránh bị làm phiền.

### 🤝 Giao Dịch & Liên Hệ Trực Tiếp
*   **Nút [Gọi ngay]:** Tự động mở bàn phím điện thoại và điền sẵn số người bán.
*   **Nút [Chat Zalo]:** Chuyển hướng trực tiếp vào ứng dụng Zalo để bắt đầu cuộc trò chuyện.

---

## 🛠 2. Công Nghệ Sử Dụng
*   **Framework:** Flutter / Dart
*   **Backend & Database:** Firebase (Authentication, Cloud Firestore, Cloud Storage)
*   **Thư viện nổi bật:** `url_launcher` (Điều hướng cuộc gọi/Zalo), `image_picker` (Xử lý Camera/Thư viện ảnh).

---

## 🚀 3. Trải Nghiệm Nhanh (Dành cho Giảng viên chấm điểm)

Để tiết kiệm thời gian và bỏ qua các bước cài đặt môi trường rườm rà, vui lòng tải file ứng dụng (APK) và cài đặt trực tiếp trên điện thoại Android:

👉 **[https://drive.google.com/drive/folders/1bpAOeZqFiKR5Sg0k6b-HsE1hZuEERdZL?usp=drive_link]

**Tài khoản Test được cấp quyền:**
Do giới hạn bảo mật của Google về việc gửi SMS, vui lòng sử dụng các tài khoản test sau để đăng nhập:
*   **Số điện thoại:** `+84901234567` *(hoặc thay bằng số sếp đã cài)*
*   **Mã OTP:** `123456`

---

## 💻 4. Hướng Dẫn Chạy Mã Nguồn (Dành cho Developer)

**Yêu cầu hệ thống:**
*   Flutter SDK (v3.x trở lên).
*   Thiết bị Android thật (để test tính năng Gọi điện, Zalo và Camera). Máy ảo (Emulator) sẽ không hỗ trợ đầy đủ các tính năng này.

**Các bước cài đặt:**
1.  Clone repository này về máy tính:
```bash
    git clone [https://github.com/](https://github.com/)[TEN-GITHUB-CUA-SEP]/quan_ly_giao_trinh.git
    ```
2.  Cài đặt các thư viện phụ thuộc:
```bash
    flutter clean
    flutter pub get
    ```
3.  Kết nối điện thoại qua cáp USB và chạy ứng dụng:
```bash
    flutter run
    ```

> **⚠️ Lưu ý về Firebase:** File `google-services.json` đã được tích hợp sẵn để kết nối Database. Tuy nhiên, nếu bạn tự biên dịch lại code (build/run) trên máy tính cá nhân, tính năng gửi mã OTP thực tế sẽ bị Firebase từ chối do thiếu mã SHA-1 của máy tính bạn. Vui lòng sử dụng tính năng **Trải nghiệm nhanh (Mục 3)** để đánh giá trọn vẹn dự án.