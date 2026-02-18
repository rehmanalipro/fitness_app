import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/routes/app_routes.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final bool isHome;
  final bool showAppBar;
  final bool showBackButton;
  final bool showAvatar;
  final int currentIndex;
  final bool constrainBody;
  final double contentMaxWidth;

  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    this.isHome = false,
    this.showAppBar = false,
    this.showBackButton = false,
    this.showAvatar = false,
    this.currentIndex = 0,
    this.constrainBody = true,
    this.contentMaxWidth = 520,
  });

  @override
  Widget build(BuildContext context) {
    final bodyContent = constrainBody
        ? LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final width = maxWidth < contentMaxWidth
                  ? maxWidth
                  : contentMaxWidth;
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(width: width, child: body),
              );
            },
          )
        : body;

    if (!showAppBar || isHome) {
      return Scaffold(
        body: SafeArea(top: false, bottom: false, child: bodyContent),
        bottomNavigationBar: _BottomNavBar(currentIndex: currentIndex),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    const headerHeight = 220.0;
    final bodyTop = screenSize.height < 700 ? 120.0 : 127.0;
    // Manually building header to allow avatar and back button in the same space without affecting title position
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Container(
              height: headerHeight,
              width: double.infinity,
              color: Colors.black,
            ),
            _ManualHeader(
              title: title,
              showBackButton: showBackButton,
              showAvatar: _shouldShowAvatar(),
              onBackTap: _handleBackTap,
            ),
            Positioned.fill(
              top: bodyTop,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: bodyContent,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(currentIndex: currentIndex),
    );
  }

  bool _shouldShowAvatar() {
    if (showBackButton) return false;
    if (showAvatar) return true;
    if (currentIndex == 3 || currentIndex == 4) return true;

    final lowerTitle = title.toLowerCase();
    return lowerTitle == 'foryou' ||
        lowerTitle == 'for you' ||
        lowerTitle == 'explore' ||
        lowerTitle == 'chat';
  }

  void _handleBackTap() {
    if (Get.key.currentState?.canPop() == true) {
      Get.back();
      return;
    }
    Get.offNamed(AppRoutes.home);
  }
}

class _ManualHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final bool showAvatar;
  final VoidCallback onBackTap;

  const _ManualHeader({
    required this.title,
    required this.showBackButton,
    required this.showAvatar,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasBack = showBackButton;
    final hasAvatar = !hasBack && showAvatar;
    final left = hasBack ? 22.0 : 26.0;
    final top = hasBack ? 60.0 : 62.0;
    final size = hasBack ? 32.0 : 28.0;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth < 360 ? 22.0 : 24.0;

    return Stack(
      children: [
        if (hasBack)
          Positioned(
            top: top,
            left: left,
            width: size,
            height: size,
            child: _HeaderBackButton(onTap: onBackTap),
          ),
        if (hasAvatar)
          Positioned(
            top: top,
            left: left,
            width: size,
            height: size,
            child: _HeaderAvatar(size: size),
          ),
        Positioned(
          top: 60,
          left: 72,
          right: 72,
          height: 32,
          child: Center(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: titleFontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HeaderBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE2E6E9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF70757A),
          ),
        ),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  final double size;

  const _HeaderAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<HomeProfileController>()) {
      final profileController = Get.find<HomeProfileController>();
      return Obx(
        () => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD9D9D9), width: 0.5),
          ),
          child: CircleAvatar(
            radius: size / 2,
            backgroundImage: profileController.avatarProvider,
            backgroundColor: const Color(0xFFEAEAEA),
            child: profileController.avatarProvider == null
                ? const Icon(Icons.person, size: 14, color: Colors.black54)
                : null,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD9D9D9), width: 0.5),
      ),
      child: const CircleAvatar(
        radius: 14,
        backgroundColor: Color(0xFFEAEAEA),
        child: Icon(Icons.person, size: 14, color: Colors.black54),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 70.0;
    const barTopPadding = 8.0;
    const centerButtonWidth = 58.5;
    const centerButtonHeight = 60.0;
    const centerButtonBorder = 2.0;
    const activeColor = Colors.black;
    const inactiveColor = Color(0xFFCFCFCF);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final available = totalWidth - centerButtonWidth;
        final itemWidth = (available / 6).clamp(48.0, 80.0);
        final iconSize = itemWidth >= 64 ? 26.0 : 24.0;
        final labelFontSize = itemWidth >= 64 ? 12.0 : 10.0;

        return SizedBox(
          height: barHeight + bottomInset,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: barHeight + bottomInset,
                padding: EdgeInsets.only(
                  bottom: bottomInset,
                  top: barTopPadding,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _NavItem(
                      width: itemWidth,
                      label: 'Home',
                      icon: Icons.home,
                      isActive: currentIndex == 0,
                      onTap: () => _goTo(AppRoutes.home, 0),
                      iconSize: iconSize,
                      fontSize: labelFontSize,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    _NavItem(
                      width: itemWidth,
                      label: 'Food Log',
                      icon: Icons.restaurant_menu,
                      isActive: currentIndex == 1,
                      onTap: () => _goTo(AppRoutes.foodLog, 1),
                      iconSize: iconSize,
                      fontSize: labelFontSize,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    _NavItem(
                      width: itemWidth,
                      label: 'Challenges',
                      icon: Icons.fitness_center,
                      isActive: currentIndex == 2,
                      onTap: () => _goTo(AppRoutes.challenges, 2),
                      iconSize: iconSize,
                      fontSize: labelFontSize,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    SizedBox(width: centerButtonWidth),
                    _NavItem(
                      width: itemWidth,
                      label: 'Leaderboard',
                      icon: Icons.bar_chart,
                      isActive: currentIndex == 3,
                      onTap: () => _goTo(AppRoutes.leaderboard, 3),
                      iconSize: iconSize,
                      fontSize: labelFontSize,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    _NavItem(
                      width: itemWidth,
                      label: 'Guides',
                      icon: Icons.menu_book,
                      isActive: currentIndex == 4,
                      onTap: () => _goTo(AppRoutes.guides, 4),
                      iconSize: iconSize,
                      fontSize: labelFontSize,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    _NavItem(
                      width: itemWidth,
                      label: 'Settings',
                      icon: Icons.settings,
                      isActive: currentIndex == 5,
                      onTap: () => _goTo(AppRoutes.settings, 5),
                      iconSize: iconSize,
                      fontSize: labelFontSize,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: InkWell(
                  onTap: () => Get.toNamed(AppRoutes.addAction),
                  borderRadius: BorderRadius.circular(centerButtonHeight / 2),
                  child: Container(
                    width: centerButtonWidth,
                    height: centerButtonHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE6E6E6),
                        width: centerButtonBorder,
                      ),
                    ),
                    child: const Icon(Icons.add, size: 26),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goTo(String route, int index) {
    if (currentIndex == index) return;
    Get.offNamed(route);
  }
}

class _NavItem extends StatelessWidget {
  final double width;
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final double iconSize;
  final double fontSize;
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.width,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.iconSize,
    required this.fontSize,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}
