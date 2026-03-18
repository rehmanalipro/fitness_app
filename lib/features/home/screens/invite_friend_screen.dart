import 'package:flutter/material.dart';

import 'package:fitness_app/core/utils/app_responsive.dart';
import 'package:fitness_app/features/home/widgets/user_profile_sheet.dart';
import 'package:fitness_app/layout/main_layout.dart';

const _kFriends = [
  {'id': 'f1', 'name': 'Marsha Fisher',    'handle': '@marsha.fit',   'img': 'https://i.pravatar.cc/100?img=24'},
  {'id': 'f2', 'name': 'Juanita Cormier',  'handle': '@juanita.c',    'img': 'https://i.pravatar.cc/100?img=26'},
  {'id': 'f3', 'name': 'Tamara Schmidt',   'handle': '@tamara.s',     'img': 'https://i.pravatar.cc/100?img=52'},
  {'id': 'f4', 'name': 'Ricardo Veum',     'handle': '@ricardo.v',    'img': 'https://i.pravatar.cc/100?img=15'},
  {'id': 'f5', 'name': 'Gary Sanford',     'handle': '@gary.san',     'img': 'https://i.pravatar.cc/100?img=14'},
  {'id': 'f6', 'name': 'Bryan Cole',       'handle': '@bryan.cole',   'img': 'https://i.pravatar.cc/100?img=12'},
];

class InviteFriendScreen extends StatelessWidget {
  const InviteFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentMaxWidth = AppResponsive.isDesktop(context)
        ? 720.0
        : (AppResponsive.isTablet(context) ? 560.0 : 390.0);

    return MainLayout(
      title: 'Invite a Friend',
      showAppBar: true,
      showBackButton: true,
      currentIndex: 4,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _kFriends.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final friend = _kFriends[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x15000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => showUserProfileSheet(
                                context,
                                userId: friend['id']!,
                                name: friend['name']!,
                                handle: friend['handle']!,
                                avatarUrl: friend['img'],
                              ),
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    friend['img']!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => showUserProfileSheet(
                                  context,
                                  userId: friend['id']!,
                                  name: friend['name']!,
                                  handle: friend['handle']!,
                                  avatarUrl: friend['img'],
                                ),
                                child: Text(
                                  friend['name']!,
                                  style: const TextStyle(
                                    fontSize: 27 / 2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 101,
                              height: 42,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  side: const BorderSide(color: Colors.black54),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Invite',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
  }
}
