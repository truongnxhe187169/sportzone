---
inclusion: manual
---

# SportZone – SQLite Database Schema

Kích hoạt file này khi làm việc liên quan đến database, `DatabaseService`, models, hoặc queries.

## DatabaseService – Conventions

```dart
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance; // singleton
  DatabaseService._internal();

  Database? _db;

  Future<void> init() async {
    final path = join(await getDatabasesPath(), 'sportzone.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
      onOpen: (db) async => await _seedIfEmpty(db),
    );
  }

  Database get db => _db!;
}
```

- Mọi method CRUD đều là `async` và trả về `Future`
- Dùng `db.insert()`, `db.query()`, `db.update()`, `db.rawQuery()` 
- Không dùng raw SQL string trực tiếp ngoài `rawQuery` khi cần JOIN
- Parameterized queries bắt buộc (tránh SQL injection): dùng `where: 'id = ?', whereArgs: [id]`

## Schema đầy đủ

### Table: `users`
```sql
CREATE TABLE users (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  name       TEXT    NOT NULL,
  email      TEXT    NOT NULL UNIQUE,
  password   TEXT    NOT NULL,   -- SHA-256 hex string
  phone      TEXT,
  avatar     TEXT,               -- local file path hoặc asset URL
  created_at TEXT    NOT NULL    -- ISO 8601: 2026-10-20T09:41:00
);
```

### Table: `courts`
```sql
CREATE TABLE courts (
  id                  INTEGER PRIMARY KEY AUTOINCREMENT,
  name                TEXT    NOT NULL,
  type                TEXT    NOT NULL, -- 'badminton' | 'pickleball' | 'football' | 'tennis'
  address             TEXT    NOT NULL,
  lat                 REAL    NOT NULL,
  lng                 REAL    NOT NULL,
  price_per_hour      REAL    NOT NULL, -- giá off-peak (VNĐ)
  peak_price_per_hour REAL    NOT NULL, -- giá peak 17:00-21:00
  description         TEXT,
  images              TEXT,             -- JSON: '["url1","url2"]'
  rating              REAL    DEFAULT 0.0,
  review_count        INTEGER DEFAULT 0
);
```

### Table: `time_slots`
```sql
CREATE TABLE time_slots (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  court_id     INTEGER NOT NULL,
  date         TEXT    NOT NULL, -- YYYY-MM-DD
  start_time   TEXT    NOT NULL, -- HH:MM (e.g. '08:00')
  end_time     TEXT    NOT NULL, -- HH:MM (e.g. '09:00')
  is_available INTEGER DEFAULT 1, -- 1 = trống, 0 = đã đặt
  FOREIGN KEY (court_id) REFERENCES courts(id)
);
```

**Tạo time_slots khi seed:** Mỗi sân × 7 ngày tới × các slot 1h từ 05:00–22:00  
**Update khi đặt sân:** `UPDATE time_slots SET is_available = 0 WHERE court_id = ? AND date = ? AND start_time IN (...)`

### Table: `bookings`
```sql
CREATE TABLE bookings (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  court_id    INTEGER NOT NULL,
  user_id     INTEGER NOT NULL,
  date        TEXT    NOT NULL, -- YYYY-MM-DD
  start_time  TEXT    NOT NULL, -- HH:MM
  end_time    TEXT    NOT NULL, -- HH:MM
  total_price REAL    NOT NULL, -- tổng tiền cả dịch vụ thêm
  status      TEXT    DEFAULT 'confirmed', -- 'confirmed' | 'cancelled'
  addons      TEXT,             -- JSON: '{"racket":true,"ball":false}'
  created_at  TEXT    NOT NULL,
  FOREIGN KEY (court_id) REFERENCES courts(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Table: `reviews`
```sql
CREATE TABLE reviews (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  court_id   INTEGER NOT NULL,
  user_id    INTEGER NOT NULL,
  rating     REAL    NOT NULL CHECK(rating >= 1 AND rating <= 5),
  comment    TEXT,
  created_at TEXT    NOT NULL,
  FOREIGN KEY (court_id) REFERENCES courts(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

**Sau khi insert review:** Tính lại `courts.rating = AVG(reviews.rating)` và cập nhật `courts.review_count`

### Table: `messages`
```sql
CREATE TABLE messages (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  court_id     INTEGER NOT NULL,
  user_id      INTEGER NOT NULL,
  is_from_user INTEGER DEFAULT 1, -- 1 = user gửi, 0 = chủ sân reply (mock)
  text         TEXT    NOT NULL,
  timestamp    TEXT    NOT NULL,  -- ISO 8601
  FOREIGN KEY (court_id) REFERENCES courts(id),
  FOREIGN KEY (user_id)  REFERENCES users(id)
);
```

**Chat query:** `SELECT * FROM messages WHERE court_id = ? AND user_id = ? ORDER BY timestamp ASC`

### Table: `notifications`
```sql
CREATE TABLE notifications (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id    INTEGER NOT NULL,
  title      TEXT    NOT NULL,
  body       TEXT    NOT NULL,
  type       TEXT    NOT NULL,    -- 'booking' | 'cancel' | 'reminder' | 'system'
  is_read    INTEGER DEFAULT 0,   -- 0 = chưa đọc, 1 = đã đọc
  created_at TEXT    NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

**Unread count (cho badge):** `SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0`

## Các Query thường dùng

```dart
// Lấy tất cả sân theo type
Future<List<Court>> getCourtsByType(String type) async {
  final maps = await db.query('courts',
    where: type == 'all' ? null : 'type = ?',
    whereArgs: type == 'all' ? null : [type],
  );
  return maps.map((m) => Court.fromMap(m)).toList();
}

// Tìm kiếm sân theo từ khoá
Future<List<Court>> searchCourts(String query) async {
  final maps = await db.rawQuery(
    'SELECT * FROM courts WHERE name LIKE ? OR address LIKE ?',
    ['%$query%', '%$query%'],
  );
  return maps.map((m) => Court.fromMap(m)).toList();
}

// Lấy time slots của sân theo ngày
Future<List<TimeSlot>> getTimeSlots(int courtId, String date) async {
  final maps = await db.query('time_slots',
    where: 'court_id = ? AND date = ?',
    whereArgs: [courtId, date],
    orderBy: 'start_time ASC',
  );
  return maps.map((m) => TimeSlot.fromMap(m)).toList();
}

// Lấy bookings của user
Future<List<Booking>> getUserBookings(int userId) async {
  final maps = await db.rawQuery('''
    SELECT b.*, c.name as court_name, c.type as court_type
    FROM bookings b
    JOIN courts c ON b.court_id = c.id
    WHERE b.user_id = ?
    ORDER BY b.created_at DESC
  ''', [userId]);
  return maps.map((m) => Booking.fromMap(m)).toList();
}
```

## Model Pattern (fromMap / toMap)

```dart
class Court {
  final int id;
  final String name;
  final String type;
  final String address;
  final double lat;
  final double lng;
  final double pricePerHour;
  final double peakPricePerHour;
  final String? description;
  final List<String> images;
  final double rating;
  final int reviewCount;

  Court({required this.id, required this.name, /* ... */});

  factory Court.fromMap(Map<String, dynamic> map) => Court(
    id: map['id'] as int,
    name: map['name'] as String,
    type: map['type'] as String,
    address: map['address'] as String,
    lat: map['lat'] as double,
    lng: map['lng'] as double,
    pricePerHour: map['price_per_hour'] as double,
    peakPricePerHour: map['peak_price_per_hour'] as double,
    description: map['description'] as String?,
    images: List<String>.from(jsonDecode(map['images'] ?? '[]')),
    rating: (map['rating'] as num).toDouble(),
    reviewCount: map['review_count'] as int,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'type': type,
    'address': address,
    'lat': lat,
    'lng': lng,
    'price_per_hour': pricePerHour,
    'peak_price_per_hour': peakPricePerHour,
    'description': description,
    'images': jsonEncode(images),
    'rating': rating,
    'review_count': reviewCount,
  };
}
```

## Seed Data (15 sân mẫu)

Khi `_seedIfEmpty()` được gọi, insert 15 sân với:
- **5 sân Pickleball** tại Hà Nội (quận Thanh Xuân, Cầu Giấy, Đống Đa)
- **4 sân Cầu lông** tại Hà Nội
- **4 sân Bóng đá 7** tại TP.HCM (Bình Thạnh, Gò Vấp, Quận 7)
- **2 sân Tennis** tại TP.HCM

Toạ độ thực tế ví dụ:
```dart
// Pickleball Yên Xá – Thanh Xuân HN
lat: 20.9956, lng: 105.8027, price: 80000, peak_price: 180000

// Cầu lông Mỹ Đình – Nam Từ Liêm HN
lat: 21.0197, lng: 105.7648, price: 70000, peak_price: 150000

// Bóng đá Thống Nhất – Q10 HCM
lat: 10.7769, lng: 106.6678, price: 500000, peak_price: 800000
```

Mỗi sân cũng tạo sẵn `time_slots` cho 7 ngày tiếp theo (05:00–22:00, block 1h).  
Một số slot được set `is_available = 0` ngẫu nhiên để demo trạng thái "đã đặt".
