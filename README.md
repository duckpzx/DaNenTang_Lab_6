# User Management System

> **MSSV:** 2224802010615 — **Họ và tên:** Phạm Xuân Đức

---

## 🎬 Demo Video

[▶️ Xem video demo tại đây](https://private-user-images.githubusercontent.com/126335789/592316130-214ad1e2-48e4-47e9-8082-bb3ec9e59425.mp4?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3Nzg3NDA4MTAsIm5iZiI6MTc3ODc0MDUxMCwicGF0aCI6Ii8xMjYzMzU3ODkvNTkyMzE2MTMwLTIxNGFkMWUyLTQ4ZTQtNDdlOS04MDgyLWJiM2VjOWU1OTQyNS5tcDQ_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjYwNTE0JTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI2MDUxNFQwNjM1MTBaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT01NDVlOTBkMGMxYTRiOGIzNTZmMWExMzE5OWUyOWZlYzYxMmFhNjQ0MWMxZjk3YzkxMzk1OGFiZTFhMzM4OTM0JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCZyZXNwb25zZS1jb250ZW50LXR5cGU9dmlkZW8lMkZtcDQ)

---

## 📋 Mô tả dự án

Hệ thống quản lý người dùng full-stack gồm **ASP.NET Core Web API** làm backend, **SQL Server** làm cơ sở dữ liệu và **Flutter** làm giao diện người dùng đa nền tảng.

Giao diện được thiết kế theo phong cách **Apple iOS Dark Mode** — tối giản, cao cấp, tinh tế.

---

## 🏗️ Kiến trúc hệ thống

```
┌─────────────────────┐        HTTP/JWT        ┌──────────────────────┐
│   Flutter App       │ ◄────────────────────► │  ASP.NET Core API    │
│   (Web / Desktop)   │                        │  (.NET 9 / Port 5156)│
└─────────────────────┘                        └──────────┬───────────┘
                                                          │ EF Core
                                                          ▼
                                               ┌──────────────────────┐
                                               │  SQL Server Express  │
                                               │  (UserManagementDb)  │
                                               └──────────────────────┘
```

---

## 🛠️ Công nghệ sử dụng

| Tầng | Công nghệ |
|------|-----------|
| **Frontend** | Flutter 3.x (Web + Desktop) |
| **Backend** | ASP.NET Core 9 Web API |
| **Database** | SQL Server Express (EF Core 9) |
| **Auth** | JWT Bearer Token |
| **Password** | BCrypt hashing |
| **API Docs** | Swagger / OpenAPI |
| **State** | Provider pattern |

---

## ✨ Tính năng

### 🔐 Xác thực
- Đăng nhập / Đăng ký tài khoản
- JWT token lưu vào SharedPreferences
- Tự động kiểm tra phiên đăng nhập khi mở app
- Phân quyền **Admin** / **User**

### 👤 Người dùng thường
- Xem thông tin hồ sơ cá nhân
- Xem role, ngày tạo tài khoản
- Đăng xuất

### 🛡️ Admin
- Xem danh sách toàn bộ người dùng
- Thống kê: tổng số, số Admin, số User
- Thêm người dùng mới
- Chỉnh sửa thông tin người dùng
- Xóa người dùng

---

## 🚀 Hướng dẫn chạy dự án

### 1. Backend — ASP.NET Core API

```bash
cd phamxuanduc
dotnet run
# API chạy tại: http://localhost:5156
# Swagger UI:   http://localhost:5156/swagger
```

> Tự động migrate database và tạo tài khoản admin mặc định khi khởi động.

### 2. Frontend — Flutter App

```bash
cd flutter_app
flutter run -d chrome --web-port 3000
# App chạy tại: http://localhost:3000
```

---

## 🔑 Tài khoản mặc định

| Username | Password | Role |
|----------|----------|------|
| `admin` | `Admin@123` | Admin |

---

## 📁 Cấu trúc thư mục

```
phamxuanduc/
├── phamxuanduc/              # ASP.NET Core Backend
│   ├── Controllers/
│   │   ├── AuthController.cs
│   │   └── UsersController.cs
│   ├── Models/User.cs
│   ├── DTOs/AuthDTOs.cs
│   ├── Data/AppDbContext.cs
│   ├── Migrations/
│   └── appsettings.json
│
└── flutter_app/              # Flutter Frontend
    └── lib/
        ├── main.dart
        ├── theme/app_theme.dart
        ├── widgets/ios_widgets.dart
        ├── screens/
        │   ├── login_screen.dart
        │   ├── register_screen.dart
        │   ├── admin_dashboard_screen.dart
        │   ├── user_profile_screen.dart
        │   └── user_form_screen.dart
        ├── providers/auth_provider.dart
        ├── services/
        │   ├── auth_service.dart
        │   └── user_service.dart
        └── models/user_model.dart
```

---

## 🎨 Thiết kế UI

Giao diện được xây dựng theo phong cách **Apple iOS Dark Mode**:

- **Màu nền:** `#000000` / `#0F0F10`
- **Card:** `#1C1C1E` với border mờ `0.5px`
- **Accent:** iOS Blue `#0A84FF`
- **Typography:** Inter — giống SF Pro Display
- **Animation:** Fade in + slide mượt mà
- **Bo góc:** 14px – 20px

---

*Đồ án môn Đa Nền Tảng — 2224802010615 Phạm Xuân Đức*
