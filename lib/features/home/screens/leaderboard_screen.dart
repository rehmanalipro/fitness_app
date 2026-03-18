import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:fitness_app/core/utils/app_responsive.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/features/home/controllers/leaderboard_controller.dart';
import 'package:fitness_app/layout/main_layout.dart';

enum _GenderFilter { all, men, women }

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  _GenderFilter _filter = _GenderFilter.all;
  late final LeaderboardController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<LeaderboardController>()
        ? Get.find<LeaderboardController>()
        : Get.put(LeaderboardController(), permanent: true);
    // Ensure current user points are synced on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final profileCtrl = Get.find<HomeProfileController>();
        _ctrl.syncCurrentUserPoints(points: profileCtrl.points.value);
      } catch (_) {}
    });
  }

  void _showUserDetail(LeaderboardEntry user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 44,
              backgroundImage: NetworkImage(user.avatarUrl),
              backgroundColor: const Color(0xFFEAEAEA),
            ),
            const SizedBox(height: 12),
            Text(
              '${user.name} ${user.badge}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Color(0xFF18B4B1), size: 18),
                const SizedBox(width: 4),
                Text(
                  '${user.points} pts',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18B4B1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!user.isCurrentUser)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    try {
                      final profileCtrl = Get.find<HomeProfileController>();
                      profileCtrl.addFollowing(SocialUser(
                        id: user.id,
                        name: user.name,
                        handle: '@${user.name.toLowerCase().replaceAll(' ', '_')}',
                        avatarUrl: user.avatarUrl,
                      ));
                      Get.snackbar(
                        'Following',
                        'You are now following ${user.name}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.black87,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    } catch (_) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Follow', style: TextStyle(color: Colors.white)),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final podiumMaxWidth = AppResponsive.isDesktop(context)
        ? 520.0
        : (AppResponsive.isTablet(context) ? 420.0 : 350.0);

    return MainLayout(
      title: 'Leaderboard',
      showAppBar: true,
      showAvatar: true,
      currentIndex: 3,
      body: Obx(() {
        final genderStr = _filter == _GenderFilter.men
            ? 'men'
            : _filter == _GenderFilter.women
                ? 'women'
                : 'all';
        final sorted = _ctrl.filtered(genderStr)
          ..sort((a, b) => b.points.compareTo(a.points));

        final top1 = sorted.isNotEmpty ? sorted[0] : null;
        final top2 = sorted.length > 1 ? sorted[1] : null;
        final top3 = sorted.length > 2 ? sorted[2] : null;
        final rest = sorted.length > 3 ? sorted.sublist(3) : <LeaderboardEntry>[];

        return Container(
          width: double.infinity,
          color: const Color(0xFFF5F5F5),
          child: RefreshIndicator(
            onRefresh: () => _ctrl.loadLeaderboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 16),
              child: Column(
                children: [
                  _FilterTabs(
                    selected: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: podiumMaxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (top2 != null)
                          _TopUserCard(
                            user: top2,
                            rank: 2,
                            avatarSize: 74,
                            pointsColor: const Color(0xFF18B4B1),
                            onTap: () => _showUserDetail(top2),
                          )
                        else
                          const SizedBox(width: 106),
                        const SizedBox(width: 6),
                        if (top1 != null)
                          _TopUserCard(
                            user: top1,
                            rank: 1,
                            avatarSize: 84,
                            pointsColor: const Color(0xFF18B4B1),
                            onTap: () => _showUserDetail(top1),
                          )
                        else
                          const SizedBox(width: 114),
                        const SizedBox(width: 6),
                        if (top3 != null)
                          _TopUserCard(
                            user: top3,
                            rank: 3,
                            avatarSize: 74,
                            pointsColor: const Color(0xFF18B4B1),
                            onTap: () => _showUserDetail(top3),
                          )
                        else
                          const SizedBox(width: 106),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 260),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F2EA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.separated(
                      itemCount: rest.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final user = rest[index];
                        return _RankRow(
                          user: user,
                          rank: index + 4,
                          onTap: () => _showUserDetail(user),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      }),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final _GenderFilter selected;
  final ValueChanged<_GenderFilter> onChanged;

  const _FilterTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final maxWidth = AppResponsive.isDesktop(context)
        ? 420.0
        : (AppResponsive.isTablet(context) ? 380.0 : 345.0);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          _FilterTabItem(label: 'All', selected: selected == _GenderFilter.all, onTap: () => onChanged(_GenderFilter.all)),
          _FilterTabItem(label: 'Men', selected: selected == _GenderFilter.men, onTap: () => onChanged(_GenderFilter.men)),
          _FilterTabItem(label: 'Women', selected: selected == _GenderFilter.women, onTap: () => onChanged(_GenderFilter.women)),
        ],
      ),
    );
  }
}

class _FilterTabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTabItem({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _TopUserCard extends StatelessWidget {
  final LeaderboardEntry user;
  final int rank;
  final double avatarSize;
  final Color pointsColor;
  final VoidCallback onTap;

  const _TopUserCard({
    required this.user,
    required this.rank,
    required this.avatarSize,
    required this.pointsColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 106,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: user.isCurrentUser ? const Color(0xFF18B4B1) : Colors.black,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      user.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFEAEAEA),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -8,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text('$rank',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${user.name} ${user.badge}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              '⭐ ${user.points} pts',
              style: TextStyle(fontSize: 12, color: pointsColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final LeaderboardEntry user;
  final int rank;
  final VoidCallback onTap;

  const _RankRow({required this.user, required this.rank, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = user.isCurrentUser;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser ? Colors.white : const Color(0xFF555555),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 10,
              backgroundImage: NetworkImage(user.avatarUrl),
              backgroundColor: const Color(0xFFEAEAEA),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${user.name} ${user.badge}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isCurrentUser ? Colors.white : const Color(0xFF333333),
                ),
              ),
            ),
            Text(
              '${user.points} pts',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isCurrentUser ? Colors.white : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
