import 'package:flutter/material.dart';

import 'package:fitness_app/layout/main_layout.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Notification',
      showAppBar: true,
      showBackButton: true,
      showBottomNav: false,
      currentIndex: 0,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth < 440
              ? constraints.maxWidth - 18
              : 440.0;

          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(9, 20, 9, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 14,
                            height: 14,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE9EDF3),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF6A7588),
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Mark all as read',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.settings_outlined, size: 20),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: cardWidth,
                          height: 155,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD9DEE5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    size: 7,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Invitation',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    '8h',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF8B92A1),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.more_horiz,
                                    size: 18,
                                    color: Color(0xFF8B92A1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 1,
                                height: 40,
                                color: const Color(0xFFD9DEE5),
                              ),
                              Transform.translate(
                                offset: const Offset(10, -37),
                                child: const Text(
                                  'Angelina invite you to join "Body Weight"\nroom',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF556074),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 155,
                                    height: 32,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        'Accept',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 155,
                                    height: 32,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFFD9DEE5),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        'Decline',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
