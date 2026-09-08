import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../domain/entities/weekly_schedule.dart';
import '../providers/provider_portal_provider.dart';

class ProviderScheduleScreen extends StatefulWidget {
  const ProviderScheduleScreen({super.key});

  @override
  State<ProviderScheduleScreen> createState() => _ProviderScheduleScreenState();
}

class _ProviderScheduleScreenState extends State<ProviderScheduleScreen> {
  List<DaySchedule> _days = [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final schedule = context.watch<ProviderPortalProvider>().schedule;
      if (schedule != null) {
        _days = List.from(schedule.days);
        _initialized = true;
      }
    }
  }

  Future<void> _selectTime(int index, bool isStart) async {
    final currentStr = isStart ? _days[index].startTime : _days[index].endTime;
    final parts = currentStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _days[index] = isStart
            ? _days[index].copyWith(startTime: formatted)
            : _days[index].copyWith(endTime: formatted);
      });
    }
  }

  Future<void> _save() async {
    final provider = context.read<ProviderPortalProvider>();
    final success = await provider.updateSchedule(WeeklySchedule(days: _days));
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weekly working hours updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ProviderPortalProvider>();

    if (provider.isLoading && !_initialized) {
      return const Scaffold(body: AppLoadingIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Weekly Working Hours'),
      ),
      body: _days.isEmpty
          ? const Center(child: Text('No schedule configured'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set your business open days and working hours for each day of the week.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _days.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final day = _days[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceMd,
                            vertical: AppConstants.spaceSm,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 90,
                                child: Text(
                                  day.dayName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Switch(
                                value: day.isOpen,
                                activeThumbColor: AppTheme.primary,
                                onChanged: (val) {
                                  setState(() {
                                    _days[index] = day.copyWith(isOpen: val);
                                  });
                                },
                              ),
                              const Spacer(),
                              if (day.isOpen) ...[
                                InkWell(
                                  onTap: () => _selectTime(index, true),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppTheme.divider),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(day.startTime, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Text('–'),
                                ),
                                InkWell(
                                  onTap: () => _selectTime(index, false),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppTheme.divider),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(day.endTime, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  'OFF DAY',
                                  style: TextStyle(
                                    color: AppTheme.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceXl),
                  AppButton(
                    label: 'Save Weekly Schedule',
                    icon: Icons.check_rounded,
                    isLoading: provider.isSaving,
                    onPressed: provider.isSaving ? null : _save,
                  ),
                ],
              ),
            ),
    );
  }
}
