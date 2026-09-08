class PaymentMethodConfig {
  const PaymentMethodConfig({
    required this.id,
    required this.name,
    required this.code,
    this.accountName = '',
    this.accountNumber = '',
    this.qrCodeUrl = '',
    this.instructions = '',
    this.iconName = 'payments',
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String code;
  final String accountName;
  final String accountNumber;
  final String qrCodeUrl;
  final String instructions;
  final String iconName;
  final bool isActive;
  final int sortOrder;

  PaymentMethodConfig copyWith({
    String? id,
    String? name,
    String? code,
    String? accountName,
    String? accountNumber,
    String? qrCodeUrl,
    String? instructions,
    String? iconName,
    bool? isActive,
    int? sortOrder,
  }) {
    return PaymentMethodConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      instructions: instructions ?? this.instructions,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory PaymentMethodConfig.fromJson(Map<String, dynamic> json) {
    return PaymentMethodConfig(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      qrCodeUrl: json['qrCodeUrl'] ?? '',
      instructions: json['instructions'] ?? '',
      iconName: json['iconName'] ?? 'payments',
      isActive: json['isActive'] ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'qrCodeUrl': qrCodeUrl,
      'instructions': instructions,
      'iconName': iconName,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }
}
