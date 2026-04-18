class ToastSession {
  final String id;
  final DateTime timestamp;
  final int participantCount;
  final double closestDistance;

  ToastSession({
    required this.id,
    required this.timestamp,
    required this.participantCount,
    required this.closestDistance,
  });
}
