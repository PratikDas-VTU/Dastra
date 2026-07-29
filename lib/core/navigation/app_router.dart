// go_router configuration for Dastra
// All named routes are defined here for easy maintenance.
import 'package:go_router/go_router.dart';
import '../../modules/splash/splash_screen.dart';
import '../../modules/onboarding/onboarding_screen.dart';
import '../../modules/dashboard/dashboard_screen.dart';
import '../../modules/document/document_screen.dart';
import '../../modules/image/image_screen.dart';
import '../../modules/security/security_screen.dart';
import '../../modules/security/password_generator/password_generator_screen.dart';
import '../../modules/security/password_checker/password_checker_screen.dart';
import '../../modules/document/pdf_merge/pdf_merge_screen.dart';
import '../../modules/document/pdf_split/pdf_split_screen.dart';
import '../../modules/document/images_to_pdf/images_to_pdf_screen.dart';
import '../../modules/document/pdf_to_images/pdf_to_images_screen.dart';
import '../../modules/document/pdf_to_word/pdf_to_word_screen.dart';
import '../../modules/document/pptx_to_pdf/pptx_to_pdf_screen.dart';
import '../../modules/document/word_to_pdf/word_to_pdf_screen.dart';
import '../../modules/document/pdf_compress/pdf_compress_screen.dart';
import '../../modules/image/image_converter/image_converter_screen.dart';
import '../../modules/image/image_compressor/image_compressor_screen.dart';
import '../../modules/settings/settings_screen.dart';
import '../../modules/about/about_screen.dart';
import '../../modules/workspace/presentation/workspace_screen.dart';
import '../shell/app_shell.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // ── Splash ───────────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Shell (persistent sidebar / bottom nav) ───────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/workspace',
            pageBuilder: (context, state) => const NoTransitionPage(child: WorkspaceScreen()),
          ),
          GoRoute(
            path: '/document',
            pageBuilder: (context, state) => const NoTransitionPage(child: DocumentScreen()),
            routes: [
              GoRoute(
                path: 'pdf-merge',
                builder: (context, state) => const PdfMergeScreen(),
              ),
              GoRoute(
                path: 'pdf-split',
                builder: (context, state) => const PdfSplitScreen(),
              ),
              GoRoute(
                path: 'images-to-pdf',
                builder: (context, state) => const ImagesToPdfScreen(),
              ),
              GoRoute(
                path: 'pdf-to-images',
                builder: (context, state) => const PdfToImagesScreen(),
              ),
              GoRoute(
                path: 'pdf-to-word',
                builder: (context, state) => const PdfToWordScreen(),
              ),
              GoRoute(
                path: 'ppt-to-pdf',
                builder: (context, state) => const PptxToPdfScreen(),
              ),
              GoRoute(
                path: 'word-to-pdf',
                builder: (context, state) => const WordToPdfScreen(),
              ),
              GoRoute(
                path: 'compress-pdf',
                builder: (context, state) => const PdfCompressScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/security',
            pageBuilder: (context, state) => const NoTransitionPage(child: SecurityScreen()),
            routes: [
              GoRoute(
                path: 'password-generator',
                builder: (context, state) => const PasswordGeneratorScreen(),
              ),
              GoRoute(
                path: 'password-checker',
                builder: (context, state) => const PasswordCheckerScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),
          GoRoute(
            path: '/image',
            pageBuilder: (context, state) => const NoTransitionPage(child: ImageScreen()),
            routes: [
              GoRoute(
                path: 'converter',
                builder: (context, state) => const ImageConverterScreen(),
              ),
              GoRoute(
                path: 'compressor',
                builder: (context, state) => const ImageCompressorScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/about',
            pageBuilder: (context, state) => const NoTransitionPage(child: AboutScreen()),
          ),
        ],
      ),
    ],
  );
}
