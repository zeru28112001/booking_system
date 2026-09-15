class SystemSettingsModel {
  const SystemSettingsModel({
    required this.supportPhone,
    required this.supportEmail,
    required this.isMaintenanceMode,
  });

  final String supportPhone;
  final String supportEmail;
  final bool isMaintenanceMode;

  factory SystemSettingsModel.fromJson(Map<String, dynamic> json) {
    return SystemSettingsModel(
      supportPhone: (json['supportPhone'] as String?) ?? '09 123 456 780',
      supportEmail: (json['supportEmail'] as String?) ?? 'support@bookingsystem.mm',
      isMaintenanceMode: (json['isMaintenanceMode'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'supportPhone': supportPhone,
        'supportEmail': supportEmail,
        'isMaintenanceMode': isMaintenanceMode,
      };

  SystemSettingsModel copyWith({
    String? supportPhone,
    String? supportEmail,
    bool? isMaintenanceMode,
  }) {
    return SystemSettingsModel(
      supportPhone: supportPhone ?? this.supportPhone,
      supportEmail: supportEmail ?? this.supportEmail,
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
    );
  }
}
