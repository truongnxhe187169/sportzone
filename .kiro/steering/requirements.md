---
inclusion: manual
---

# SportZone – Functional & Non-Functional Requirements

Kích hoạt file này khi cần tham chiếu danh sách yêu cầu, viết báo cáo, hoặc kiểm tra feature coverage.

## Functional Requirements

### FR-01 – Xác thực người dùng
- FR-01.1: Người dùng có thể đăng ký tài khoản với Tên, Email, SĐT, Mật khẩu
- FR-01.2: Hệ thống validate email format và mật khẩu ≥ 8 ký tự
- FR-01.3: Mật khẩu được hash SHA-256 trước khi lưu vào SQLite
- FR-01.4: Người dùng có thể đăng nhập bằng Email + Mật khẩu
- FR-01.5: Session được lưu trong SharedPreferences, tự đăng nhập lại sau khi đóng app
- FR-01.6: Người dùng có thể đăng xuất

### FR-02 – Danh sách sân
- FR-02.1: Hiển thị danh sách tất cả sân dưới dạng grid/list
- FR-02.2: Lọc sân theo loại (Pickleball / Cầu lông / Bóng đá / Tennis)
- FR-02.3: Tìm kiếm sân theo tên hoặc địa chỉ (realtime khi gõ)
- FR-02.4: Mỗi CourtCard hiển thị ảnh, tên, loại sân, giá/giờ, rating

### FR-03 – Chi tiết sân
- FR-03.1: Hiển thị ảnh sân (PageView cuộn ngang)
- FR-03.2: Hiển thị thông tin: tên, địa chỉ, loại sân, giá off-peak và peak, mô tả, rating
- FR-03.3: DateStrip 7 ngày cho phép chọn ngày muốn đặt
- FR-03.4: Ma trận 2D (sân × giờ) hiển thị trạng thái từng slot: trống / đã đặt / đang giữ / đang chọn / giờ vàng
- FR-03.5: Slot "đã đặt" và "đang giữ" không clickable
- FR-03.6: Slot "giờ vàng" (17:00–21:00) hiển thị giá peak

### FR-04 – Đặt sân
- FR-04.1: Người dùng có thể tap chọn nhiều slot liên tiếp trên cùng một sân
- FR-04.2: Checkout bar xuất hiện khi ≥ 1 slot được chọn
- FR-04.3: Người dùng có thể thêm/bỏ dịch vụ kèm (thuê vợt, nhặt bóng, nước)
- FR-04.4: Tổng tiền cập nhật realtime khi thêm/bỏ add-ons
- FR-04.5: Xác nhận booking → lưu vào bảng `bookings`, cập nhật `time_slots.is_available = 0`

### FR-05 – Giỏ đặt & Thanh toán
- FR-05.1: BookingCartPage hiển thị chi tiết: sân, ngày, giờ, thời lượng, dịch vụ thêm, tổng tiền
- FR-05.2: CheckoutPage hiển thị số tiền cọc 50%
- FR-05.3: Sau xác nhận, tạo notification "Đặt sân thành công"

### FR-06 – Lịch sử đặt sân
- FR-06.1: MyBookingsPage hiển thị danh sách booking theo tabs: Sắp tới / Đã chơi / Đã huỷ
- FR-06.2: Booking "Sắp tới" có nút Huỷ (với dialog xác nhận)
- FR-06.3: Huỷ booking → status = 'cancelled', time_slots quay về is_available = 1
- FR-06.4: Booking "Đã chơi" có nút Đánh giá

### FR-07 – Thông báo
- FR-07.1: Hiển thị danh sách notifications từ SQLite
- FR-07.2: Notification được tạo khi: đặt sân thành công, huỷ sân
- FR-07.3: Tap notification → đánh dấu is_read = 1
- FR-07.4: Badge số lượng chưa đọc hiển thị trên bottom nav tab
- FR-07.5: flutter_local_notifications trigger notification sau khi booking confirmed

### FR-08 – Bản đồ
- FR-08.1: Hiển thị Google Maps với vị trí hiện tại của người dùng
- FR-08.2: Hiển thị markers tại vị trí tất cả các sân (load từ SQLite)
- FR-08.3: Tap marker → InfoWindow: tên sân, giá từ Xk/giờ, nút "Xem chi tiết"
- FR-08.4: Tap "Xem chi tiết" → điều hướng đến CourtDetailPage

### FR-09 – Chat
- FR-09.1: Người dùng có thể gửi tin nhắn cho "chủ sân" từ CourtDetailPage
- FR-09.2: Tin nhắn lưu vào bảng `messages` trong SQLite
- FR-09.3: Hệ thống tự động tạo reply từ "chủ sân" sau ~1.5 giây (mock)
- FR-09.4: ChatListPage hiển thị danh sách sân đã nhắn tin
- FR-09.5: Lịch sử tin nhắn được lưu và hiển thị lại khi mở ChatRoomPage

### FR-10 – State Management
- FR-10.1: UI cập nhật tự động (không cần reload thủ công) khi state thay đổi trong ViewModel
- FR-10.2: Sử dụng Provider + ChangeNotifier + notifyListeners()
- FR-10.3: MultiProvider đặt ở root (main.dart), inject cho toàn app
- FR-10.4: Các ViewModel được share state giữa nhiều màn hình (VD: badge notification)

### FR-11 – Đánh giá sân
- FR-11.1: Người dùng có thể rate sân (1–5 sao) và để lại nhận xét
- FR-11.2: Rating trung bình của sân cập nhật sau mỗi review mới
- FR-11.3: Chỉ có thể đánh giá sân đã từng đặt

### FR-12 – Hồ sơ
- FR-12.1: Người dùng có thể xem và cập nhật tên, SĐT
- FR-12.2: Người dùng có thể đổi avatar từ thư viện ảnh (image_picker)
- FR-12.3: ProfilePage có shortcut đến MyBookingsPage

---

## Non-Functional Requirements

### NFR-01 – Hiệu năng
- App load danh sách sân < 2 giây
- UI đạt 60fps khi scroll ma trận booking
- SQLite queries không chạy trên main thread (dùng `async/await`)

### NFR-02 – Bảo mật
- Mật khẩu KHÔNG được lưu plain text, phải hash SHA-256
- Không log thông tin nhạy cảm (email, password) ra console trong release build
- SQLite file ở internal storage (không accessible từ app khác)

### NFR-03 – Usability
- Tuân thủ Material Design 3 guidelines
- Mọi action có feedback rõ ràng: loading indicator, snackbar, dialog
- Empty state có hướng dẫn (không để màn hình trắng)
- Form có validation message rõ ràng

### NFR-04 – Reliability
- App không crash khi mất kết nối internet (data từ SQLite local)
- DB có xử lý lỗi (try/catch) cho mọi CRUD operation

### NFR-05 – Testing
- Tối thiểu 1 Unit Test: `BookingViewModel` — test tính `totalPrice` và validate time slot
- Tối thiểu 1 Widget Test: `CourtCard` — verify render đúng name, price, type
- Cả 2 test phải PASS khi chạy `flutter test`

### NFR-06 – Deployment
- Build được Release APK: `flutter build apk --release`
- App chạy được trên Android emulator hoặc thiết bị thật ở Release Mode
- Có screenshot/video chứng minh chạy Release Mode

---

## 10 Chức năng theo Project Sample

Mapping từng chức năng mẫu → màn hình SportZone:

| # | Chức năng mẫu | Màn hình SportZone | Điểm |
|---|---------------|-------------------|------|
| 1 | Design database/API structure | SQLite schema (7 tables) | 10% |
| 2 | Login screen | LoginPage + RegisterPage | 10% |
| 3 | Product list screen | CourtListPage | 10% |
| 4 | Product detail screen | CourtDetailPage + Booking Matrix | 10% |
| 5 | Shopping cart screen | BookingCartPage | 10% |
| 6 | Checkout/billing screen | CheckoutPage | 10% |
| 7 | Notifications screen | NotificationPage | 10% |
| 8 | Map screen | MapPage | 10% |
| 9 | Messaging/chat screen | ChatListPage + ChatRoomPage | 10% |
| 10 | Apply state management | Provider + ChangeNotifier toàn app | 10% |

---

## Definition of Done (cho mỗi feature)

- [ ] ViewModel có đầy đủ methods cần thiết
- [ ] DatabaseService có CRUD methods tương ứng
- [ ] UI render đúng theo design conventions (xem ui-conventions.md)
- [ ] State cập nhật qua `notifyListeners()`, UI tự rebuild
- [ ] Error cases được xử lý (empty state, loading, error message)
- [ ] Code có comment giải thích logic chính
- [ ] Chạy được trên emulator không crash
