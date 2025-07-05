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
  if (diff.inDays < 1) {
    return '${diff.inHours} giờ trước';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} ngày trước';
  }

  // Định nghĩa helper để format giờ phút
  String _hourMinute(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Ngoài 7 ngày, hiển thị dd/MM/yyyy và giờ
  final d = time.day.toString().padLeft(2, '0');
  final mo = time.month.toString().padLeft(2, '0');
  final y = time.year;
  return '$d/$mo/$y ${_hourMinute(time)}';
}
