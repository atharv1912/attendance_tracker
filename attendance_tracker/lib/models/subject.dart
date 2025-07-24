import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 0)
class Subject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  int attended;

  @HiveField(2)
  int missed;

  @HiveField(3)
  double? requiredAttendance; // null means use default

  Subject({
    required this.name,
    this.attended = 0,
    this.missed = 0,
    this.requiredAttendance,
  });

  double get percentage {
    if (attended + missed == 0) return 0;
    return (attended / (attended + missed)) * 100;
  }

  bool get isSafeToBunk {
    if (attended + missed == 0) return true;
    final required = requiredAttendance ?? 75.0; // default 75%
    return percentage > required + 5; // 5% buffer
  }
}

// Generate adapter
// Run: flutter packages pub run build_runner build
