import 'package:get/get.dart';
import 'package:jedweli/features/auth/presentation/pages/password_reset.dart';
import 'package:jedweli/features/auth/presentation/pages/password_reset_confirm.dart';
import 'package:jedweli/features/home/presentation/pages/create_schedule_screen.dart';
import 'package:jedweli/features/home/presentation/pages/share_schedule_screen.dart';
import 'package:jedweli/features/splash/presentation/pages/splash_screen.dart';
import 'package:jedweli/features/auth/presentation/pages/login_screen.dart';
import 'package:jedweli/features/auth/presentation/pages/otp_screen.dart';
import 'package:jedweli/features/auth/presentation/pages/register_screen.dart';
import 'package:jedweli/features/home/presentation/pages/home_screen.dart';
import 'package:jedweli/features/home/presentation/pages/schedules_screen.dart';

import '../features/home/presentation/pages/shared_schedule_detail_screen.dart';
import '../features/home/presentation/pages/shared_schedules_screen.dart';

/// A class containing all route names and the corresponding GetPage definitions.
class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const otp = '/otp';
  static const register = '/register';
  static const passwordReset = '/password-reset';
  static const passwordResetConfirm = '/password-reset-confirm';
  static const home = '/home';
  static const schedules = '/schedules';
  static const scheduleDetail = '/schedule-detail';
  static const shareSchedule = '/share-schedule'; //5alge
  static const createSchedule = '/create-schedule';
  static const sharedSchedules = '/sharedSchedules'; // 5alge
  static const sharedScheduleDetail = '/sharedScheduleDetail'; //5alge

  /// The list of GetPage routes for the application.
  static final routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: otp, page: () => OtpScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(name: passwordReset, page: () => PasswordResetScreen()),
    GetPage(name: passwordResetConfirm, page: () => PasswordResetConfirmScreen()),
    
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: schedules, page: () => SchedulesScreen()),
    GetPage(name: shareSchedule, page: () => ShareScheduleScreen()),
    GetPage(name: createSchedule, page: () => CreateScheduleScreen()),

    GetPage(name: AppRoutes.sharedSchedules, page: () => SharedSchedulesScreen()),
    GetPage(name: AppRoutes.sharedScheduleDetail, page: () => SharedScheduleDetailScreen()),

  ];
}
