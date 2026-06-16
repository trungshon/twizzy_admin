# Twizzy Admin Dashboard (Flutter Web)

Đây là trang quản trị (Admin Dashboard) của hệ thống mạng xã hội Twizzy, được xây dựng bằng **Flutter Web**.

---

## 🚀 Các chức năng quản trị
- **Quản lý người dùng**: Xem danh sách thành viên, trạng thái xác thực, kích hoạt hoặc khóa tài khoản (Ban/Unban).
- **Quản lý nội dung**: Giám sát các bài viết (Twizz), bình luận trên hệ thống.
- **Xử lý báo cáo (Report Management)**: Xem các báo cáo vi phạm nội dung từ người dùng và đưa ra quyết định xử lý.
- **Biểu đồ thống kê**: Xem biểu đồ tăng trưởng người dùng, bài đăng, tương tác thời gian thực bằng `fl_chart`.

---

## 🛠️ Yêu cầu môi trường
- **Flutter SDK**: Phiên bản >= 3.22.x
- **Google Chrome**: Dùng để chạy thử nghiệm và debug trên trình duyệt.

---

## ⚙️ Hướng dẫn Cài đặt & Cấu hình

### Bước 1: Cài đặt Dependencies
Chạy lệnh sau tại thư mục `twizzy_admin`:
```bash
flutter pub get
```

### Bước 2: Cấu hình địa chỉ API Server (Backend)
1. Mở file `lib/core/constants/app_constants.dart`.
2. Thay đổi giá trị của `baseUrl` thành URL chạy API server của bạn (mặc định là `http://localhost:3000`).
   ```dart
   static const String baseUrl = 'http://localhost:3000';
   ```

---

## 🚀 Khởi chạy & Build deploy lên Backend

### 1. Chạy độc lập dưới local (Development Mode)
Để chạy thử nghiệm trực tiếp bằng Chrome:
```bash
flutter run -d chrome
```

### 2. Build và tích hợp trực tiếp vào API Server (Khuyên dùng khi đóng gói)
Hệ thống đã viết sẵn tập lệnh build tự động để biên dịch mã nguồn Flutter Web và đưa vào thư mục tĩnh của Backend (`Twizzy-BE/admin`). Sau khi tích hợp, trang admin sẽ được chạy trực tiếp từ server Node.js.

- **Trên Windows (PowerShell)**:
  Chạy script build:
  ```powershell
  ./build-admin.ps1
  ```
- **Trên macOS / Linux (Bash)**:
  Cấp quyền thực thi và chạy:
  ```bash
  chmod +x build-admin.sh
  ./build-admin.sh
  ```

Sau khi chạy xong tập lệnh, trang Admin Dashboard sẽ sẵn sàng hoạt động tại địa chỉ:
👉 **`http://localhost:3000/admin-web/`** (Khi API Server Backend đang chạy).
