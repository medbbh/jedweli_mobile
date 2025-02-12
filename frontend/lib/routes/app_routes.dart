import 'package:get/get.dart';
import 'package:jedweli/screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/schedules_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';
  static const register = '/register';
  static const home = '/home';
  static const schedules = '/schedules';
  static const scheduleDetail = '/schedule-detail';

  static final routes = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: otp, page: () => OtpScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: schedules, page: () => SchedulesScreen()),
  ];
}
