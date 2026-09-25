/// Domain entity — the app's canonical shape of a service Category.
/// No JSON logic here. No HTTP imports.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.nameMm,
    required this.iconName,
  });

  final String id;
  final String name;
  final String? nameMm;

  /// Backend-safe icon key (e.g. 'plumbing'). A wire format cannot carry an
  /// IconData, so the widget layer resolves this key to an icon.
  final String iconName;

  String getLocalizedName(String langCode) {
    if ((langCode == 'my' || langCode == 'mm' || langCode.toLowerCase().contains('myanmar')) &&
        nameMm != null &&
        nameMm!.isNotEmpty) {
      return nameMm!;
    }
    return name;
  }

  @override
  String toString() => 'Category(id: $id, name: $name, nameMm: $nameMm)';
}
