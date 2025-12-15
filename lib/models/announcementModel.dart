import 'package:mongo_dart/mongo_dart.dart';

class AnnouncementModel{
  ObjectId? id;
  String tittle;
  String description;
  bool isDisplay;
  AnnouncementModel({
    this.id,
    required this.tittle,
    required this.description,
    required this.isDisplay,
  });
  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {

    return AnnouncementModel(
        id: map['_id'],
        tittle: map['tittle'],
        description: map['description'],
        isDisplay: map['isDisplay']

    );
  }


  Map<String, dynamic> toMap() {


    return {
      'tittle': tittle,
      'description': description,
      'isDisplay': isDisplay,
    };
  }
}