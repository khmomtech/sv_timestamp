import 'package:intl/intl.dart';

class TimeService {
  static String prettyNow() {
    final now = DateTime.now();
    final fmt = DateFormat('hh:mm a | EEE, MMM d, yyyy');
    return fmt.format(now);
  }

  static String shortTime() {
    final now = DateTime.now();
    return DateFormat('hh:mm a').format(now);
  }
}
