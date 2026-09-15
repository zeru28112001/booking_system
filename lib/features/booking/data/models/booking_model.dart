import '../../../provider_portal/domain/entities/payment_method_config.dart';
import '../../domain/entities/booking.dart';

/// Data-layer DTO — extends Booking and adds JSON (de)serialization.
/// Screens and providers never import this class.
class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.providerId,
    required super.providerName,
    required super.serviceId,
    required super.serviceName,
    required super.date,
    required super.timeSlot,
    super.bookingType = 'in_shop',
    required super.address,
    super.latitude,
    super.longitude,
    required super.notes,
    required super.paymentMethod,
    required super.status,
    required super.price,
    required super.durationMinutes,
    required super.createdAt,
    super.staffId,
    super.staffName,
    super.paymentMethodId,
    super.paymentMethodConfig,
    super.customerName,
    super.customerPhone,
    this.customerId,
  });

  final String? customerId;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    PaymentMethodConfig? pmConfig;
    String? pmId;

    final pmIdRaw = json['paymentMethodId'] ?? json['payment_method_id'];
    if (pmIdRaw is Map<String, dynamic>) {
      pmConfig = PaymentMethodConfig.fromJson(pmIdRaw);
      pmId = pmConfig.id;
    } else if (pmIdRaw != null) {
      pmId = pmIdRaw.toString();
    }

    String? cName;
    String? cPhone;
    String? cId;

    final customerRaw = json['customer_id'] ?? json['customerId'];
    if (customerRaw is Map<String, dynamic>) {
      cId = (customerRaw['_id'] ?? customerRaw['id'] ?? '').toString();
      cName = customerRaw['name']?.toString();
      cPhone = customerRaw['phone']?.toString();
    } else if (customerRaw != null) {
      cId = customerRaw.toString();
    }

    return BookingModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      customerId: cId ?? '',
      customerName: cName,
      customerPhone: cPhone,
      providerId: (json['provider_id'] ?? json['providerId'] ?? '').toString(),
      providerName: (json['provider_name'] as String?) ??
          (json['providerName'] as String?) ??
          '',
      serviceId: (json['service_id'] ?? json['serviceId'] ?? '').toString(),
      serviceName: (json['service_name'] as String?) ??
          (json['serviceName'] as String?) ??
          '',
      staffId: (json['staff_id'] as String?) ?? (json['staffId'] as String?),
      staffName:
          (json['staff_name'] as String?) ?? (json['staffName'] as String?),
      date: (json['date'] as String?) ?? '',
      timeSlot: (json['time_slot'] as String?) ??
          (json['timeSlot'] as String?) ??
          '',
      bookingType: (json['booking_type'] as String?) ??
          (json['bookingType'] as String?) ??
          'in_shop',
      address: (json['address'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      notes: (json['notes'] as String?) ?? '',
      paymentMethodId: pmId,
      paymentMethodConfig: pmConfig,
      paymentMethod: (json['payment_method'] as String?) ??
          (json['paymentMethod'] as String?) ??
          'cash',
      status: (json['status'] as String?) ?? 'pending',
      price: (json['price'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ??
          (json['durationMinutes'] as num?)?.toInt() ??
          0,
      createdAt: (json['created_at'] as String?) ??
          (json['createdAt'] as String?) ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'provider_id': providerId,
        'provider_name': providerName,
        'service_id': serviceId,
        'service_name': serviceName,
        'staff_id': staffId,
        'staff_name': staffName,
        'date': date,
        'time_slot': timeSlot,
        'booking_type': bookingType,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes,
        'payment_method': paymentMethod,
        'payment_method_id': paymentMethodId,
        'status': status,
        'price': price,
        'duration_minutes': durationMinutes,
        'created_at': createdAt,
      };

  @override
  BookingModel copyWith({
    String? status,
    String? bookingType,
    String? customerName,
    String? customerPhone,
    String? paymentMethodId,
    PaymentMethodConfig? paymentMethodConfig,
  }) =>
      BookingModel(
        id: id,
        customerId: customerId,
        customerName: customerName ?? this.customerName,
        customerPhone: customerPhone ?? this.customerPhone,
        providerId: providerId,
        providerName: providerName,
        serviceId: serviceId,
        serviceName: serviceName,
        staffId: staffId,
        staffName: staffName,
        date: date,
        timeSlot: timeSlot,
        bookingType: bookingType ?? this.bookingType,
        address: address,
        notes: notes,
        paymentMethod: paymentMethod,
        paymentMethodId: paymentMethodId ?? this.paymentMethodId,
        paymentMethodConfig: paymentMethodConfig ?? this.paymentMethodConfig,
        status: status ?? this.status,
        price: price,
        durationMinutes: durationMinutes,
        createdAt: createdAt,
      );
}
