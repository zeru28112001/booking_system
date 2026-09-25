/// Domain entity — a staff member working at a shop-type provider.
/// No JSON or HTTP logic here.
class Staff {
  const Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.rating,
    required this.isAvailableToday,
    this.avatarUrl,
    this.specialties = const [],
    this.servicePrices = const {},
    this.offDays = const [],
    this.shiftStartTime,
    this.shiftEndTime,
  });

  final String id;
  final String name;
  final String role; // e.g. "Senior Hair Stylist", "Nail Technician"
  final double rating;
  final bool isAvailableToday;
  final String? avatarUrl;
  final List<String> specialties;
  final Map<String, int> servicePrices; // Service name -> Custom price mapping
  final List<String> offDays;
  final String? shiftStartTime;
  final String? shiftEndTime;

  @override
  String toString() => 'Staff(id: $id, name: $name, role: $role)';
}
