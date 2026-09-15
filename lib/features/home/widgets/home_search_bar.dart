import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key, required this.hint});

  final String hint;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.push('/search?q=${Uri.encodeComponent(query.trim())}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusPill),
        border: Border.all(color: AppTheme.divider, width: 1.5),
      ),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onSubmitted: _onSearch,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHint,
              ),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppTheme.textHint),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, size: 20, color: AppTheme.primary),
            onPressed: () => _onSearch(_controller.text),
            tooltip: 'Search',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 12),
        ),
      ),
    );
  }
}
