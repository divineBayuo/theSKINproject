// To parse this JSON data, do
//
//     final mongoDbModel = mongoDbModelFromJson(jsonString);

import 'dart:convert';
//import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

MongoDbModel mongoDbModelFromJson(String str) =>
    MongoDbModel.fromJson(json.decode(str));

String mongoDbModelToJson(MongoDbModel data) => json.encode(data.toJson());

class MongoDbModel {
  ObjectId id;
  String fullname;
  String location;
  String dob;
  String sex;
  String phone;
  String emergency;
  String emergentcontact;
  String modeofdetection;
  String othermodeofdetection;
  String classification;
  String duration;
  String dateofclinexam;
  String limitation;
  String numberoflesions;
  String diameter1;
  String diameter2;
  List<String> typeoflesion;
  List<String> locationofswelling;
  String? imageBase64;
  List<String> clinicalsuspicion;
  String other;
  String anyother;
  String? comment;

  MongoDbModel({
    required this.id,
    required this.fullname,
    required this.location,
    required this.dob,
    required this.sex,
    required this.phone,
    required this.emergency,
    required this.emergentcontact,
    required this.modeofdetection,
    required this.othermodeofdetection,
    required this.classification,
    required this.duration,
    required this.dateofclinexam,
    required this.limitation,
    required this.numberoflesions,
    required this.diameter1,
    required this.diameter2,
    required this.typeoflesion,
    required this.locationofswelling,
    this.imageBase64,
    required this.clinicalsuspicion,
    required this.other,
    required this.anyother,
    this.comment,
  });

  factory MongoDbModel.fromJson(Map<String, dynamic> json) => MongoDbModel(
        id: json["_id"] is String
            ? ObjectId.fromHexString(json["_id"])
            : json["_id"],
        fullname: json["fullname"] ?? '',
        location: json["location"] ?? '',
        dob: json["dob"] ?? '',
        sex: json["sex"] ?? '',
        phone: json["phone"] ?? '',
        emergency: json["emergency"] ?? '',
        emergentcontact: json["emergentcontact"] ?? '',
        modeofdetection: json["modeofdetection"] ?? '',
        othermodeofdetection: json["othermodeofdetection"] ?? '',
        classification: json["classification"] ?? '',
        duration: json["duration"] ?? '',
        dateofclinexam: json["dateofclinexam"] ?? '',
        limitation: json["limitation"] ?? '',
        numberoflesions: json["numberoflesions"] ?? '',
        diameter1: json["diameter1"] ?? '',
        diameter2: json["diameter2"] ?? '',
        typeoflesion: (json["typeoflesion"] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        locationofswelling: (json["locationofswelling"] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        imageBase64: json["imageBase64"] ?? '',
        clinicalsuspicion: (json["clinicalsuspicion"] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        other: json["other"] ?? '',
        anyother: json["anyother"] ?? '',
        comment: json["comment"] ?? '',
      );

  String? get image => null;

  Map<String, dynamic> toJson() => {
        "_id": id,
        "fullname": fullname,
        "location": location,
        "dob": dob,
        "sex": sex,
        "phone": phone,
        "emergency": emergency,
        "emergentcontact": emergentcontact,
        "modeofdetection": modeofdetection,
        "othermodeofdetection": othermodeofdetection,
        "classification": classification,
        "duration": duration,
        "dateofclinexam": dateofclinexam,
        "limitation": limitation,
        "numberoflesions": numberoflesions,
        "diameter1": diameter1,
        "diameter2": diameter2,
        "typeoflesion": typeoflesion,
        "locationofswelling": locationofswelling,
        "imageBase64": imageBase64,
        "clinicalsuspicion": clinicalsuspicion,
        "other": other,
        "anyother": anyother,
        "comment": comment
      };
}
