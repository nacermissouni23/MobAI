import 'package:equatable/equatable.dart';

class Report extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String iconName;
  final bool isHighlighted;

  const Report({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.iconName = 'description',
    this.isHighlighted = false,
  });

  @override
  List<Object?> get props => [id, title, date];
}

enum LogCategory { all, stock, operation }

class LogEntry extends Equatable {
  final String id;
  final String time;
  final String timeAgo;
  final String category;
  final String userName;
  final String description;
  final String? referenceId;
  final String? referenceLabel;

  const LogEntry({
    required this.id,
    required this.time,
    required this.timeAgo,
    required this.category,
    required this.userName,
    required this.description,
    this.referenceId,
    this.referenceLabel,
  });

  @override
  List<Object?> get props => [id, time, category, userName];
}
