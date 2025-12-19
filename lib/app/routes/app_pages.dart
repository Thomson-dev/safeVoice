import 'package:get/get.dart';
import 'package:safe_voice/app/routes/role_selection_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/report_controller.dart';
import '../controllers/trusted_contact_controller.dart';
import '../../features/student/screens/student_home_screen.dart';
import '../../features/student/screens/report_incident_screen.dart';
import '../../features/student/screens/emergency_alert_screen.dart';
import '../../features/student/screens/track_report_screen.dart';
import '../../features/student/screens/trusted_contacts_screen.dart';
import '../../features/student/screens/resources_hub_screen.dart';
import '../../features/counselor/screens/counselor_home_screen.dart';
import '../../features/counselor/screens/report_detail_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = AppRoutes.ROLE_SELECTION;

  static final routes = [
    GetPage(
      name: AppRoutes.ROLE_SELECTION,
      page: () => const RoleSelectionScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.STUDENT_HOME,
      page: () => const StudentHomeScreen(),
      binding: StudentBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.REPORT_INCIDENT,
      page: () => const ReportIncidentScreen(),
      binding: ReportBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.EMERGENCY_ALERT,
      page: () => const EmergencyAlertScreen(),
      binding: EmergencyBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.TRACK_REPORT,
      page: () => const TrackReportScreen(),
      binding: TrackingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.TRUSTED_CONTACTS,
      page: () => const TrustedContactsScreen(),
      binding: ContactsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.RESOURCES_HUB,
      page: () => const ResourcesHubScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.COUNSELOR_HOME,
      page: () => const CounselorHomeScreen(),
      binding: CounselorBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.REPORT_DETAIL,
      page: () => const ReportDetailScreen(),
      binding: ReportDetailBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}

// Bindings
class StudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ReportController());
    Get.put(TrustedContactController());
  }
}

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ReportController());
  }
}

class EmergencyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ReportController());
    Get.put(TrustedContactController());
  }
}

class TrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ReportController());
  }
}

class ContactsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TrustedContactController());
  }
}

class CounselorBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ReportController());
  }
}

class ReportDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ReportController());
  }
}
