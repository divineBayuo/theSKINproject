//import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skin_app/MongoDBModel.dart';
import 'package:skin_app/dbHelper/constant.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class MongoDatabase {
  static mongo.Db? _db;
  static mongo.DbCollection? userCollection;

/*   static Future<void> connect() async {
    var connectionString = dotenv.env['MONGO_CONN_URL']!;
    _db = mongo.Db(connectionString);

    try {
      await _db!.open();
      print('Connected to database');
      userCollection = _db!.collection(USER_COLLECTION);
    } catch (e) {
      print('Error connecting to database: $e');
      rethrow;
    }
  } */

  static Future<void> connect() async {
    try {
      await dotenv.load(fileName: ".env");
      var connectionString = dotenv.env['MONGO_CONN_URL']!;
      _db = mongo.Db(connectionString);

      await _db!.open();
      print('Connected to database');
      userCollection = _db!.collection(USER_COLLECTION);

    } catch (e) {
      print('Error connecting to database: $e');
      rethrow;
    }
  }

  static mongo.Db get db => _db!;

  static Future<void> update(MongoDbModel data) async {
    try {
      await userCollection!.update(mongo.where.eq('_id', data.id),
          mongo.modify.set('comment', data.comment));
      print('Update successful');
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  static Future<String> insert(MongoDbModel data) async {
    try {
      var result = await userCollection!.insertOne(data.toJson());
      print('Insert result: ${result.toString()}');

      if (result.isSuccess) {
        return result.toString();
      } else {
        return ("Something went wrong while inserting data.");
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  static Future<void> delete(String id) async {
    try {
      var objectId = mongo.ObjectId.fromHexString(id);
      await userCollection!.remove({'_id': objectId});
      print('Delete successful');
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    try {
      var data = await userCollection!.find().toList();
      return data;
    } catch (e) {
      print(e);
      print('Error retrieving data: $e');
      return [];
    }
  }
}
