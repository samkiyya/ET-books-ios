class Announcement {
  final int id;
  final String creatorId;
  final String title;
  final String status;
  final String reason;
  final String content;
  bool allowComments;
  final DateTime createdAt;
  final DateTime updatedAt;
  int likesCount;
  final int commentsCount;
  bool isLiked;

  Announcement(
      {required this.id,
      required this.creatorId,
      required this.title,
      required this.status,
      required this.reason,
      required this.content,
      required this.allowComments,
      required this.createdAt,
      required this.updatedAt,
      required this.likesCount,
      required this.commentsCount,
      this.isLiked = false});

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      creatorId: json['creatorId']?.toString() ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      reason: json['reason'] ?? '',
      content: json['content'] ?? '',
      allowComments: json['allowComments'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
    );
  }
}
