import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateFilterNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setDate(DateTime? date) => state = date;
  void clear() => state = null;
}

final dateFilterProvider = NotifierProvider<DateFilterNotifier, DateTime?>(
  DateFilterNotifier.new,
);
