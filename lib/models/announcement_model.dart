class Announcement {
  final int id;
  final String creatorId;
  final String title;
  final String status;
  final String reason;
  final String content;
  final String role;
  final String? imageUrl;
  final String? videoUrl;
  bool allowComments;
  final DateTime createdAt;
  final DateTime updatedAt;
  int likesCount;
  final int commentsCount;
  final String creatorName;
  bool isLiked;

  Announcement(
      {required this.id,
      required this.creatorId,
      required this.title,
      required this.status,
      required this.reason,
      required this.content,
      this.imageUrl,
      this.videoUrl,
      required this.allowComments,
      required this.createdAt,
      required this.updatedAt,
      required this.likesCount,
      required this.commentsCount,
      required this.creatorName,
      required this.role,
      this.isLiked = false});

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      creatorId: json['creatorId']?.toString() ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      reason: json['reason'] ?? '',
      content: json['content'] ?? '',
      role: json['role'],
      imageUrl: json['image'],
      videoUrl: json['video'],
      creatorName: json['creatorName']?? 'some one',
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
