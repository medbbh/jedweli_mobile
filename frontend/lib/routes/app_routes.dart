import 'package:get/get.dart';
import 'package:jedweli/features/splash/presentation/pages/splash_screen.dart';
import 'package:jedweli/features/auth/presentation/pages/login_screen.dart';
import 'package:jedweli/features/auth/presentation/pages/otp_screen.dart';
import 'package:jedweli/features/auth/presentation/pages/register_screen.dart';
import 'package:jedweli/features/home/presentation/pages/home_screen.dart';
import 'package:jedweli/features/home/presentation/pages/schedules_screen.dart';

/// A class containing all route names and the corresponding GetPage definitions.
class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';
  static const register = '/register';
  static const home = '/home';
  static const schedules = '/schedules';
  static const scheduleDetail = '/schedule-detail';

  /// The list of GetPage routes for the application.
  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: otp, page: () => OtpScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: schedules, page: () => SchedulesScreen()),
  ];
}
