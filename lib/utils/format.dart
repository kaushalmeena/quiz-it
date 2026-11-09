/// `1594` → `1,594`.
String formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// `50 s` or `1 m 32 s`.
String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return minutes == 0 ? '${seconds}s' : '${minutes}m ${seconds}s';
}

/// `0.784` → `78%`.
String formatPercent(double share) => '${(share * 100).round()}%';
