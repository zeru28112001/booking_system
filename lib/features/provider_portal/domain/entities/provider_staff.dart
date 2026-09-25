/// Domain entity representing a shop staff member.
class ProviderStaff {
  const ProviderStaff({
    required this.id,
    required this.name,
    required this.phone,
    required this.specialties,
    this.servicePrices = const {},
    required this.isActive,
    required this.avatarUrl,
    this.offDays = const [],
    this.shiftStartTime,
    this.shiftEndTime,
  });

  final String id;
  final String name;
  final String phone;
  final List<String> specialties;
  final Map<String, int> servicePrices;
  final bool isActive;
  final String avatarUrl;
  final List<String> offDays;
  final String? shiftStartTime;
  final String? shiftEndTime;
}
