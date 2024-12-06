class Comment {
  final int id;
  final int announcementId;
  final String userId;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.announcementId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      announcementId: json['announcementId'] is int
          ? json['announcementId']
          : int.parse(json['announcementId'].toString()),
      userId: json['userId']?.toString() ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
