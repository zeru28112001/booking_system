import '../../../provider_portal/domain/entities/payment_method_config.dart';

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
    this.bookingType = 'in_shop',
    required this.address,
    this.latitude,
    this.longitude,
    required this.notes,
    required this.paymentMethod,
    required this.status,
    required this.price,
    required this.durationMinutes,
    required this.createdAt,
    this.staffId,
    this.staffName,
    this.customerName,
    this.customerPhone,
    this.paymentMethodId,
    this.paymentMethodConfig,
  });

  final String id;
  final String providerId;
  final String providerName;
  final String serviceId;
  final String serviceName;
  final String? staffId;
  final String? staffName;
  final String? customerName;
  final String? customerPhone;

  /// 'yyyy-MM-dd'
  final String date;

  /// 'HH:mm' (24h)
  final String timeSlot;

  /// 'in_shop' | 'home_service'
  final String bookingType;

  final String address;
  final double? latitude;
  final double? longitude;
  final String notes;

  /// 'cash' | 'myanmyanpay' | 'stripe' or payment code
  final String paymentMethod;

  final String? paymentMethodId;
  final PaymentMethodConfig? paymentMethodConfig;

  /// 'pending' | 'accepted' | 'in_progress' | 'completed' | 'cancelled'
  final String status;

  /// Price in MMK.
  final int price;
  final int durationMinutes;

  /// ISO-8601 creation timestamp.
  final String createdAt;

  Booking copyWith({
    String? status,
    String? bookingType,
    String? customerName,
    String? customerPhone,
    String? paymentMethodId,
    PaymentMethodConfig? paymentMethodConfig,
  }) =>
      Booking(
        id: id,
        providerId: providerId,
        providerName: providerName,
        serviceId: serviceId,
        serviceName: serviceName,
        staffId: staffId,
        staffName: staffName,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        date: date,
        timeSlot: timeSlot,
        bookingType: bookingType ?? this.bookingType,
        address: address,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        paymentMethod: paymentMethod,
        paymentMethodId: paymentMethodId ?? this.paymentMethodId,
        paymentMethodConfig: paymentMethodConfig ?? this.paymentMethodConfig,
        status: status ?? this.status,
        price: price,
        durationMinutes: durationMinutes,
        createdAt: createdAt,
      );

  @override
  String toString() => 'Booking(id: $id, status: $status)';
}
