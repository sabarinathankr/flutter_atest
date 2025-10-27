

import 'comment.dart';

class PostData {
  final String id;
  final String videoId;
  final String title;
  final String description;
  final String author;
  final DateTime timestamp;

  PostData({
    required this.id,
    required this.videoId,
    required this.title,
    required this.description,
    required this.author,
    required this.timestamp,
  });
}