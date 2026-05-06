import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  final AuthService _authService;

  UserService(this._authService);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$apiUrl/users/me'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw jsonDecode(response.body)['detail'] ?? 'Failed to get profile';
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    String? email,
    String? phone,
  }) async {
    final Map<String, dynamic> body = {};
    if (fullName != null) body['full_name'] = fullName;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;

    final response = await http.put(
      Uri.parse('$apiUrl/users/me'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw jsonDecode(response.body)['detail'] ?? 'Failed to update profile';
    }
  }

  Future<List<dynamic>> getAddresses() async {
    final response = await http.get(
      Uri.parse('$apiUrl/users/me/addresses'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw 'Failed to get addresses';
    }
  }

  Future<Map<String, dynamic>> addAddress({
    required String label,
    required String fullAddress,
    required String city,
    required String state,
    required String pincode,
    required bool isDefault,
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/users/me/addresses'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'label': label,
        'full_address': fullAddress,
        'city': city,
        'state': state,
        'pincode': pincode,
        'is_default': isDefault,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw jsonDecode(response.body)['detail'] ?? 'Failed to add address';
    }
  }

  Future<Map<String, dynamic>> updateAddress(
    String id, {
    String? label,
    String? fullAddress,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
  }) async {
    final Map<String, dynamic> body = {};
    if (label != null) body['label'] = label;
    if (fullAddress != null) body['full_address'] = fullAddress;
    if (city != null) body['city'] = city;
    if (state != null) body['state'] = state;
    if (pincode != null) body['pincode'] = pincode;
    if (isDefault != null) body['is_default'] = isDefault;

    final response = await http.put(
      Uri.parse('$apiUrl/users/me/addresses/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw jsonDecode(response.body)['detail'] ?? 'Failed to update address';
    }
  }

  Future<void> deleteAddress(String id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/users/me/addresses/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw 'Failed to delete address';
    }
  }

  // --- Favorites ---
  Future<List<dynamic>> getFavoritePartners() async {
    final response = await http.get(
      Uri.parse('$apiUrl/users/me/favorites'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw 'Failed to load favorite partners';
    }
  }

  Future<void> addFavoritePartner(String partnerId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/users/me/favorites/$partnerId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw 'Failed to add favorite';
    }
  }

  Future<void> removeFavoritePartner(String partnerId) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/users/me/favorites/$partnerId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw 'Failed to remove favorite';
    }
  }

  // --- Presence ---
  Future<void> updatePresence(bool isOnline) async {
    final response = await http.patch(
      Uri.parse('$apiUrl/users/me/presence?is_online=$isOnline'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw 'Failed to update presence';
    }
  }

  // --- Reviews ---
  Future<bool> submitReview(
    String jobId,
    String providerId,
    int rating,
    String? comment,
  ) async {
    final response = await http.post(
      Uri.parse('$apiUrl/users/reviews'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'job_id': jobId,
        'partner_id': providerId,
        'rating': rating,
        'comment': comment,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<dynamic>> getProviderReviews(String providerId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/users/reviews/$providerId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
}
