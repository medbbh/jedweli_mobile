import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/schedules_screen.dart';
import '../screens/home/schedule_detail_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const otp = '/otp';
  static const register = '/register';
  static const home = '/home';
  static const schedules = '/schedules';
  static const scheduleDetail = '/schedule-detail';

  static final routes = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: otp, page: () => OtpScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: schedules, page: () => const SchedulesScreen()),
    GetPage(name: scheduleDetail, page: () => ScheduleDetailScreen()),
  ];
}
