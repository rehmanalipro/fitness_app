import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import 'package:fitness_app/layout/main_layout.dart';
import 'package:fitness_app/features/home/controllers/home_profile_controller.dart';
import 'package:fitness_app/features/home/controllers/challenges_feed_controller.dart';
import 'package:fitness_app/features/home/services/app_api_service.dart';

class RandomChallengeScreen extends StatefulWidget {
  const RandomChallengeScreen({super.key});

  @override
  State<RandomChallengeScreen> createState() => _RandomChallengeScreenState();
}

class _RandomChallengeScreenState extends State<RandomChallengeScreen> {
  static final _rng = Random();
  final List<RandomChallenge> _queue = [];
  late RandomChallenge _currentChallenge;
  bool _isAdRunning = false;
  bool _isLoadingFromBackend = false;

  // Backend challenges converted to RandomChallenge
  final List<RandomChallenge> _backendChallenges = [];

  @override
  void initState() {
    super.initState();
    _prepareQueue();
    _currentChallenge = _pickNextChallenge();
    _loadBackendChallenges();
  }

  Future<void> _loadBackendChallenges() async {
    setState(() => _isLoadingFromBackend = true);
    try {
      // Try to get challenges from ChallengesFeedController first
      final feedCtrl = Get.isRegistered<ChallengesFeedController>()
          ? Get.find<ChallengesFeedController>()
          : Get.put(ChallengesFeedController(), permanent: true);

      await feedCtrl.loadPublicChallenges();

      final apiPosts = feedCtrl.publicPosts
          .where((p) => p.id.startsWith('api_'))
          .toList();

      if (apiPosts.isNotEmpty) {
        _backendChallenges.clear();
        for (final p in apiPosts) {
          _backendChallenges.add(RandomChallenge(
            id: p.id,
            name: p.title,
            subtitle: p.target,
            description: p.description,
            duration: '${p.target} min',
            progress: p.progress,
            timeLimitMinutes: 5,
            imageUrl: p.imageUrl?.isNotEmpty == true
                ? p.imageUrl!
                : 'https://images.pexels.com/photos/416778/pexels-photo-416778.jpeg?auto=compress&cs=tinysrgb&w=400',
          ));
        }
        // Replace queue with backend challenges
        _queue.clear();
        _queue.addAll(_backendChallenges);
        _queue.shuffle(_rng);
        if (mounted) {
          setState(() => _currentChallenge = _pickNextChallenge());
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingFromBackend = false);
  }

  void _prepareQueue() {
    _queue
      ..clear()
      ..addAll(_randomChallengePool);
    _queue.shuffle(_rng);
  }

  RandomChallenge _pickNextChallenge() {
    if (_queue.isEmpty) {
      _prepareQueue();
    }
    return _queue.removeLast();
  }

  void _startRandomChallenge() {
    setState(() {
      _currentChallenge = _pickNextChallenge();
    });
  }

  void _recordChallenge() {
    Get.to(
      () => ChallengeRecordingScreen(challenge: _currentChallenge),
    );
  }

  void _showAdPopup({
    required String title,
    required String message,
    required VoidCallback onSuccess,
  }) {
    if (_isAdRunning) return;
    setState(() => _isAdRunning = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              const Text('Watch the short ad to unlock this action'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await Future.delayed(const Duration(seconds: 2));
                  onSuccess();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Watch Ad'),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() => _isAdRunning = false);
      }
    });
  }

  void _discardChallenge() {
    _showAdPopup(
      title: 'Discard Challenge',
      message: 'Abandon the challenge and select a new one.',
      onSuccess: () {
        setState(() => _currentChallenge = _pickNextChallenge());
        Get.snackbar('Challenge Discarded', 'A fresh challenge is ready');
      },
    );
  }

  int get _totalTimeLimitMinutes => _currentChallenge.timeLimitMinutes;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 420 ? 12.0 : 24.0;

    return MainLayout(
      title: 'Challenges',
      showAppBar: true,
      showBackButton: true,
      currentIndex: 2,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                if (_isLoadingFromBackend)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: LinearProgressIndicator(color: Colors.black),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF191929), Color(0xFF20283C)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose Random Challenge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Stuck on what to do today? Spin the wheel and we will pick something that matches your next effort.',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAdRunning ? null : _startRandomChallenge,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Start Random Challenge',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCurrentChallengeCard(screenWidth),
                const SizedBox(height: 16),
                const Text(
                  'Challenge Description',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _currentChallenge.description,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 24),
                _ActionButtons(
                  onRecord: _recordChallenge,
                  onDiscard: _discardChallenge,
                  isBusy: _isAdRunning,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentChallengeCard(double screenWidth) {
    final progressPercent = _currentChallenge.progress.clamp(0, 1).toDouble();
    final totalMinutes = _totalTimeLimitMinutes;
    final imageSize = screenWidth < 360 ? 60.0 : 80.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _currentChallenge.imageUrl,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentChallenge.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentChallenge.subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.black54, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${totalMinutes.toString().padLeft(2, '0')}:00 min',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercent,
            backgroundColor: Colors.grey.shade200,
            color: Colors.blue.shade400,
            minHeight: 6,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_currentChallenge.progress * 100).round()}% complete',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                'Duration ${_currentChallenge.duration}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onRecord;
  final VoidCallback onDiscard;
  final bool isBusy;

  const _ActionButtons({
    Key? key,
    required this.onRecord,
    required this.onDiscard,
    required this.isBusy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isBusy ? null : onRecord,
            icon: const Icon(Icons.mic, size: 20),
            label: const Text('Record Challenge'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isBusy ? null : onDiscard,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.black.withOpacity(0.7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Discard'),
          ),
        ),
      ],
    );
  }
}

class RandomChallenge {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String duration;
  final double progress;
  final int timeLimitMinutes;
  final String imageUrl;

  const RandomChallenge({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.duration,
    required this.progress,
    required this.timeLimitMinutes,
    required this.imageUrl,
  });
}

const _randomChallengePool = [
  RandomChallenge(
    id: 'push',
    name: 'Push Up Surge',
    subtitle: '100 push ups over 3 sets',
    description:
        'Perform slow, controlled push ups to really feel the burn. Maintain a straight line from heels to shoulders.',
    duration: '5:00 min',
    progress: 0.45,
    timeLimitMinutes: 5,
    imageUrl:
        'https://images.pexels.com/photos/416778/pexels-photo-416778.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  RandomChallenge(
    id: 'plank',
    name: 'Plank Hold',
    subtitle: '4 rounds of 45 seconds',
    description:
        'Keep your hips high and brace your core. Each round focuses on breathing and posture.',
    duration: '6:00 min',
    progress: 0.32,
    timeLimitMinutes: 6,
    imageUrl:
        'https://images.pexels.com/photos/3837705/pexels-photo-3837705.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  RandomChallenge(
    id: 'squat',
    name: 'Jump Squat Pack',
    subtitle: '3 sets of 12 reps',
    description:
        'Explosive lower-body work. Land softly and let your knees track over toes.',
    duration: '7:00 min',
    progress: 0.61,
    timeLimitMinutes: 7,
    imageUrl:
        'https://images.pexels.com/photos/1552242/pexels-photo-1552242.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  RandomChallenge(
    id: 'lunge',
    name: 'Lunge Ladder',
    subtitle: 'Alternating forward lunges',
    description:
        'Focus on depth and posture. Reach at least 90 degrees on each knee bend.',
    duration: '8:00 min',
    progress: 0.58,
    timeLimitMinutes: 8,
    imageUrl:
        'https://images.pexels.com/photos/2372842/pexels-photo-2372842.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  RandomChallenge(
    id: 'burpee',
    name: 'Burpee Burner',
    subtitle: '5 rounds of 8 reps',
    description:
        'Use the full burpee cycle to elevate your heart rate. Soft landings, strong takeoffs.',
    duration: '9:00 min',
    progress: 0.23,
    timeLimitMinutes: 9,
    imageUrl:
        'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
];

class ChallengeRecordingScreen extends StatefulWidget {
  final RandomChallenge challenge;

  const ChallengeRecordingScreen({
    super.key,
    required this.challenge,
  });

  @override
  State<ChallengeRecordingScreen> createState() =>
      _ChallengeRecordingScreenState();
}

class _ChallengeRecordingScreenState extends State<ChallengeRecordingScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _isCameraReady = false;
  bool _isRecording = false;
  Timer? _recordingTimer;
  late int _remainingSeconds;

  int get _challengeSeconds => widget.challenge.timeLimitMinutes * 60;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _challengeSeconds;
    _setupCamera();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _setupCamera() async {
    try {
      final available = await availableCameras();
      if (!mounted || available.isEmpty) return;
      _cameras = available;
      await _initializeCamera(_cameraIndex);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCameraReady = false);
    }
  }

  Future<void> _initializeCamera(int index) async {
    final camera = _cameras.isNotEmpty ? _cameras[index] : null;
    if (camera == null) return;
    final oldController = _controller;
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await oldController?.dispose();
    try {
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _cameraIndex = index;
        _isCameraReady = true;
      });
    } catch (_) {
      controller.dispose();
      if (!mounted) return;
      setState(() => _isCameraReady = false);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final nextIndex = (_cameraIndex + 1) % _cameras.length;
    setState(() => _isCameraReady = false);
    await _initializeCamera(nextIndex);
  }

  Future<void> _startRecording() async {
    final controller = _controller;
    if (controller == null || !_isCameraReady || _isRecording) return;
    try {
      await controller.startVideoRecording();
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _remainingSeconds = _challengeSeconds;
      });
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (_remainingSeconds <= 1) {
          timer.cancel();
          setState(() => _remainingSeconds = 0);
          await _finishRecording(auto: true);
          return;
        }
        setState(() => _remainingSeconds -= 1);
      });
    } catch (_) {
      Get.snackbar('Recording failed', 'Unable to start video capture');
    }
  }

  Future<void> _finishRecording({bool auto = false}) async {
    final controller = _controller;
    if (controller == null || !_isRecording) return;
    try {
      final file = await controller.stopVideoRecording();
      _recordingTimer?.cancel();
      if (!mounted) return;
      setState(() => _isRecording = false);

      // Award points for completing challenge
      try {
        final profileCtrl = Get.find<HomeProfileController>();
        profileCtrl.addPoints(10);
      } catch (_) {}

      // Upload recorded video to backend as accepted challenge
      _uploadRecordedChallenge(file.path);

      final message =
          auto ? 'Challenge time completed' : 'Recording saved successfully';
      Get.snackbar('Challenge recorded', message);
      Get.back(result: file.path);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isRecording = false);
      Get.snackbar('Recording failed', 'Unable to stop video capture');
    }
  }

  Future<void> _uploadRecordedChallenge(String videoPath) async {
    try {
      final api = AppApiService();
      // Accept the challenge on backend using its real id
      await api.acceptChallenge(challengeId: widget.challenge.id);
      // Upload the recorded video as a challenge post
      await api.uploadChallengeWithMedia(
        title: widget.challenge.name,
        target: widget.challenge.subtitle,
        category: 'Random',
        fitnessLevel: 'All',
        description: widget.challenge.description,
        mediaFile: File(videoPath),
        isVideo: true,
      );
      // Also update progress to 100%
      final rawId = widget.challenge.id.replaceFirst(RegExp(r'^(api_|my_|public_)'), '');
      if (rawId.isNotEmpty) {
        await api.updateChallengeProgress(rawId, {'progress': 100, 'status': 'completed'});
      }
    } catch (_) {
      // Silent fail — points already awarded locally
    }
  }

  String _formattedRemaining() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _progress() {
    if (_challengeSeconds == 0) return 0;
    return (_challengeSeconds - _remainingSeconds) / _challengeSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Record ${widget.challenge.name}';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isCameraReady && _controller != null
                ? CameraPreview(_controller!)
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          Container(
            color: const Color(0xFF0F0F0F),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Remaining ${_formattedRemaining()} / ${widget.challenge.timeLimitMinutes} min',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progress(),
                  color: Colors.greenAccent,
                  backgroundColor: Colors.white24,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isRecording ? () => _finishRecording() : _startRecording,
                        icon: Icon(
                          _isRecording ? Icons.stop : Icons.videocam,
                          size: 20,
                        ),
                        label: Text(
                          _isRecording ? 'Stop' : 'Start recording',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isRecording ? Colors.red : Colors.white,
                          foregroundColor:
                              _isRecording ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_cameras.length > 1)
                      IconButton(
                        onPressed: _switchCamera,
                        color: Colors.white,
                        icon: const Icon(Icons.flip_camera_ios),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.challenge.subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
