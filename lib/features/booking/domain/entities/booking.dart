/// Domain entity — one booked appointment.
/// No JSON logic here. No HTTP imports.
class Booking {
  const Booking({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.timeSlot,
    required this.address,
    required this.notes,
    required this.paymentMethod,
    required this.status,
    required this.price,
    required this.durationMinutes,
    required this.createdAt,
    this.staffId,
    this.staffName,
  });

  final String id;
  final String providerId;
  final String providerName;
  final String serviceId;
  final String serviceName;
  final String? staffId;
  final String? staffName;

  /// 'yyyy-MM-dd'
  final String date;

  /// 'HH:mm' (24h)
  final String timeSlot;

  final String address;
  final String notes;

  /// 'cash' | 'myanmyanpay' | 'stripe'
  final String paymentMethod;

  /// 'pending' | 'accepted' | 'in_progress' | 'completed' | 'cancelled'
  final String status;

  /// Price in MMK.
  final int price;
  final int durationMinutes;

  /// ISO-8601 creation timestamp.
  final String createdAt;

  Booking copyWith({String? status}) => Booking(
        id: id,
        providerId: providerId,
        providerName: providerName,
        serviceId: serviceId,
        serviceName: serviceName,
        staffId: staffId,
        staffName: staffName,
        date: date,
        timeSlot: timeSlot,
        address: address,
        notes: notes,
        paymentMethod: paymentMethod,
        status: status ?? this.status,
        price: price,
        durationMinutes: durationMinutes,
        createdAt: createdAt,
      );

  @override
  String toString() => 'Booking(id: $id, status: $status)';
}
