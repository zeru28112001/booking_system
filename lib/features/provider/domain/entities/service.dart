/// Domain entity — a bookable sub-service, grouped for the detail tabs.
/// No JSON logic here. No HTTP imports.
class Service {
  const Service({
    required this.id,
    required this.name,
    required this.group,
    required this.price,
    required this.durationMinutes,
  });

  final String id;
  final String name;

  /// Sub-service tab key, e.g. 'Hair' or 'Repair'.
  final String group;

  /// Price in MMK.
  final int price;
  final int durationMinutes;

  @override
  String toString() => 'Service(id: $id, name: $name, group: $group)';
}
