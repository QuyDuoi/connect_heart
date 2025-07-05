class Certificate {
  final int eventId;
  final String certificateLink;
  final String eventTitle;
  final DateTime registeredAt;

  Certificate({
    required this.eventId,
    required this.certificateLink,
    required this.eventTitle,
    required this.registeredAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      eventId: json['event_id'],
      certificateLink: json['certificate_link'],
      eventTitle: json['event_title'],
      registeredAt: DateTime.parse(json['registered_at']),
    );
  }
}
