String formatTimeAgo(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inSeconds < 10) {
    return 'Vừa xong';
  }
  if (diff.inMinutes < 1) {
    return '${diff.inSeconds} giây trước';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes} phút trước';
  }

  // Định nghĩa helper để format giờ phút
  String _hourMinute(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Cùng ngày
  if (time.year == now.year && time.month == now.month && time.day == now.day) {
    return 'Hôm nay ${_hourMinute(time)}';
  }

  // Hôm qua
  final yesterday = now.subtract(const Duration(days: 1));
  if (time.year == yesterday.year &&
      time.month == yesterday.month &&
      time.day == yesterday.day) {
    return 'Hôm qua ${_hourMinute(time)}';
  }

  // Trong tuần (trong 7 ngày)
  if (diff.inDays < 7) {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    // DateTime.weekday: 1 = Mon, …, 7 = Sun
    final wd = weekdays[time.weekday - 1];
    return '$wd lúc ${_hourMinute(time)}';
  }

  // Ngoài phạm vi trên, hiện ngày tháng năm
  final d = time.day.toString().padLeft(2, '0');
  final mo = time.month.toString().padLeft(2, '0');
  final y = time.year;
  return '$d/$mo/$y ${_hourMinute(time)}';
}
