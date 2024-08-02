import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Assuming you're using JWT

class TokenManager {
  static const _tokenKey = 'auth_token';

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Retrieve token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;

    final isExpired = JwtDecoder.isExpired(token);
    return !isExpired;
  }
}
