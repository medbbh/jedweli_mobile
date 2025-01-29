import 'package:get/get.dart';
import '../utils/constants.dart';

class AuthService extends GetConnect {

  @override
  void onInit() {
    httpClient.baseUrl = Constants.baseAuthUrl;
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }


  Future<Response> register(Map<String, dynamic> data) async {
    return await post('register/', data);
  }
  // ✅ Login API
  Future<Response> login(Map<String, dynamic> data) async {
    const url = 'login/'; 
    print("Login request to: $url with data: $data"); // ✅ Debug API request

    final response = await post(url, data);

    print("Login Response: ${response.statusCode} - ${response.body}"); // ✅ Debug API response

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception("Failed to login: ${response.body}");
    }
  }


Future<Response> verifyOtp(Map<String, dynamic> data) async {
  print("Verifying OTP with data: $data"); // ✅ Debugging

  final response = await post('verify-otp/', data);

  print("OTP Response: ${response.statusCode} - ${response.body}"); // ✅ Debugging response

  if (response.statusCode == 200) {
    final responseBody = response.body;

    if (responseBody != null && responseBody.containsKey('access') && responseBody.containsKey('refresh')) {
      print("Tokens received: Access - ${responseBody['access']}, Refresh - ${responseBody['refresh']}");
      return response; // 
    } else {
      throw Exception("Invalid response format. Expected access and refresh tokens.");
    }
  } else {
    throw Exception("Failed to verify OTP: ${response.body}");
  }
}

}
