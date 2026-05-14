class ApiConstants {
  // ASP.NET Core API - http profile port 5156
  static const String baseUrl = 'http://localhost:5156/api';

  static const String login    = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String users    = '$baseUrl/users';
  static const String me       = '$baseUrl/users/me';
}
