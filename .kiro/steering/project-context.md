# SportZone – Project Context

## Tổng quan

**Dự án:** SportZone – Ứng dụng đặt sân thể thao (Pickleball, Cầu lông, Bóng đá, Tennis)  
**Môn học:** PRM393 – Mobile Application Development (Flutter)  
**Nhóm:** 2 người, tech stack mức cơ bản  
**Thời gian:** 5 tuần

## Tech Stack

| Công nghệ | Package | Mục đích |
|-----------|---------|---------|
| State Management | `provider: ^6.1.2` | ChangeNotifier + Consumer |
| Database | `sqflite: ^2.3.3` | SQLite local |
| DB Path | `path: ^1.9.0` | Đường dẫn file SQLite |
| Session | `shared_preferences: ^2.3.2` | Lưu userId sau login |
| Password | `crypto: ^3.0.3` | SHA-256 hash |
| Maps | `google_maps_flutter: ^2.9.0` | Bản đồ + markers sân |
| GPS | `geolocator: ^13.0.1` | Vị trí người dùng |
| Notifications | `flutter_local_notifications: ^17.2.3` | Push notification local |
| Images | `cached_network_image: ^3.4.1` | Load ảnh từ URL, cache |
| Image Picker | `image_picker: ^1.1.2` | Đổi avatar profile |
| Formatting | `intl: ^0.19.0` | Format ngày, tiền VNĐ |
| Routing | `go_router: ^14.3.0` | Navigation |

## Kiến trúc: MVVM + Provider

```
View (Widget/Page)
  └── Consumer<XViewModel> / context.watch<XViewModel>()
        └── ViewModel (ChangeNotifier)
              └── DatabaseService (sqflite CRUD)
                    └── SQLite Database
```

**Quy tắc quan trọng:**
- View **không** chứa business logic, chỉ render UI và gọi ViewModel methods
- ViewModel **không** import Flutter widgets, chỉ import models và services
- Mọi thay đổi state phải gọi `notifyListeners()` sau khi update
- `DatabaseService` là singleton, được inject qua constructor của ViewModel

## Cấu trúc thư mục

```
lib/
├── models/
│   ├── user.dart           # User entity
│   ├── court.dart          # Court entity
│   ├── booking.dart        # Booking entity
│   ├── message.dart        # Chat message entity
│   └── notification.dart   # Notification entity
│
├── services/
│   ├── database_service.dart   # Tất cả SQLite CRUD
│   └── location_service.dart   # Geolocator wrapper
│
├── viewmodels/
│   ├── auth_viewmodel.dart        # Login, Register, Logout, session
│   ├── court_viewmodel.dart       # Load courts, search, filter
│   ├── booking_viewmodel.dart     # Cart, checkout, my bookings, cancel
│   ├── chat_viewmodel.dart        # Messages per court
│   └── notification_viewmodel.dart
│
├── views/
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── courts/
│   │   ├── court_list_page.dart
│   │   └── court_detail_page.dart
│   ├── booking/
│   │   ├── booking_cart_page.dart
│   │   └── checkout_page.dart
│   ├── map/
│   │   └── map_page.dart
│   ├── chat/
│   │   ├── chat_list_page.dart
│   │   └── chat_room_page.dart
│   ├── notification/
│   │   └── notification_page.dart
│   └── profile/
│       ├── profile_page.dart
│       └── my_bookings_page.dart
│
├── widgets/            # Reusable widgets dùng nhiều nơi
│   ├── court_card.dart
│   ├── booking_tile.dart
│   ├── time_slot_cell.dart
│   └── star_rating.dart
│
├── core/
│   ├── app_colors.dart     # Tất cả màu sắc (xem ui-conventions.md)
│   ├── app_strings.dart    # Hardcoded strings tiếng Việt
│   └── app_router.dart     # go_router configuration
│
└── main.dart               # MultiProvider setup
```

## main.dart MultiProvider Setup

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbService = DatabaseService();
  await dbService.init(); // tạo tables + seed data nếu lần đầu

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(dbService)),
        ChangeNotifierProvider(create: (_) => CourtViewModel(dbService)),
        ChangeNotifierProvider(create: (_) => BookingViewModel(dbService)),
        ChangeNotifierProvider(create: (_) => ChatViewModel(dbService)),
        ChangeNotifierProvider(create: (_) => NotificationViewModel(dbService)),
      ],
      child: const SportZoneApp(),
    ),
  );
}
```

## Naming Conventions

| Loại | Convention | Ví dụ |
|------|-----------|-------|
| Files | `snake_case.dart` | `court_detail_page.dart` |
| Classes | `PascalCase` | `CourtViewModel` |
| Methods | `camelCase` | `loadCourts()`, `confirmBooking()` |
| Variables | `camelCase` | `selectedSlots`, `currentUser` |
| Constants | `kCamelCase` | `kPrimaryColor`, `kPeakStartHour` |
| Private | `_prefix` | `_courts`, `_isLoading` |
| Pages | `XxxPage` suffix | `CourtDetailPage` |
| ViewModels | `XxxViewModel` suffix | `BookingViewModel` |
| Models | Tên thực thể | `Court`, `Booking`, `User` |

## Các màn hình và ViewModel tương ứng

| Màn hình | ViewModel chính | Chức năng PRM393 |
|----------|----------------|-----------------|
| LoginPage / RegisterPage | AuthViewModel | #2 Login |
| CourtListPage | CourtViewModel | #3 Product list |
| CourtDetailPage | CourtViewModel + BookingViewModel | #4 Product detail |
| BookingCartPage | BookingViewModel | #5 Shopping cart |
| CheckoutPage | BookingViewModel | #6 Checkout |
| NotificationPage | NotificationViewModel | #7 Notifications |
| MapPage | CourtViewModel + LocationService | #8 Map |
| ChatRoomPage | ChatViewModel | #9 Messaging |
| HomeScreen (BottomNav) | All ViewModels | #10 State management |

## Authentication Flow

- Mật khẩu được hash bằng SHA-256 trước khi lưu vào SQLite
- Session lưu trong SharedPreferences với key `user_id`
- SplashScreen check session → điều hướng tự động
- Sau đăng xuất: xoá key `user_id`, điều hướng LoginPage và replace stack

## Lưu ý cho Team

- **Không dùng Firebase** – tất cả data lưu SQLite local
- **Không dùng BLoC** – dùng Provider + ChangeNotifier
- Chat là **mock** – auto-reply từ "chủ sân" sau 1.5s (lưu SQLite)
- Seed 15 sân mẫu với toạ độ TP.HCM/Hà Nội thực tế khi DB init lần đầu
- Tất cả comment code bằng tiếng Việt hoặc tiếng Anh đều được, miễn có comment
