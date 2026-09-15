import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../admin_portal/data/models/promo_banner_model.dart';

/// Single Promo Banner strip widget.
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.local_offer_rounded,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: hasImage
              ? null
              : const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: hasImage ? Colors.black : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background image
            if (hasImage)
              Positioned.fill(
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
            // Dark scrim over image so text is readable
            if (hasImage)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withAlpha(160),
                        Colors.black.withAlpha(60),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            // Content row
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.onPrimary.withAlpha(40),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Icon(icon, size: 22, color: AppTheme.onPrimary),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppConstants.spaceXs),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.onPrimary.withAlpha(220),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dynamic auto-scrolling 5s Banner Carousel widget for Home Screen.
class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
  });

  final List<PromoBannerModel> banners;
  final Function(PromoBannerModel)? onBannerTap;

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  static const int _kInfiniteBase = 10000;
  late PageController _pageController;
  Timer? _timer;
  int _currentVirtualIndex = 0;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initController();
    _startAutoSlideTimer();
  }

  void _initController() {
    final count = widget.banners.length;
    _currentVirtualIndex = count > 0 ? _kInfiniteBase * count : 0;
    _currentPageIndex = 0;
    _pageController = PageController(initialPage: _currentVirtualIndex);
  }

  void _startAutoSlideTimer() {
    _timer?.cancel();
    if (widget.banners.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.banners.isEmpty || !_pageController.hasClients) return;
      _currentVirtualIndex++;
      _pageController.animateToPage(
        _currentVirtualIndex,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didUpdateWidget(covariant PromoBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _timer?.cancel();
      _pageController.dispose();
      _initController();
      _startAutoSlideTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  IconData _resolveIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'spa':
        return Icons.spa_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'content_cut':
        return Icons.content_cut_rounded;
      case 'brush':
        return Icons.brush_rounded;
      case 'home_repair_service':
        return Icons.home_repair_service_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'local_offer':
      default:
        return Icons.local_offer_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const PromoBanner(
        title: '20% off your first booking',
        subtitle: "New to Zeru' Booking? Try a top-rated local pro.",
      );
    }

    final bannerCount = widget.banners.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 100,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification && notification.dragDetails != null) {
                // User started dragging manually, temporarily pause auto timer
                _timer?.cancel();
              } else if (notification is ScrollEndNotification) {
                // User completed drag, restart 5s auto slide timer
                _startAutoSlideTimer();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (virtualIndex) {
                setState(() {
                  _currentVirtualIndex = virtualIndex;
                  _currentPageIndex = virtualIndex % bannerCount;
                });
              },
              itemBuilder: (context, index) {
                final realIndex = index % bannerCount;
                final banner = widget.banners[realIndex];
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double scale = 1.0;
                    double opacity = 1.0;
                    if (_pageController.position.haveDimensions) {
                      final page = _pageController.page ?? _currentVirtualIndex.toDouble();
                      final diff = (page - index).abs();
                      scale = (1 - (diff * 0.06)).clamp(0.94, 1.0);
                      opacity = (1 - (diff * 0.25)).clamp(0.75, 1.0);
                    } else {
                      scale = (index == _currentVirtualIndex) ? 1.0 : 0.94;
                      opacity = (index == _currentVirtualIndex) ? 1.0 : 0.75;
                    }
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: PromoBanner(
                      title: banner.title,
                      subtitle: banner.subtitle,
                      icon: _resolveIcon(banner.iconName),
                      imageUrl: banner.imageUrl,
                      onTap: () => widget.onBannerTap?.call(banner),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (bannerCount > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(bannerCount, (index) {
              final isSelected = index == _currentPageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary.withAlpha(60),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withAlpha(80),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
