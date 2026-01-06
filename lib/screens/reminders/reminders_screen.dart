import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class ReminderItem {
  final String id;
  final String task;
  final DateTime reminderTime;
  bool isCompleted;
  bool isMarkedForDeletion;
  
  ReminderItem({
    required this.id,
    required this.task,
    required this.reminderTime,
    this.isCompleted = false,
    this.isMarkedForDeletion = false,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'task': task,
    'reminderTime': reminderTime.toIso8601String(),
    'isCompleted': isCompleted,
    'isMarkedForDeletion': isMarkedForDeletion,
  };
  
  factory ReminderItem.fromJson(Map<String, dynamic> json) => ReminderItem(
    id: json['id'] as String,
    task: json['task'] as String,
    reminderTime: DateTime.parse(json['reminderTime'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
    isMarkedForDeletion: json['isMarkedForDeletion'] as bool? ?? false,
  );
}

class RemindersScreen extends StatefulWidget {
  final StorageService storage;
  
  const RemindersScreen({
    super.key,
    required this.storage,
  });

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<ReminderItem> _reminders = [];
  
  @override
  void initState() {
    super.initState();
    _loadReminders();
  }
  
  void _loadReminders() {
    final remindersData = widget.storage.getReminders();
    setState(() {
      _reminders = remindersData
          .map((data) => ReminderItem.fromJson(data))
          .toList();
    });
  }
  
  void _saveReminders() {
    final remindersData = _reminders
        .map((reminder) => reminder.toJson())
        .toList();
    widget.storage.saveReminders(remindersData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Reminders list
            Expanded(
              child: _reminders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 80,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reminders yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add a reminder',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = _reminders[index];
                        return _buildReminderCard(reminder, index);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildReminderCard(ReminderItem reminder, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedOpacity(
        opacity: reminder.isMarkedForDeletion ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        onEnd: () {
          if (reminder.isMarkedForDeletion) {
            setState(() {
              _reminders.removeAt(index);
              _saveReminders();
            });
          }
        },
        child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: reminder.isCompleted,
                onChanged: (value) {
                  setState(() {
                    reminder.isCompleted = value ?? false;
                    _saveReminders();
                  });
                },
                activeColor: AppTheme.successGreen,
              ),
              
              // Task text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.task,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration: reminder.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                        color: reminder.isCompleted 
                            ? Colors.grey 
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.alarm,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatReminderTime(reminder.reminderTime),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteReminder(reminder, index),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
  
  String _formatReminderTime(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inMinutes < 60) {
      return 'In ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'In ${difference.inHours} hours';
    } else {
      return 'In ${difference.inDays} days';
    }
  }
  
  void _deleteReminder(ReminderItem reminder, int index) {
    setState(() {
      reminder.isMarkedForDeletion = true;
    });
  }
  
  void _showAddReminderDialog() {
    final taskController = TextEditingController();
    int reminderMinutes = 5;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reminder'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Task input
                TextField(
                  controller: taskController,
                  decoration: const InputDecoration(
                    labelText: 'What to do?',
                    hintText: 'e.g., Review math notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                
                // Reminder time input
                Row(
                  children: [
                    const Text('Remind me in:'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<int>(
                        value: reminderMinutes,
                        isExpanded: true,
                        items: [5, 10, 15, 30, 60, 120, 180, 360]
                            .map((min) => DropdownMenuItem(
                                  value: min,
                                  child: Text(
                                    min < 60 ? '$min min' : '${min ~/ 60} hr',
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            reminderMinutes = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final task = taskController.text.trim();
              if (task.isNotEmpty) {
                _addReminder(task, reminderMinutes);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _addReminder(String task, int minutes) {
    final reminder = ReminderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      task: task,
      reminderTime: DateTime.now().add(Duration(minutes: minutes)),
    );
    
    setState(() {
      _reminders.add(reminder);
      _saveReminders();
    });
    
    // Schedule notification
    _scheduleNotification(reminder);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for $minutes minutes from now'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
  
  void _scheduleNotification(ReminderItem reminder) {
    // TODO: Implement notification scheduling
    // This would require flutter_local_notifications package
    // For now, we'll just show a placeholder
  }
}

