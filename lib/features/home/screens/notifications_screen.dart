import 'package:flutter/material.dart';

import 'package:fitness_app/features/home/services/app_api_service.dart';
import 'package:fitness_app/layout/main_layout.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AppApiService _apiService = AppApiService();
  bool _isLoading = true;
  bool _isBusy = false;
  int _unreadCount = 0;
  String? _error;
  List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _apiService.getNotifications(),
        _apiService.getUnreadNotificationsCount(),
      ]);

      final listResult = results[0];
      final unreadResult = results[1];

      if (listResult['ok'] != true) {
        setState(() {
          _error = 'Notifications load failed (${listResult['statusCode']})';
          _isLoading = false;
        });
        return;
      }

      final notificationData = _extractData(listResult['data']);
      final unreadData = _extractData(unreadResult['data']);

      final rawList =
          notificationData['notifications'] ?? notificationData['items'];
      final list = rawList is List ? rawList : <dynamic>[];

      final countValue = unreadData['unread_count'] ?? unreadData['count'] ?? 0;
      final unreadCount = countValue is num
          ? countValue.toInt()
          : int.tryParse(countValue.toString()) ?? 0;

      setState(() {
        _items = list
            .whereType<Map>()
            .map((e) {
              return e.map((key, value) => MapEntry(key.toString(), value));
            })
            .toList(growable: false);
        _unreadCount = unreadCount;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to connect to server';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    setState(() => _isBusy = true);
    try {
      await _apiService.markAllNotificationsAsRead();
      await _loadNotifications();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _markOneRead(String id) async {
    setState(() => _isBusy = true);
    try {
      await _apiService.markNotificationAsRead(id);
      await _loadNotifications();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Map<String, dynamic> _extractData(dynamic raw) {
    if (raw is! Map<String, dynamic>) return <String, dynamic>{};
    final nested = raw['data'];
    if (nested is Map<String, dynamic>) return nested;
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Notification',
      showAppBar: true,
      showBackButton: true,
      showBottomNav: false,
      currentIndex: 0,
      body: Container(
        width: double.infinity,
        color: const Color(0xFFF5F5F5),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
                  children: [
                    Row(
                      children: [
                        const Text(
                          'All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 9,
                          backgroundColor: const Color(0xFFE9EDF3),
                          child: Text(
                            '$_unreadCount',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6A7588),
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _isBusy ? null : _markAllRead,
                          child: const Text('Mark all as read'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text('No notifications found')),
                      ),
                    ..._items.map((item) {
                      final id = (item['id'] ?? '').toString();
                      final title =
                          (item['title'] ?? item['type'] ?? 'Notification')
                              .toString();
                      final body = (item['body'] ?? item['message'] ?? '-')
                          .toString();
                      final createdAt = (item['created_at'] ?? '').toString();
                      final isRead =
                          item['read'] == true || item['is_read'] == true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD9DEE5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (!isRead)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.black,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (createdAt.isNotEmpty)
                                  Text(
                                    createdAt,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF8B92A1),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              body,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF556074),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: (_isBusy || isRead || id.isEmpty)
                                    ? null
                                    : () => _markOneRead(id),
                                child: Text(isRead ? 'Read' : 'Mark as read'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}
