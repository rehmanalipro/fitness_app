import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/routes/app_routes.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showAppBar;
  final int currentIndex;
  final bool constrainBody;
  final double contentMaxWidth;

  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    this.showAppBar = false,
    this.currentIndex = 0,
    this.constrainBody = true,
    this.contentMaxWidth = 520,
  });

  @override
  Widget build(BuildContext context) {
    final content = constrainBody
        ? LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final width =
                  maxWidth < contentMaxWidth ? maxWidth : contentMaxWidth;
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  child: body,
                ),
              );
            },
          )
        : body;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Get.back(),
              ),
            )
          : null,
      body: SafeArea(
        top: false,
        bottom: false,
        child: content,
      ),
      bottomNavigationBar: _BottomNavBar(currentIndex: currentIndex),
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
                padding:
                    EdgeInsets.only(bottom: bottomInset, top: barTopPadding),
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
                  borderRadius:
                      BorderRadius.circular(centerButtonHeight / 2),
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
