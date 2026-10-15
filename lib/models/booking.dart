import 'dart:convert';

/// Model đại diện cho một lượt đặt sân
class Booking {
  final int id;
  final int courtId;
  final int userId;
  final String date; // YYYY-MM-DD
  final String startTime; // HH:MM
  final String endTime; // HH:MM
  final double totalPrice;
  final String status; // 'confirmed' | 'cancelled'
  final Map<String, bool> addons; // {"racket":true,"ball":false}
  final String createdAt;
  // Trường join từ query JOIN với bảng courts
  final String? courtName;
  final String? courtType;

  const Booking({
    required this.id,
    required this.courtId,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.addons,
    required this.createdAt,
    this.courtName,
    this.courtType,
  });

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        id: map['id'] as int,
        courtId: map['court_id'] as int,
        userId: map['user_id'] as int,
        date: map['date'] as String,
        startTime: map['start_time'] as String,
        endTime: map['end_time'] as String,
        totalPrice: (map['total_price'] as num).toDouble(),
        status: map['status'] as String? ?? 'confirmed',
        addons: map['addons'] != null
            ? Map<String, bool>.from(jsonDecode(map['addons'] as String))
            : {},
        createdAt: map['created_at'] as String,
        courtName: map['court_name'] as String?,
        courtType: map['court_type'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'court_id': courtId,
        'user_id': userId,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        'total_price': totalPrice,
        'status': status,
        'addons': jsonEncode(addons),
        'created_at': createdAt,
      };

  Booking copyWith({
    int? id,
    int? courtId,
    int? userId,
    String? date,
    String? startTime,
    String? endTime,
    double? totalPrice,
    String? status,
    Map<String, bool>? addons,
    String? createdAt,
    String? courtName,
    String? courtType,
  }) =>
      Booking(
        id: id ?? this.id,
        courtId: courtId ?? this.courtId,
        userId: userId ?? this.userId,
        date: date ?? this.date,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        totalPrice: totalPrice ?? this.totalPrice,
        status: status ?? this.status,
        addons: addons ?? this.addons,
        createdAt: createdAt ?? this.createdAt,
        courtName: courtName ?? this.courtName,
        courtType: courtType ?? this.courtType,
      );
}
