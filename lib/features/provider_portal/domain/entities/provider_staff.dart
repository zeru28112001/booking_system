/// Domain entity representing a shop staff member.
class ProviderStaff {
  const ProviderStaff({
    required this.id,
    required this.name,
    required this.phone,
    required this.specialties,
    required this.isActive,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String phone;
  final List<String> specialties;
  final bool isActive;
  final String avatarUrl;
}
