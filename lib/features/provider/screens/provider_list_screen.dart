import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/skeletons/provider_card_skeleton.dart';
import '../../../core/widgets/animations/staggered_entrance.dart';
import '../../../core/widgets/animations/app_scale_button.dart';
import 'dart:async';
import '../providers/provider_list_provider.dart';
import '../widgets/provider_card.dart';
import '../widgets/sort_filter_bar.dart';
import '../../../core/providers/location_provider.dart';

/// Phase 3 — providers in one category, with client-side sorting and animations.
class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.searchQuery,
  });

  final String? categoryId;
  final String? categoryName;
  final String? searchQuery;

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  Future<void> _initFetch({String? newQuery}) async {
    final locationProvider = context.read<LocationProvider>();
    if (!mounted) return;
    
    context.read<ProviderListProvider>().fetchProviders(
      categoryId: widget.categoryId, 
      query: newQuery ?? _searchController.text,
      lat: locationProvider.activeLat, 
      lng: locationProvider.activeLng,
      isRefresh: true,
    );
  }

  Future<void> _loadNextPage() async {
    final listProvider = context.read<ProviderListProvider>();
    if (listProvider.isLoadingMore || !listProvider.hasMore) return;
    
    final locationProvider = context.read<LocationProvider>();
    if (!mounted) return;
    
    listProvider.fetchProviders(
      categoryId: widget.categoryId,
      query: _searchController.text,
      lat: locationProvider.activeLat,
      lng: locationProvider.activeLng,
      isRefresh: false,
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _initFetch();
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadNextPage();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initFetch();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: widget.searchQuery != null 
            ? TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search providers...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(128)),
                ),
                style: const TextStyle(fontSize: 18),
              )
            : Text(widget.categoryName != null && widget.categoryName!.isNotEmpty ? widget.categoryName! : 'Providers'),
      ),
      body: Consumer<ProviderListProvider>(
        builder: (context, list, _) {
          if (list.isLoading) {
            return ListView.separated(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              itemCount: 6,
              separatorBuilder: (context, index) => const SizedBox(height: AppConstants.spaceMd),
              itemBuilder: (context, index) => const ProviderCardSkeleton(),
            );
          }

          if (list.error != null) {
            return AppErrorState(
              message: list.error!,
              onRetry: _initFetch,
            );
          }

          final providers = list.sortedProviders;

          if (providers.isEmpty) {
            return AppEmptyState(
              icon: Icons.storefront_outlined,
              title: 'No providers found',
              subtitle: widget.searchQuery != null && widget.searchQuery!.isNotEmpty
                  ? 'No providers found matching "${widget.searchQuery}". Try a different keyword.'
                  : 'We are still onboarding local pros in ${widget.categoryName ?? 'this category'}. '
                    'Check back soon.',
              actionLabel: 'Back to home',
              onAction: () => context.go('/home'),
            );
          }

          return Column(
            children: [
              SortFilterBar(
                selected: list.sortOption,
                onSelected: (sort) =>
                    context.read<ProviderListProvider>().setSort(sort),
              ),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  itemCount: providers.length + (list.hasMore ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppConstants.spaceMd),
                  itemBuilder: (context, index) {
                    if (index == providers.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.spaceMd),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final provider = providers[index];
                    return StaggeredEntrance(
                      index: index,
                      child: AppScaleButton(
                        onTap: () => context.push(
                          '/provider/${provider.id}'
                          '?name=${Uri.encodeComponent(provider.name)}',
                        ),
                        child: ProviderCard(
                          provider: provider,
                          onTap: () => context.push(
                            '/provider/${provider.id}'
                            '?name=${Uri.encodeComponent(provider.name)}',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
