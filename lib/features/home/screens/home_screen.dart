import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/skeletons/category_grid_skeleton.dart';
import '../../../core/widgets/animations/staggered_entrance.dart';
import '../../../core/widgets/animations/app_scale_button.dart';
import '../domain/entities/category.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_tile.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/saved_locations_bottom_sheet.dart';
import '../../../core/providers/location_provider.dart';
import '../providers/home_provider.dart';

/// Phase 2 — Home & category discovery.
/// UI only: all data arrives through [HomeProvider].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onLogout, this.onViewBookings});

  /// Supplied by the composition root so this feature never imports
  /// features/auth — cross-feature wiring stays outside the feature.
  final VoidCallback? onLogout;

  /// Same rule for features/booking: main.dart owns the navigation.
  final VoidCallback? onViewBookings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Deferred: fetchCategories() notifies listeners synchronously, which is
    // illegal while this widget's first frame is still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().fetchCategories();
    });
  }

  void _openCategory(Category category) {
    final name = Uri.encodeComponent(category.name);
    context.push('/category/${category.id}?name=$name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const _LocationTitle(),
        actions: [
          if (widget.onViewBookings != null)
            IconButton(
              icon: const Icon(Icons.event_note_outlined),
              tooltip: 'My Bookings',
              onPressed: widget.onViewBookings,
            ),
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: widget.onLogout,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeSearchBar(hint: 'Search services or providers'),
              const SizedBox(height: AppConstants.spaceMd),
              Consumer<HomeProvider>(
                builder: (context, home, _) {
                  return PromoBannerCarousel(
                    banners: home.banners,
                    onBannerTap: (banner) {
                      if (banner.targetCategoryId != null && banner.targetCategoryId!.isNotEmpty) {
                        final cat = home.categories.firstWhere(
                          (c) => c.id == banner.targetCategoryId,
                          orElse: () => Category(
                            id: banner.targetCategoryId!,
                            name: banner.title,
                            iconName: banner.iconName,
                          ),
                        );
                        _openCategory(cat);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: AppConstants.spaceLg),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categories',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Consumer<HomeProvider>(builder: _buildCategoryArea),
            ],
          ),
        ),
      ),
    );
  }

  /// loading | error | empty | data
  Widget _buildCategoryArea(
    BuildContext context,
    HomeProvider home,
    Widget? _,
  ) {
    if (home.isLoading) {
      return const CategoryGridSkeleton(itemCount: 8);
    }

    if (home.error != null) {
      return AppErrorState(
        message: home.error!,
        onRetry: () => context.read<HomeProvider>().fetchCategories(),
      );
    }

    if (home.categories.isEmpty) {
      return const AppEmptyState(
        icon: Icons.category_outlined,
        title: 'No categories yet',
        subtitle: 'Service categories will appear here once they are available.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: home.categories.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        mainAxisSpacing: AppConstants.spaceMd,
        crossAxisSpacing: AppConstants.spaceMd,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final category = home.categories[index];
        return StaggeredEntrance(
          index: index,
          child: AppScaleButton(
            onTap: () => _openCategory(category),
            child: CategoryTile(
              category: category,
              onTap: () => _openCategory(category),
            ),
          ),
        );
      },
    );
  }
}

class _LocationTitle extends StatelessWidget {
  const _LocationTitle();

  @override
  Widget build(BuildContext context) {
    final currentLocation = context.watch<LocationProvider>().currentLocationName ?? AppConstants.defaultLocation;
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
          ),
          builder: (_) => const SavedLocationsBottomSheet(),
        );
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 18,
          color: AppTheme.primary,
        ),
        const SizedBox(width: AppConstants.spaceXs),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current location',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                currentLocation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.expand_more_rounded,
          size: 18,
          color: AppTheme.textSecondary,
        ),
          ],
        ),
      ),
    );
  }
}
