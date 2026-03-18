import 'package:get/get.dart';
import 'package:fitness_app/features/home/services/app_api_service.dart';

class LeaderboardEntry {
  final String id;
  final String name;
  final String avatarUrl;
  final String gender; // 'men' | 'women' | 'all'
  final String badge;
  final bool isCurrentUser;
  int points;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.gender,
    required this.badge,
    this.isCurrentUser = false,
    required this.points,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json,
      {bool isCurrentUser = false}) {
    return LeaderboardEntry(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['user_name'] ?? json['username'] ?? 'User',
      avatarUrl: json['avatar'] ?? json['profile_image'] ?? json['image'] ?? '',
      gender: (json['gender'] ?? 'all').toString().toLowerCase(),
      badge: '🏅',
      isCurrentUser: isCurrentUser,
      points: _toInt(json['points'] ?? json['score'] ?? 0),
    );
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0);
}

class LeaderboardController extends GetxController {
  final _api = AppApiService();

  final RxList<LeaderboardEntry> entries = <LeaderboardEntry>[].obs;
  final RxBool isLoading = false.obs;

  // Fallback local data shown while loading or on error
  static final List<LeaderboardEntry> _fallback = [
    LeaderboardEntry(id: 'u1', name: 'Bryan', avatarUrl: 'https://i.pravatar.cc/120?img=12', gender: 'men', badge: '🏅', points: 43),
    LeaderboardEntry(id: 'u2', name: 'Meghan', avatarUrl: 'https://i.pravatar.cc/120?img=47', gender: 'women', badge: '🏅', points: 40),
    LeaderboardEntry(id: 'u3', name: 'Alex', avatarUrl: 'https://i.pravatar.cc/120?img=32', gender: 'women', badge: '🏅', points: 38),
    LeaderboardEntry(id: 'u4', name: 'Marsha Fisher', avatarUrl: 'https://i.pravatar.cc/120?img=24', gender: 'women', badge: '🏅', points: 36),
    LeaderboardEntry(id: 'u5', name: 'Juanita Cormier', avatarUrl: 'https://i.pravatar.cc/120?img=26', gender: 'women', badge: '🏅', points: 35),
    LeaderboardEntry(id: 'me', name: 'You', avatarUrl: 'https://i.pravatar.cc/120?img=47', gender: 'women', badge: '🏅', isCurrentUser: true, points: 34),
    LeaderboardEntry(id: 'u6', name: 'Tamara Schmidt', avatarUrl: 'https://i.pravatar.cc/120?img=52', gender: 'women', badge: '🏅', points: 33),
    LeaderboardEntry(id: 'u7', name: 'Ricardo Veum', avatarUrl: 'https://i.pravatar.cc/120?img=15', gender: 'men', badge: '🏅', points: 32),
    LeaderboardEntry(id: 'u8', name: 'Gary Sanford', avatarUrl: 'https://i.pravatar.cc/120?img=14', gender: 'men', badge: '🏅', points: 31),
  ];

  @override
  void onInit() {
    super.onInit();
    entries.assignAll(_fallback);
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    isLoading.value = true;
    try {
      final result = await _api.getLeaderboard();
      if (result['ok'] == true) {
        final data = result['data'];
        List<dynamic> list = [];
        if (data is Map) {
          list = data['data'] ?? data['leaderboard'] ?? data['users'] ?? [];
        } else if (data is List) {
          list = data;
        }
        if (list.isNotEmpty) {
          final parsed = list
              .whereType<Map<String, dynamic>>()
              .map((e) => LeaderboardEntry.fromJson(e))
              .toList();
          // Re-inject current user entry if backend doesn't mark it
          final meIdx = parsed.indexWhere((e) => e.isCurrentUser);
          if (meIdx == -1) {
            final localMe = entries.firstWhereOrNull((e) => e.isCurrentUser);
            if (localMe != null) parsed.add(localMe);
          }
          parsed.sort((a, b) => b.points.compareTo(a.points));
          entries.assignAll(parsed);
        }
      }
    } catch (_) {
      // keep fallback data
    } finally {
      isLoading.value = false;
    }
  }

  /// Award points to current user — called from HomeProfileController
  void syncCurrentUserPoints({required int points}) {
    final idx = entries.indexWhere((e) => e.isCurrentUser);
    if (idx == -1) return;
    entries[idx].points = points;
    entries.refresh();
  }

  List<LeaderboardEntry> filtered(String gender) {
    if (gender == 'all') return entries.toList();
    return entries.where((e) => e.gender == gender || e.isCurrentUser).toList();
  }
}
