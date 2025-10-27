class Comment {
  final String id;
  final String author;
  final String content;
  final DateTime timestamp;
  int likes;
  bool isLiked;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
  });
}