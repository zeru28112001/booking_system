import '../../domain/entities/service.dart';

/// Data-layer DTO — extends Service and adds JSON (de)serialization.
/// Screens and providers never import this class.
class ServiceModel extends Service {
  const ServiceModel({
    required super.id,
    required super.name,
    required super.group,
    required super.price,
    required super.durationMinutes,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] as String?) ?? '',
      group: (json['group'] as String?) ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ??
          (json['durationMinutes'] as num?)?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group,
        'price': price,
        'duration_minutes': durationMinutes,
      };
}
