class ProviderPayment {
  const ProviderPayment({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.paidAt,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String customerId;
  final String customerName;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime? paidAt;
  final DateTime createdAt;

  ProviderPayment copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    String? customerName,
    double? amount,
    String? paymentMethod,
    String? status,
    DateTime? paidAt,
    DateTime? createdAt,
  }) {
    return ProviderPayment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ProviderPayment.fromJson(Map<String, dynamic> json) {
    String cName = 'Customer';
    String cId = '';
    if (json['customerId'] != null) {
      if (json['customerId'] is Map<String, dynamic>) {
        cName = json['customerId']['name'] ?? 'Customer';
        cId = json['customerId']['_id'] ?? json['customerId']['id'] ?? '';
      } else if (json['customerId'] is String) {
        cId = json['customerId'];
      }
    }

    String bId = '';
    if (json['bookingId'] != null) {
      if (json['bookingId'] is Map<String, dynamic>) {
        bId = json['bookingId']['_id'] ?? json['bookingId']['id'] ?? '';
      } else if (json['bookingId'] is String) {
        bId = json['bookingId'];
      }
    }

    return ProviderPayment(
      id: json['_id'] ?? json['id'] ?? '',
      bookingId: bId,
      customerId: cId,
      customerName: cName,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'cash',
      status: json['status'] ?? 'pending',
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'customerId': customerId,
      'customerName': customerName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'paidAt': paidAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ProviderPaymentSummary {
  const ProviderPaymentSummary({
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.refundedAmount,
    required this.totalTransactions,
    required this.completedCount,
    required this.pendingCount,
    required this.refundedCount,
  });

  final double totalEarnings;
  final double pendingEarnings;
  final double refundedAmount;
  final int totalTransactions;
  final int completedCount;
  final int pendingCount;
  final int refundedCount;

  factory ProviderPaymentSummary.fromJson(Map<String, dynamic> json) {
    return ProviderPaymentSummary(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      pendingEarnings: (json['pendingEarnings'] as num?)?.toDouble() ?? 0.0,
      refundedAmount: (json['refundedAmount'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: (json['totalTransactions'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      refundedCount: (json['refundedCount'] as num?)?.toInt() ?? 0,
    );
  }
}
