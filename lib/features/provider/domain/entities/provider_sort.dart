/// Sort options for the provider list filter bar.
/// Lives in domain so both the provider state and the filter widget can use it.
enum ProviderSort {
  recommended('Recommended'),
  topRated('Top Rated'),
  nearest('Nearest'),
  lowestPrice('Lowest Price');

  const ProviderSort(this.label);

  final String label;
}
