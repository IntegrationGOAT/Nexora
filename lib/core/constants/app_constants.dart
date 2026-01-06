/// App-wide constants
class AppConstants {
  // App info
  static const String appName = 'StudyBuddy';
  static const String tagline = 'Your smart study companion';


  // Timer constants
  static const int defaultFocusDuration = 25; // minutes
  static const int defaultBreakDuration = 5; // minutes
  static const int microBreakDuration = 2; // minutes
  static const int cooldownDuration = 10; // minutes

  // Session milestones (in seconds)
  static const List<int> hapticMilestones = [300, 600, 900, 1200, 1500]; // 5, 10, 15, 20, 25 min

  // Lockdown
  static const int exitLongPressDuration = 3; // seconds
  static const int maxDailyFailures = 3;

  // Streak
  static const int streakGracePeriodHours = 36;

  // Music fade durations
  static const int musicFadeInDuration = 3; // seconds
  static const int musicFadeOutDuration = 2; // seconds

  // Burnout detection
  static const int burnoutThresholdMinutes = 180; // 3 hours continuous
  static const int forcedRestMinutes = 30;

  // Task decomposer
  static const int mandatoryStartTaskMinutes = 10;

  // Overthinking dump
  static const int maxThoughtLength = 500;

  // Procrastination tracking
  static const int procrastinationThresholdMinutes = 15;
}

