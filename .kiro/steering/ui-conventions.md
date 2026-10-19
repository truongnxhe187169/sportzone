---
inclusion: auto
name: ui-conventions
description: Flutter UI design tokens, widget patterns, and SportZone visual conventions. Activate when writing widgets, pages, or styling code.
---

# SportZone – UI Conventions & Design System

## Color Palette (`lib/core/app_colors.dart`)

```dart
class AppColors {
  // Background
  static const Color background   = Color(0xFFFAFAFA); // Off-white surface
  static const Color surface      = Color(0xFFFFFFFF); // White interactive
  static const Color surfaceDim   = Color(0xFFF4F4F5); // Disabled / booked slots

  // Text
  static const Color textPrimary  = Color(0xFF09090B); // Deep Carbon
  static const Color textSecondary = Color(0xFF71717A); // Muted Zinc
  static const Color textDisabled = Color(0xFFA1A1AA); // Disabled text

  // Border
  static const Color border       = Color(0xFFE4E4E7); // Hairline border
  static const Color borderStrong = Color(0xFFD4D4D8); // Stronger border

  // Primary accent (CTA, selected state)
  static const Color primary      = Color(0xFF15803D); // Turf Green
  static const Color primaryLight = Color(0xFFF0FDF4); // Green tint bg
  static const Color primaryMuted = Color(0xFF86EFAC); // Green muted (on dark)

  // Peak hours accent
  static const Color peak         = Color(0xFFEA580C); // International Orange
  static const Color peakLight    = Color(0xFFFFFBEB); // Peak slot background
  static const Color peakBorder   = Color(0xFFFCD34D); // Peak/locked border

  // Slot states
  static const Color slotLocked   = Color(0xFFFEF3C7); // Amber tint (held by someone)
  static const Color slotLockedBorder = Color(0xFFD97706);

  // Status colors
  static const Color success      = Color(0xFF15803D);
  static const Color warning      = Color(0xFFD97706);
  static const Color error        = Color(0xFFDC2626);

  // Dark variants (nếu có dark mode)
  static const Color borderDark   = Color(0xFF27272A);
}
```

## Typography

```dart
// Dùng 2 font chính:
// - Inter / system sans-serif: headings, labels, body text
// - Monospace (JetBrains Mono / Courier): giá, giờ, mã sân, số liệu

// Heading sizes
static const TextStyle h1 = TextStyle(
  fontSize: 20, fontWeight: FontWeight.w800,
  letterSpacing: -0.4, color: AppColors.textPrimary,
);

static const TextStyle h2 = TextStyle(
  fontSize: 16, fontWeight: FontWeight.w700,
  letterSpacing: -0.3, color: AppColors.textPrimary,
);

static const TextStyle label = TextStyle(
  fontSize: 12, fontWeight: FontWeight.w600,
  letterSpacing: -0.2, color: AppColors.textPrimary,
);

// Monospace: BẮTBUỘC dùng cho giá tiền, giờ, mã sân
static const TextStyle mono = TextStyle(
  fontFamily: 'monospace',
  fontSize: 11, fontWeight: FontWeight.w700,
  letterSpacing: 0, color: AppColors.textPrimary,
  fontFeatures: [FontFeature.tabularFigures()],
);

static const TextStyle monoLarge = TextStyle(
  fontFamily: 'monospace',
  fontSize: 16, fontWeight: FontWeight.w800,
  letterSpacing: -0.2, color: AppColors.textPrimary,
  fontFeatures: [FontFeature.tabularFigures()],
);

static const TextStyle monoSmall = TextStyle(
  fontFamily: 'monospace',
  fontSize: 9, fontWeight: FontWeight.w500,
  color: AppColors.textSecondary,
);
```

## Border Radius Rules

```
TUYỆT ĐỐI KHÔNG dùng BorderRadius > 8px (không rounded-xl, không pill shape)

Buttons / TextFields / Cards:   BorderRadius.circular(4)
Input fields:                   BorderRadius.circular(4)
Chips / Tags:                   BorderRadius.circular(2)
Grid cells / Matrix slots:      BorderRadius.zero
Bottom sheets:                  BorderRadius.vertical(top: Radius.circular(8))
Dialogs:                        BorderRadius.circular(4)
```

## Shadow & Elevation Rules

```
KHÔNG dùng drop shadows (BoxDecoration.boxShadow: [])
KHÔNG dùng Card elevation > 0
KHÔNG dùng glassmorphism / backdrop blur

Thay thế bằng:
- Hairline border: Border.all(color: AppColors.border, width: 1)
- Strong border khi cần nhấn: Border.all(color: AppColors.textPrimary, width: 2)
```

## Button Pattern

```dart
// Primary CTA (đặt sân, xác nhận)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
      letterSpacing: -0.01),
  ),
  ...
)

// Secondary / Outline button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimary,
    side: const BorderSide(color: AppColors.border, width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    elevation: 0,
  ),
  ...
)

// Destructive (huỷ đặt sân)
// Dùng ElevatedButton với backgroundColor: AppColors.error
```

## Input Field Pattern

```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
  ),
)
```

## Slot States (Booking Matrix)

```dart
// Available
BoxDecoration( color: Colors.white, border: Border.all(color: AppColors.border) )

// Available – Peak hours (17:00–21:00)
BoxDecoration( color: AppColors.peakLight, border: Border.all(color: AppColors.border) )

// Booked / Occupied
BoxDecoration(
  color: AppColors.surfaceDim,
  border: Border.all(color: AppColors.border),
  // Thêm diagonal hatch bằng CustomPainter hoặc Image.asset
)

// Locked / Held
BoxDecoration(
  color: AppColors.slotLocked,
  border: Border.all(color: AppColors.peakBorder),
)

// Selected by user
BoxDecoration(
  color: AppColors.primary,
  border: Border.all(color: AppColors.primary),
)
```

## Spacing System

```dart
// Dùng bội số của 4px
const double xs  = 4.0;
const double sm  = 8.0;
const double md  = 12.0;
const double lg  = 16.0;  // padding chuẩn của page
const double xl  = 20.0;
const double xxl = 24.0;

// Page padding chuẩn
const EdgeInsets kPagePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
```

## Anti-patterns – KHÔNG làm

```dart
// ❌ KHÔNG dùng icon/emoji decorative trong heading
Text('⚽ Danh sách sân')   // sai
Text('Danh sách sân')      // đúng

// ❌ KHÔNG dùng pill-shaped badge
Chip(shape: StadiumBorder())     // sai
Container(borderRadius: BorderRadius.circular(2))  // đúng

// ❌ KHÔNG dùng rounded-xl cards
Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))  // sai
Container(decoration: BoxDecoration(
  border: Border.all(color: AppColors.border),
  borderRadius: BorderRadius.circular(4),  // đúng
))

// ❌ KHÔNG dùng BoxShadow
BoxDecoration(boxShadow: [...])   // sai
BoxDecoration(border: Border.all(color: AppColors.border))  // đúng

// ❌ KHÔNG dùng giá tiền với font thường
Text('180,000đ')  // font mặc định – sai
Text('180.000đ', style: AppTextStyles.mono)  // đúng
```

## Bottom Navigation

```dart
// 5 tabs theo thứ tự:
// [0] Sân (house icon)
// [1] Bản đồ (map icon)
// [2] Chat (message icon)
// [3] Thông báo (bell icon + badge)
// [4] Hồ sơ (person icon)

NavigationBar(
  elevation: 0,
  backgroundColor: AppColors.surface,
  shadowColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  indicatorColor: AppColors.primaryLight,
  ...
)
```

## Hiển thị tiền tệ

```dart
// LUÔN dùng intl để format tiền
import 'package:intl/intl.dart';

final _vndFormat = NumberFormat('#,###', 'vi_VN');

String formatPrice(double amount) => '${_vndFormat.format(amount)}đ';
// Kết quả: '180.000đ'

// Rút gọn trong matrix slots
String formatPriceShort(double amount) {
  if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}k';
  return '${amount.toInt()}';
}
// Kết quả: '180k'
```

## Responsive

App target Android phone, không cần tablet layout.  
Dùng `MediaQuery.of(context).size.width` khi cần responsive, không dùng `LayoutBuilder` cho đơn giản.
