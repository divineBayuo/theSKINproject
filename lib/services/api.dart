//import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class Api {
  // POST method
  static const String baseUrl = 'http://192.168.0.149/api';

  static Future<bool> addPatient(Map<String, String> data, File? imageFile) async {
    var uri = Uri.parse('$baseUrl/patient');

    var request = http.MultipartRequest('POST', uri);
    request.fields.addAll(data);

    if (imageFile != null) {
      var mimeType = lookupMimeType(imageFile.path)!.split('/');
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));
    }

    var response = await request.send();

    return response.statusCode == 200;
  }


  // GET method
  static Future<http.Response> getPatient(String id) async {
    var uri = Uri.parse('$baseUrl/get_patient/$id');
    var response = await http.get(uri);
    return response;
  }

  // PUT method
  static Future<bool> updatePatient(String id, Map<String, String> data, File? imageFile) async {
    var uri = Uri.parse('$baseUrl/update_patient/$id');

    var request = http.MultipartRequest('PUT', uri);
    request.fields.addAll(data);

    if (imageFile != null) {
      var mimeType = lookupMimeType(imageFile.path)!.split('/');
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));
    }

    var response = await request.send();

    return response.statusCode == 200;
  }

  // PATCH method
  static Future<bool> patchPatient(String id, Map<String, String> data) async {
    var uri = Uri.parse('$baseUrl/patch_patient/$id');

    var request = http.MultipartRequest('PATCH', uri);
    request.fields.addAll(data);

    var response = await request.send();

    return response.statusCode == 200;
  }

  // DELETE method
  static Future<bool> deletePatient(String id) async {
    var uri = Uri.parse('$baseUrl/delete_patient/$id');
    var response = await http.delete(uri);
    return response.statusCode == 200;
  }
}

