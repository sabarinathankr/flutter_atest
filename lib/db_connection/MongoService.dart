import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';

class MongoService {

  String dbKey() {
    String ourConnection="mongodb+srv://atestrazorpay:OucgJLTdGOHrpWwq@cluster0.a1okps9.mongodb.net/AtestCollections?retryWrites=true&w=majority&appName=Cluster0";
    return ourConnection;
  }
  MongoService._internal();
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;

  Db? _db;

  /// Get active DB connection
  Future<Db> getDb() async {
    if (_db != null && _db!.isConnected) {
      return _db!;
    }

    try {
      _db = await Db.create(dbKey());
      await _db!.open();
      print('✅ MongoDB connected');
      return _db!;
    } on MongoDartError catch (e) {
      if (e.message.contains('authentication failed')) {
        throw Exception('MONGO_AUTH_ERROR');
      }
      throw Exception('MONGO_ERROR: ${e.message}');
    } on SocketException {
      throw Exception('NO_INTERNET');
    } catch (e) {
      throw Exception('UNKNOWN_ERROR: $e');
    }
  }

  /// Close DB (optional, usually on logout/app close)
  Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      _db = null;
      print('🔌 MongoDB disconnected');
    }
  }
}
