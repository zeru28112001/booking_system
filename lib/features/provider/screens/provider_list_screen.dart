import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../providers/provider_list_provider.dart';
import '../widgets/provider_card.dart';
import '../widgets/sort_filter_bar.dart';

/// Phase 3 — providers in one category, with client-side sorting.
class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  @override
  void initState() {
    super.initState();
    // Deferring keeps notifyListeners out of the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProviderListProvider>().fetchProviders(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          widget.categoryName.isNotEmpty ? widget.categoryName : 'Providers',
        ),
      ),
      body: Consumer<ProviderListProvider>(
        builder: (context, list, _) {
          if (list.isLoading) return const AppLoadingIndicator();

          if (list.error != null) {
            return AppErrorState(
              message: list.error!,
              onRetry: () => context
                  .read<ProviderListProvider>()
                  .fetchProviders(widget.categoryId),
            );
          }

          final providers = list.sortedProviders;

          if (providers.isEmpty) {
            return AppEmptyState(
              icon: Icons.storefront_outlined,
              title: 'No providers found',
              subtitle:
                  'We are still onboarding local pros in ${widget.categoryName}. '
                  'Check back soon.',
              actionLabel: 'Back to categories',
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
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  itemCount: providers.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppConstants.spaceMd),
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    return ProviderCard(
                      provider: provider,
                      onTap: () => context.push(
                        '/provider/${provider.id}'
                        '?name=${Uri.encodeComponent(provider.name)}',
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
