import 'package:flutter/material.dart';
import '../../core/models/enums.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/streak_service.dart';
import '../focus/focus_session_screen.dart';
import '../../widgets/glass_card.dart';

class MentalStateScreen extends StatefulWidget {
  final StorageService storage;
  final StreakService streakService;
  final MentalState initialState;

  const MentalStateScreen({
    super.key,
    required this.storage,
    required this.streakService,
    required this.initialState,
  });

  @override
  State<MentalStateScreen> createState() => _MentalStateScreenState();
}

class _MentalStateScreenState extends State<MentalStateScreen> {
  late MentalState _selectedState;
  int _customDuration = 0;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedState = widget.initialState;
    _customDuration = 25; // Start with empty/default
    _durationController.text = ''; // Empty text field initially
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Color _getDurationColor(int minutes) {
    if (minutes == 0) return Colors.grey; // Not set
    if (minutes <= 15) return const Color(0xFF10B981); // Green - quick
    if (minutes <= 30) return const Color(0xFF3B82F6); // Blue - standard
    if (minutes <= 60) return const Color(0xFF7C3AED); // Purple - solid
    if (minutes <= 120) return const Color(0xFFEF4444); // Red - intense
    if (minutes <= 300) return const Color(0xFFFF6B35); // Orange - marathon
    return const Color(0xFFDC2626); // Dark red - extreme
  }

  List<Color> _getDurationGradient(int minutes) {
    if (minutes == 0) return const [Colors.grey, Colors.grey];
    if (minutes <= 15) return const [Color(0xFF10B981), Color(0xFF059669)];
    if (minutes <= 30) return const [Color(0xFF3B82F6), Color(0xFF2563EB)];
    if (minutes <= 60) return const [Color(0xFF7C3AED), Color(0xFF9333EA)];
    if (minutes <= 120) return const [Color(0xFFEF4444), Color(0xFFDC2626)];
    if (minutes <= 300) return const [Color(0xFFFF6B35), Color(0xFFF59E0B)];
    return const [Color(0xFFDC2626), Color(0xFF991B1B)];
  }

  String _getDurationEmoji(int minutes) {
    if (minutes == 0) return '⏱️'; // Not set
    if (minutes <= 15) return '⚡'; // Quick burst
    if (minutes <= 30) return '🎯'; // Standard focus
    if (minutes <= 60) return '🔥'; // Solid session
    if (minutes <= 120) return '💪'; // Power session
    if (minutes <= 300) return '🚀'; // Marathon mode
    return '🏆'; // Ultra dedication
  }

  String _getDurationFeedback(int minutes) {
    if (minutes == 0) return 'Enter duration';
    if (minutes <= 15) return 'Quick Sprint';
    if (minutes <= 30) return 'Perfect Focus';
    if (minutes <= 60) return 'Solid Session';
    if (minutes <= 120) return 'Power Mode';
    if (minutes <= 300) return 'Marathon Session';
    return 'Ultra Marathon Mode 🔥';
  }

  String _getDurationWarning(int minutes) {
    if (minutes <= 60) return '';
    if (minutes <= 120) return 'Take breaks!';
    if (minutes <= 300) return '⚠️ Remember to rest!';
    return '⚠️ EXTREME! Take regular breaks!';
  }

  double _getSliderProgress(int minutes) {
    if (minutes == 0) return 0.0; // Not set
    if (minutes <= 60) {
      // 1-60 min: 0-60% of bar
      return ((minutes - 1) / 59 * 0.6).clamp(0.0, 0.6);
    } else if (minutes <= 300) {
      // 60-300 min: 60-90% of bar
      return (0.6 + ((minutes - 60) / 240 * 0.3)).clamp(0.6, 0.9);
    } else {
      // 300+ min: 90-98% of bar (capped to never overflow)
      double progress = 0.9 + ((minutes - 300) / 300 * 0.08);
      return progress.clamp(0.9, 0.98);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Session'),
        backgroundColor: _getDurationColor(_customDuration).withOpacity(0.1),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Duration selector
              _buildDurationSelector(),
              const SizedBox(height: 24),

              // Subject and topic
              _buildTaskInput(),
              const SizedBox(height: 32),

              // Distraction contract
              _buildDistractionContract(),
              const SizedBox(height: 32),

              // Start button
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Duration',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            // Text input for minutes
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter minutes (minimum 1)',
                hintText: 'e.g., 25, 60, 300...',
                prefixIcon: Icon(
                  Icons.timer_outlined,
                  color: _getDurationColor(_customDuration),
                ),
                suffixIcon: _customDuration > 0 ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _getDurationEmoji(_customDuration),
                    style: const TextStyle(fontSize: 24),
                  ),
                ) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _getDurationColor(_customDuration).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _getDurationColor(_customDuration),
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                final minutes = int.tryParse(value);
                if (minutes != null && minutes >= 1) {
                  setState(() {
                    _customDuration = minutes;
                  });
                } else if (value.isEmpty) {
                  setState(() {
                    _customDuration = 0;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Emoji feedback and duration type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getDurationGradient(_customDuration),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    _getDurationEmoji(_customDuration),
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDurationFeedback(_customDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_getDurationWarning(_customDuration).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _getDurationWarning(_customDuration),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Visual gradient slider (non-interactive, shows duration visually)
            Column(
              children: [
                // Gradient bar
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: _getDurationGradient(_customDuration),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Progress indicator - dynamic based on duration with proper capping
                      FractionallySizedBox(
                        widthFactor: _getSliderProgress(_customDuration),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Duration display with adaptive range labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '5m',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getDurationGradient(_customDuration),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getDurationColor(_customDuration).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getDurationEmoji(_customDuration),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _customDuration >= 60
                                    ? '${(_customDuration / 60).toStringAsFixed(1)}h'
                                    : '$_customDuration min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      '∞',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInput() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What will you study?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                hintText: 'e.g., Mathematics',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: 'Topic (Optional)',
                hintText: 'e.g., Calculus - Derivatives',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistractionContract() {
    return GlassCard(
      color: _selectedState.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.lock,
              size: 48,
              color: _selectedState.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'LOCKDOWN CONTRACT',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• No back button\n'
              '• No app switching\n'
              '• Exit requires long-press\n'
              '• Early exit = logged failure\n'
              '• Your focus, your rules',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: _startFocusSession,
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedState.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'LOCK IN & START',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _startFocusSession() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FocusSessionScreen(
          storage: widget.storage,
          streakService: widget.streakService,
          mentalState: _selectedState,
          durationMinutes: _customDuration,
          subject: _subjectController.text.trim().isEmpty
              ? null
              : _subjectController.text.trim(),
          topic: _topicController.text.trim().isEmpty
              ? null
              : _topicController.text.trim(),
        ),
      ),
    );
  }
}

