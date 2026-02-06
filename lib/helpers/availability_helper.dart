import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Utility class for managing user availability status
class AvailabilityHelper {
  /// Determine if a user is online based on current time and shift data
  ///
  /// Returns true if:
  /// - Today's date matches the shift date
  /// - Current time (in the given timezone) is between start_time and end_time
  ///
  /// Otherwise returns false
  static bool isUserOnline({
    required DateTime shiftDate,
    required String startTime, // Format: "HH:mm" (24-hour)
    required String endTime, // Format: "HH:mm" (24-hour)
    required String timezone, // e.g., "Asia/Karachi", "UTC", "America/New_York"
  }) {
    try {
      // Get current time in the specified timezone
      final location = tz.getLocation(timezone);
      final currentTimeInTz = tz.TZDateTime.now(location);

      // Check if today matches the shift date
      final shiftDateInTz =
          tz.TZDateTime.from(shiftDate.toUtc(), location).toLocal();
      final isDateMatch = currentTimeInTz.year == shiftDateInTz.year &&
          currentTimeInTz.month == shiftDateInTz.month &&
          currentTimeInTz.day == shiftDateInTz.day;

      if (!isDateMatch) {
        return false;
      }

      // Convert time strings to minutes since midnight
      final startMinutes = _timeStringToMinutes(startTime);
      final endMinutes = _timeStringToMinutes(endTime);
      final currentMinutes =
          currentTimeInTz.hour * 60 + currentTimeInTz.minute;

      // Check if current time is between start and end time
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } catch (e) {
      print('Error checking user online status: $e');
      return false;
    }
  }

  /// Get user availability status as a string
  static String getUserStatus({
    required DateTime shiftDate,
    required String startTime,
    required String endTime,
    required String timezone,
  }) {
    return isUserOnline(
      shiftDate: shiftDate,
      startTime: startTime,
      endTime: endTime,
      timezone: timezone,
    )
        ? 'Online'
        : 'Offline';
  }

  /// Convert time string "HH:mm" to minutes since midnight
  static int _timeStringToMinutes(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return 0;
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      return hours * 60 + minutes;
    } catch (e) {
      print('Error parsing time string: $e');
      return 0;
    }
  }

  /// Format time for display
  static String formatTime(String time) {
    try {
      final format = DateFormat('HH:mm');
      final parsedTime = format.parse(time);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  /// Check if shift time has passed
  static bool hasShiftPassed({
    required DateTime shiftDate,
    required String endTime,
    required String timezone,
  }) {
    try {
      final location = tz.getLocation(timezone);
      final currentTimeInTz = tz.TZDateTime.now(location);

      // Get shift end date and time
      final endMinutes = _timeStringToMinutes(endTime);
      final shiftEndDateTime = shiftDate.add(Duration(
        hours: endMinutes ~/ 60,
        minutes: endMinutes % 60,
      ));

      return currentTimeInTz.isAfter(shiftEndDateTime);
    } catch (e) {
      print('Error checking if shift passed: $e');
      return false;
    }
  }

  /// Get remaining time in shift (returns null if shift has ended)
  static Duration? getRemainingShiftTime({
    required DateTime shiftDate,
    required String endTime,
    required String timezone,
  }) {
    try {
      final location = tz.getLocation(timezone);
      final currentTimeInTz = tz.TZDateTime.now(location);

      // Get shift end date and time
      final endMinutes = _timeStringToMinutes(endTime);
      final shiftEndDateTime = shiftDate.add(Duration(
        hours: endMinutes ~/ 60,
        minutes: endMinutes % 60,
      ));

      if (currentTimeInTz.isAfter(shiftEndDateTime)) {
        return null; // Shift has ended
      }

      return shiftEndDateTime.difference(currentTimeInTz);
    } catch (e) {
      print('Error calculating remaining shift time: $e');
      return null;
    }
  }

  /// Get default timezone
  static String getDefaultTimezone() {
    // Returns the system timezone, or 'UTC' if unable to determine
    try {
      return tz.local.name;
    } catch (e) {
      return 'UTC';
    }
  }

  /// Get all available timezones
  static List<String> getAvailableTimezones() {
    return tz.timeZoneDatabase.locations.keys.toList();
  }

  /// Validate time format (HH:mm)
  static bool isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  /// Validate timezone
  static bool isValidTimezone(String timezone) {
    try {
      tz.getLocation(timezone);
      return true;
    } catch (e) {
      return false;
    }
  }
}
