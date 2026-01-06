import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/enums.dart';
import '../../core/models/models.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/streak_service.dart';
import '../../core/services/timer_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/constants/app_constants.dart';
import '../../main.dart';
import '../../widgets/pressure_ring.dart';
import '../session_complete/session_complete_screen.dart';

class FocusSessionScreen extends StatefulWidget {
  final StorageService storage;
  final StreakService streakService;
  final MentalState mentalState;
  final int durationMinutes;
  final String? subject;
  final String? topic;

  const FocusSessionScreen({
    super.key,
    required this.storage,
    required this.streakService,
    required this.mentalState,
    required this.durationMinutes,
    this.subject,
    this.topic,
  });

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with TickerProviderStateMixin {

  late TimerService _timerService;
  late DateTime _sessionStartTime;
  late AnimationController _pulseController;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  bool _isLongPressing = false;
  int _longPressProgress = 0;
  Timer? _longPressTimer;

  String _motivationalMessage = '';
  bool _showMotivation = false;
  Timer? _motivationTimer;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    _sessionStartTime = DateTime.now();
    _timerService = TimerService();

    // Start timer
    _timerService.startTimer(
      widget.durationMinutes,
      onTick: _onTimerTick,
      onComplete: _onSessionComplete,
    );

    // Pulse animation for pressure effect
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (2000 / widget.mentalState.animationSpeed).toInt(),
      ),
    )..repeat(reverse: true);

    // Breathing animation for background with realistic inhale/exhale
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // 5 seconds full cycle
    )..repeat();

    // Custom curve for realistic breathing: slower inhale, faster exhale
    _breathingAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: const Interval(
          0.0, 1.0,
          curve: _BreathingCurve(), // Custom breathing curve
        ),
      ),
    );

    // Set immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    HapticService.success();

    // Start motivational feedback timer
    _startMotivationalFeedback();
  }

  void _startMotivationalFeedback() {
    // Show first message after 1 minute, then every 1 minute
    _motivationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _showRandomMotivation();
      }
    });
  }

  void _showRandomMotivation() {
    final messages = [
      'Keep it up! 🔥',
      'You\'re doing great! 💪',
      'Stay focused! 🎯',
      'Almost there! ⭐',
      'You got this! 🚀',
      'Crushing it! 💯',
      'Keep going! 🌟',
      'Stay strong! 💪',
      'Nice work! ✨',
      'Keep pushing! 🔥',
      'You\'re unstoppable! ⚡',
      'Great progress! 📈',
      'Stay locked in! 🎯',
      'Amazing effort! 🏆',
      'Keep the momentum! 🌊',
    ];

    setState(() {
      _motivationalMessage = messages[DateTime.now().millisecond % messages.length];
      _showMotivation = true;
    });

    // Hide message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showMotivation = false;
        });
      }
    });
  }

  void _onTimerTick() {
    final elapsed = _timerService.elapsedSeconds;

    // Check for milestones
    if (AppConstants.hapticMilestones.contains(elapsed)) {
      HapticService.milestone();
    }
  }

  void _onSessionComplete() {
    _completeSession(forced: false);
  }

  void _completeSession({required bool forced}) async {
    // Calculate actual duration
    final actualMinutes = _timerService.elapsedSeconds ~/ 60;

    // Create session record
    final session = FocusSession(
      startTime: _sessionStartTime,
      endTime: DateTime.now(),
      plannedDurationMinutes: widget.durationMinutes,
      actualDurationMinutes: actualMinutes,
      mentalState: widget.mentalState.name,
      subject: widget.subject,
      topic: widget.topic,
      wasHonest: true, // Will be updated in completion screen
      result: forced ? 'forced' : 'completed',
      musicCategory: null,
      distractionCount: 0,
    );

    // Save session
    await widget.storage.addSession(session);

    // Update burnout tracking
    await widget.storage.addBurnoutMinutes(actualMinutes);

    // Reset procrastination timer
    await widget.storage.setProcrastinationStart(null);

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    HapticService.success();

    // Navigate to completion screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SessionCompleteScreen(
            storage: widget.storage,
            streakService: widget.streakService,
            session: session,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timerService.dispose();
    _pulseController.dispose();
    _breathingController.dispose();
    _longPressTimer?.cancel();
    _motivationTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable back button
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    // Always dark mode: Pure black with breathing effect
                    widget.mentalState.primaryColor.withOpacity(
                      _breathingAnimation.value * 0.5 // 0.1 to 0.5 opacity range
                    ),
                    const Color(0xFF000000), // Pure black
                  ],
                ),
              ),
              child: child,
            );
          },
          child: Stack(
            children: [
            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // Subject/Topic in black
                    if (widget.subject != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          widget.subject!,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (widget.topic != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          widget.topic!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 48),

                    // Pressure ring with timer
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated pressure ring
                          AnimatedBuilder(
                            animation: _timerService,
                            builder: (context, child) {
                              return PressureRing(
                                progress: _timerService.progress,
                                color: widget.mentalState.primaryColor,
                                pulseAnimation: _pulseController,
                              );
                            },
                          ),

                          // Timer display
                          AnimatedBuilder(
                            animation: _timerService,
                            builder: (context, child) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _timerService.formattedTime,
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w900,
                                      color: widget.mentalState.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Stay locked in',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Motivational message
                    AnimatedOpacity(
                      opacity: _showMotivation ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: widget.mentalState.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _motivationalMessage,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Exit button (bottom)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildExitButton(),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildExitButton() {
    return Center(
      child: GestureDetector(
        onLongPressStart: (_) => _startLongPress(),
        onLongPressEnd: (_) => _cancelLongPress(),
        child: Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.red.withOpacity(_isLongPressing ? 0.8 : 0.3),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Progress bar
              if (_isLongPressing)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    width: 200 * (_longPressProgress / 100),
                  ),
                ),

              // Text
              Center(
                child: Text(
                  _isLongPressing ? 'Hold to Exit...' : 'HOLD TO EXIT',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLongPress() {
    setState(() {
      _isLongPressing = true;
      _longPressProgress = 0;
    });

    HapticService.warning();

    _longPressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _longPressProgress += 1;
      });

      if (_longPressProgress >= 100) {
        _cancelLongPress();
        _exitSession();
      }
    });
  }

  void _cancelLongPress() {
    setState(() {
      _isLongPressing = false;
      _longPressProgress = 0;
    });
    _longPressTimer?.cancel();
  }

  void _exitSession() async {
    // Show exit confirmation
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exit Session?'),
        content: const Text(
          'Leaving early will log this as an incomplete session. '
          'This affects your discipline score.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Session'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit Anyway'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await widget.storage.incrementDailyFailures();
      _completeSession(forced: true);
    }
  }
}

/// Custom curve for realistic breathing animation
/// Simulates inhale (slow ease in) and exhale (faster ease out)
class _BreathingCurve extends Curve {
  const _BreathingCurve();

  @override
  double transformInternal(double t) {
    // Split into inhale (0.0 to 0.6) and exhale (0.6 to 1.0)
    if (t < 0.6) {
      // Inhale: slow and steady (60% of cycle)
      final inhaleProgress = t / 0.6;
      return Curves.easeInOut.transform(inhaleProgress);
    } else {
      // Exhale: faster and smoother (40% of cycle)
      final exhaleProgress = (t - 0.6) / 0.4;
      return 1.0 - Curves.easeIn.transform(exhaleProgress);
    }
  }
}
