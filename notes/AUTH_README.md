# Studify Frontend - Authentication Setup

Aplikasi Flutter untuk Studify dengan fitur autentikasi lengkap (Login, Register, Logout).

## ✅ Fitur yang Sudah Diimplementasikan

### 1. **Authentication System**
- ✅ Login dengan email & password
- ✅ Register dengan nama, email, password, dan konfirmasi password
- ✅ Logout dengan konfirmasi dialog
- ✅ JWT Token management (auto-save & load)
- ✅ Auto-login jika token masih valid
- ✅ Protected routes dengan Auth Guard

### 2. **State Management**
- ✅ Provider untuk global state management
- ✅ AuthProvider dengan status: initial, authenticated, unauthenticated, loading
- ✅ User data persistence menggunakan SharedPreferences

### 3. **API Integration**
- ✅ HTTP client setup
- ✅ RESTful API service untuk backend Laravel
- ✅ Error handling (ValidationException, UnauthorizedException, NetworkException)
- ✅ Token auto-refresh capability

### 4. **UI/UX**
- ✅ Material Design 3
- ✅ Responsive forms dengan validasi
- ✅ Loading indicators
- ✅ Error messages dengan SnackBar
- ✅ Password visibility toggle

## 📂 Struktur Project

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart          # API endpoints & headers
│   └── errors/
│       └── api_exception.dart          # Custom exceptions
├── data/
│   ├── models/
│   │   ├── user_model.dart             # User model
│   │   ├── user_model.g.dart           # Generated JSON serialization
│   │   ├── auth_response.dart          # Auth response model
│   │   └── auth_response.g.dart        # Generated JSON serialization
│   └── services/
│       └── auth_service.dart           # API calls (login, register, logout)
├── providers/
│   └── auth_provider.dart              # Auth state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart           # Login UI
│   │   └── register_screen.dart        # Register UI
│   └── home/
│       └── home_screen.dart            # Home screen dengan logout
└── main.dart                           # App entry point & routing
```

## 🚀 Setup & Konfigurasi

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Model Files

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Konfigurasi Backend URL

Edit file `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  // Ganti dengan URL backend Vercel Anda
  static const String baseUrl = 'https://studify-backend.vercel.app/api';
  
  // ... rest of code
}
```

**Cara mendapatkan URL Vercel:**
1. Buka dashboard Vercel: https://vercel.com/dashboard
2. Pilih project backend Laravel Anda
3. Copy URL deployment (contoh: `https://studify-backend.vercel.app`)
4. Tambahkan `/api` di akhir URL

### 4. Run Application

```bash
flutter run
```

## 🔑 API Endpoints yang Digunakan

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/users` | Register user baru |
| POST | `/api/auth/login` | Login user |
| DELETE | `/api/auth/login` | Logout user |
| POST | `/api/auth/refresh` | Refresh JWT token |
| GET | `/api/auth/user` | Get user data |

## 📱 Flow Aplikasi

### 1. **App Start**
```
App Launch
    ↓
Check Auth Status (dari SharedPreferences)
    ↓
├─ Token ada & valid → Navigate to Home
└─ Token tidak ada → Navigate to Login
```

### 2. **Register Flow**
```
Register Screen
    ↓
Fill Form (nama, email, password, confirm)
    ↓
Validate Input
    ↓
POST /api/users
    ↓
├─ Success → Save token → Navigate to Home
└─ Error → Show error message
```

### 3. **Login Flow**
```
Login Screen
    ↓
Fill Form (email, password)
    ↓
Validate Input
    ↓
POST /api/auth/login
    ↓
├─ Success → Save token → Navigate to Home
└─ Error → Show error message
```

### 4. **Logout Flow**
```
Home Screen → Press Logout
    ↓
Confirmation Dialog
    ↓
DELETE /api/auth/login
    ↓
Clear token & user data
    ↓
Navigate to Login
```

## 🛠️ Dependencies

```yaml
dependencies:
  # HTTP Client
  http: ^1.2.2
  
  # State Management
  provider: ^6.1.2
  
  # Local Storage
  shared_preferences: ^2.3.3
  
  # JSON Serialization
  json_annotation: ^4.9.0

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.13
  json_serializable: ^6.8.0
```

## 🔐 Security Features

- ✅ Password hashing di backend (bcrypt)
- ✅ JWT token authentication
- ✅ Token auto-refresh
- ✅ Secure token storage (SharedPreferences)
- ✅ Input validation (email format, password length)
- ✅ HTTPS only connections

## 🧪 Testing

Untuk testing manual:

1. **Test Register:**
   - Buka app → Klik "Daftar"
   - Isi form dengan data valid
   - Pastikan redirect ke Home setelah sukses

2. **Test Login:**
   - Logout jika sudah login
   - Isi email & password yang sudah terdaftar
   - Pastikan redirect ke Home setelah sukses

3. **Test Auto-Login:**
   - Login sekali
   - Close app (kill process)
   - Buka app lagi
   - Pastikan langsung masuk ke Home (tidak perlu login lagi)

4. **Test Logout:**
   - Di Home screen, klik icon logout
   - Konfirmasi logout
   - Pastikan redirect ke Login screen

## 📝 Catatan Penting

1. **URL Backend**: Pastikan URL backend sudah benar dan backend sudah deployed di Vercel
2. **CORS**: Pastikan backend Laravel sudah konfigurasi CORS untuk menerima request dari Flutter
3. **Internet Permission**: 
   - Android: Sudah auto-enabled
   - iOS: Perlu tambahkan di `Info.plist` jika menggunakan HTTP (production harus HTTPS)

## 🐛 Troubleshooting

### Error: "Network error occurred"
- Cek koneksi internet
- Pastikan URL backend benar
- Cek apakah backend sudah running/deployed

### Error: "Validation failed"
- Cek format input (email harus valid, password min 6 karakter)
- Pastikan password dan confirm password sama

### Error: "Unauthorized"
- Token expired atau tidak valid
- Logout dan login ulang

### Error: "Unable to load asset"
- Jalankan `flutter clean` lalu `flutter pub get`

## 🚧 Next Steps (Fitur yang Akan Ditambahkan)

- [ ] Forgot Password
- [ ] Email Verification
- [ ] Profile Management
- [ ] Classroom Management (F-02)
- [ ] Schedule Management (F-03, F-04, F-05)
- [ ] Push Notifications (F-06)

## 📞 Support

Jika ada pertanyaan atau issue, silakan buat issue di repository atau hubungi tim developer.

---

**Studify Frontend v1.0.0**
Built with ❤️ using Flutter
