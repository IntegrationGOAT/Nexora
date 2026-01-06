import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/enums.dart';

/// Local storage service using SharedPreferences
class StorageService {
  static const String _keyStats = 'user_stats';
  static const String _keySessions = 'focus_sessions';
  static const String _keyThoughts = 'thought_entries';
  static const String _keyTasks = 'study_tasks';
  static const String _keyCurrentMentalState = 'current_mental_state';
  static const String _keyExamDate = 'exam_date';
  static const String _keyProcrastinationStart = 'procrastination_start';
  static const String _keyDailyFailures = 'daily_failures';
  static const String _keyLastFailureDate = 'last_failure_date';
  static const String _keyBurnoutMinutes = 'burnout_minutes';
  static const String _keyLastBurnoutCheck = 'last_burnout_check';
  static const String _keyReminders = 'reminders';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Stats
  Future<void> saveStats(UserStats stats) async {
    await _prefs.setString(_keyStats, jsonEncode(stats.toJson()));
  }

  UserStats getStats() {
    final String? statsJson = _prefs.getString(_keyStats);
    if (statsJson == null) {
      return UserStats();
    }
    return UserStats.fromJson(jsonDecode(statsJson));
  }

  // Focus Sessions
  Future<void> saveSessions(List<FocusSession> sessions) async {
    final List<String> sessionsJson = sessions.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs.setStringList(_keySessions, sessionsJson);
  }

  List<FocusSession> getSessions() {
    final List<String>? sessionsJson = _prefs.getStringList(_keySessions);
    if (sessionsJson == null) {
      return [];
    }
    return sessionsJson.map((s) => FocusSession.fromJson(jsonDecode(s))).toList();
  }

  Future<void> addSession(FocusSession session) async {
    final sessions = getSessions();
    sessions.add(session);
    await saveSessions(sessions);
  }

  // Thought Entries
  Future<void> saveThoughts(List<ThoughtEntry> thoughts) async {
    final List<String> thoughtsJson = thoughts.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_keyThoughts, thoughtsJson);
  }

  List<ThoughtEntry> getThoughts() {
    final List<String>? thoughtsJson = _prefs.getStringList(_keyThoughts);
    if (thoughtsJson == null) {
      return [];
    }
    return thoughtsJson.map((t) => ThoughtEntry.fromJson(jsonDecode(t))).toList();
  }

  Future<void> addThought(ThoughtEntry thought) async {
    final thoughts = getThoughts();
    thoughts.add(thought);
    await saveThoughts(thoughts);
  }

  // Study Tasks
  Future<void> saveTasks(List<StudyTask> tasks) async {
    final List<String> tasksJson = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_keyTasks, tasksJson);
  }

  List<StudyTask> getTasks() {
    final List<String>? tasksJson = _prefs.getStringList(_keyTasks);
    if (tasksJson == null) {
      return [];
    }
    return tasksJson.map((t) => StudyTask.fromJson(jsonDecode(t))).toList();
  }

  Future<void> addTask(StudyTask task) async {
    final tasks = getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> updateTask(StudyTask updatedTask) async {
    final tasks = getTasks();
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  // Current Mental State
  Future<void> setCurrentMentalState(MentalState state) async {
    await _prefs.setString(_keyCurrentMentalState, state.name);
  }

  MentalState getCurrentMentalState() {
    final String? stateName = _prefs.getString(_keyCurrentMentalState);
    if (stateName == null) {
      return MentalState.distracted;
    }
    return MentalState.values.firstWhere(
      (e) => e.name == stateName,
      orElse: () => MentalState.distracted,
    );
  }

  // Exam Date
  Future<void> setExamDate(DateTime? date) async {
    if (date == null) {
      await _prefs.remove(_keyExamDate);
    } else {
      await _prefs.setString(_keyExamDate, date.toIso8601String());
    }
  }

  DateTime? getExamDate() {
    final String? dateStr = _prefs.getString(_keyExamDate);
    if (dateStr == null) {
      return null;
    }
    return DateTime.parse(dateStr);
  }

  // Procrastination tracking
  Future<void> setProcrastinationStart(DateTime? time) async {
    if (time == null) {
      await _prefs.remove(_keyProcrastinationStart);
    } else {
      await _prefs.setString(_keyProcrastinationStart, time.toIso8601String());
    }
  }

  DateTime? getProcrastinationStart() {
    final String? timeStr = _prefs.getString(_keyProcrastinationStart);
    if (timeStr == null) {
      return null;
    }
    return DateTime.parse(timeStr);
  }

  // Daily failures
  Future<void> incrementDailyFailures() async {
    final today = DateTime.now();
    final lastFailureDate = getLastFailureDate();

    if (lastFailureDate == null || !_isSameDay(today, lastFailureDate)) {
      // New day, reset counter
      await _prefs.setInt(_keyDailyFailures, 1);
    } else {
      final current = _prefs.getInt(_keyDailyFailures) ?? 0;
      await _prefs.setInt(_keyDailyFailures, current + 1);
    }

    await _prefs.setString(_keyLastFailureDate, today.toIso8601String());
  }

  int getDailyFailures() {
    final today = DateTime.now();
    final lastFailureDate = getLastFailureDate();

    if (lastFailureDate == null || !_isSameDay(today, lastFailureDate)) {
      return 0;
    }

    return _prefs.getInt(_keyDailyFailures) ?? 0;
  }

  DateTime? getLastFailureDate() {
    final String? dateStr = _prefs.getString(_keyLastFailureDate);
    if (dateStr == null) {
      return null;
    }
    return DateTime.parse(dateStr);
  }

  // Burnout tracking
  Future<void> addBurnoutMinutes(int minutes) async {
    final today = DateTime.now();
    final lastCheck = getLastBurnoutCheck();

    if (lastCheck == null || !_isSameDay(today, lastCheck)) {
      // New day, reset
      await _prefs.setInt(_keyBurnoutMinutes, minutes);
    } else {
      final current = _prefs.getInt(_keyBurnoutMinutes) ?? 0;
      await _prefs.setInt(_keyBurnoutMinutes, current + minutes);
    }

    await _prefs.setString(_keyLastBurnoutCheck, today.toIso8601String());
  }

  int getTodayBurnoutMinutes() {
    final today = DateTime.now();
    final lastCheck = getLastBurnoutCheck();

    if (lastCheck == null || !_isSameDay(today, lastCheck)) {
      return 0;
    }

    return _prefs.getInt(_keyBurnoutMinutes) ?? 0;
  }

  DateTime? getLastBurnoutCheck() {
    final String? dateStr = _prefs.getString(_keyLastBurnoutCheck);
    if (dateStr == null) {
      return null;
    }
    return DateTime.parse(dateStr);
  }

  Future<void> resetBurnoutMinutes() async {
    await _prefs.setInt(_keyBurnoutMinutes, 0);
  }

  // Reminders
  Future<void> saveReminders(List<Map<String, dynamic>> reminders) async {
    final List<String> remindersJson = reminders.map((r) => jsonEncode(r)).toList();
    await _prefs.setStringList(_keyReminders, remindersJson);
  }

  List<Map<String, dynamic>> getReminders() {
    final List<String>? remindersJson = _prefs.getStringList(_keyReminders);
    if (remindersJson == null) {
      return [];
    }
    return remindersJson.map((r) => jsonDecode(r) as Map<String, dynamic>).toList();
  }

  // Helper
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Clear all data (hard reset)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

