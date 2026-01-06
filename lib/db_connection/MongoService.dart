import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';

import 'db_exceptions.dart';


class MongoService {

  String dbKey() {
    return "mongodb+srv://atestrazorpay:OucgJLTdGOHrpWwq@cluster0.a1okps9.mongodb.net/AtestCollections?retryWrites=true&w=majority&appName=Cluster0";
  }
  MongoService._internal();
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;

  Db? _db;
  Future<Db>? _openingFuture; // 🔥 key part
  Future<Db> getDb() {
    // ✅ Already connected
    if (_db != null && _db!.isConnected) {
      return Future.value(_db);
    }

    // 🔁 Already opening → wait for it
    if (_openingFuture != null) {
      return _openingFuture!;
    }

    // 🆕 First open
    _openingFuture = _openDb();
    return _openingFuture!;
  }

  Future<Db> _openDb() async {
    try {
      _db = await Db.create(dbKey());
      await _db!.open();
      return _db!;
    } on MongoDartError catch (e) {
      if (e.message.contains('authentication failed')) {
        throw DbAuthException();
      }
      throw DbUnknownException(e.message);
    } on SocketException {
      throw DbNoInternetException();
    } finally {
      _openingFuture = null; // ✅ reset
    }
  }

  Future<void> close() async {
   /* if (_db != null && _db!.isConnected) {
      await _db!.close();
      _db = null;
    }*/
  }
}
