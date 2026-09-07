import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../providers/provider_portal_provider.dart';
import '../widgets/service_form_sheet.dart';

class ProviderServicesScreen extends StatelessWidget {
  const ProviderServicesScreen({super.key});

  void _openSheet(BuildContext context, [dynamic service]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ServiceFormSheet(service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Manage Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Service',
            onPressed: () => _openSheet(context),
          ),
        ],
      ),
      body: Consumer<ProviderPortalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.services.isEmpty) {
            return const AppLoadingIndicator();
          }

          final services = provider.services;

          if (services.isEmpty) {
            return AppEmptyState(
              icon: Icons.design_services_outlined,
              title: 'No services added',
              subtitle: 'Add your shop services and variants to start accepting bookings.',
              actionLabel: 'Add First Service',
              onAction: () => _openSheet(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            itemCount: services.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: AppConstants.spaceSm),
            itemBuilder: (context, index) {
              final s = services[index];
              return Container(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                      ),
                      child: const Icon(Icons.content_cut_rounded, color: AppTheme.primary),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AppFormatters.currency(s.price)} · ${s.durationMinutes} mins',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (s.group.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Category: ${s.group}',
                              style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                      onPressed: () => _openSheet(context, s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                      onPressed: () {
                        provider.deleteService(s.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Service'),
      ),
    );
  }
}
