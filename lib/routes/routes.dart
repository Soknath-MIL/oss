import 'package:get/get.dart';
import 'package:oss/presentation/pages/appeal_list_page.dart';
import 'package:oss/presentation/pages/appeal_page.dart';
import 'package:oss/presentation/pages/complete_form_page.dart';
import 'package:oss/presentation/pages/contact_us_page.dart';
import 'package:oss/presentation/pages/edit_profile_page.dart';
import 'package:oss/presentation/pages/emergency_page.dart';
import 'package:oss/presentation/pages/ems_request_page.dart';
import 'package:oss/presentation/pages/general_request_form.dart';
import 'package:oss/presentation/pages/home_page.dart';
import 'package:oss/presentation/pages/journal_page.dart';
import 'package:oss/presentation/pages/login_page.dart';
import 'package:oss/presentation/pages/main_page.dart';
import 'package:oss/presentation/pages/map_view_page.dart';
import 'package:oss/presentation/pages/message_page.dart';
import 'package:oss/presentation/pages/news_detail_page.dart';
import 'package:oss/presentation/pages/news_page.dart';
import 'package:oss/presentation/pages/notification_detail_page.dart';
import 'package:oss/presentation/pages/payment_detail_page.dart';
import 'package:oss/presentation/pages/pois_page.dart';
import 'package:oss/presentation/pages/qr_scanner_page.dart';
import 'package:oss/presentation/pages/request_detail_page.dart';
import 'package:oss/presentation/pages/request_page.dart';
import 'package:oss/presentation/pages/splash_screen.dart';
import 'package:oss/presentation/pages/staff_list_page.dart';
import 'package:oss/presentation/pages/tax_payment_page.dart';
import 'package:oss/presentation/pages/trash_request_form.dart';
import 'package:oss/presentation/pages/validate_account.dart';
import 'package:oss/presentation/pages/verify_otp_page.dart';
import 'package:oss/presentation/pages/vision_page.dart';
import 'package:oss/presentation/widgets/no_internet.dart';

import '../presentation/pages/open_access_page.dart';
import '../presentation/pages/open_bussiness_main_page.dart';
import '../presentation/pages/vision_detail_page.dart';
import '../presentation/widgets/maintenance_widget.dart';
import '../presentation/widgets/request_list.dart';

appRoutes() => [
      GetPage(
        name: '/main',
        page: () => const MainScreen(),
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/home',
        page: () => const HomeScreen(),
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/login',
        page: () => LoginPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/verify-otp',
        page: () => VerifyOtpScreen(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/message',
        page: () => const MessageScreen(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/validate-account',
        page: () => const ValidateSccount(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/appeal-request',
        page: () => const AppealPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/request',
        page: () => const RequestPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/splashscreen',
        page: () => const SplashScreen(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/request-detail',
        page: () => const RequestDetailPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/news',
        page: () => const NewsPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/emergency',
        page: () => const EmergencyContactPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/contact',
        page: () => const ContactUsPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/appeal-list',
        page: () => const AppealListPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/request-list',
        page: () => const RequestListPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/news-detail',
        page: () => const NewsDetailPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/journal',
        page: () => const JournalPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/staff',
        page: () => const StaffListPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/open-access',
        page: () => const OpenAccessPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/map-view',
        page: () => const MapViewPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/chat',
        page: () => const MessageScreen(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/pois',
        page: () => const PoisPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/notification-detail',
        page: () => const NotificationDetailPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/vision',
        page: () => const VisionPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/vision-detail',
        page: () => const VisionDetailPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/tax-payment',
        page: () => const TaxPaymentPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/payment-detail',
        page: () => const PaymentDetailPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/test-form',
        page: () => const CompleteForm(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/ems-form',
        page: () => const EmsRequestPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/trash-form',
        page: () => const TrashRequestPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/general-form',
        page: () => const GeneralRequestPage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/openBusiness-form',
        page: () => const OpenBusiness(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/edit-profile',
        page: () => const EditProfilePage(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/qr-scanner',
        page: () => const QRScanner(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/no-connection',
        page: () => const NoInternetConnection(),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/maintenance',
        page: () => const MaintenanceWidget(
          label: "ภายใต้การบำรุงรักษา",
        ),
        middlewares: [MyMiddelware()],
        transition: Transition.leftToRightWithFade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ];

class MyMiddelware extends GetMiddleware {}
