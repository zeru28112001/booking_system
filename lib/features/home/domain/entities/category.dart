/// Domain entity — the app's canonical shape of a service Category.
/// No JSON logic here. No HTTP imports.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconName,
  });

  final String id;
  final String name;

  /// Backend-safe icon key (e.g. 'plumbing'). A wire format cannot carry an
  /// IconData, so the widget layer resolves this key to an icon.
  final String iconName;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
