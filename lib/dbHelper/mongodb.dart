//import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skin_app/MongoDBModel.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class MongoDatabase {
  static mongo.Db? _db;
  static mongo.DbCollection? userCollection;

  static Future<void> connect() async {
    try {
      // Initialize and load the dotenv file
      //await dotenv.load(fileName: ".env");

      // Fetch the MongoDB connection string from the .env file
      var connectionString = dotenv.env['MONGO_CONN_URL'];

      if (connectionString == null) {
        throw Exception('MongoDB connection URL not found in .env');
      }

      // Connect to the MongoDB database
      _db = mongo.Db(connectionString);
      await _db!.open();
      print('Connected to database');

      userCollection = _db!
          .collection('patients'); // Adjust USER_COLLECTION if it's a constant
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
