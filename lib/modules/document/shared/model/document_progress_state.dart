import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart' as get_it;
import 'success_screen_data.dart';
import 'conversion_result_data.dart';
import '../../../../core/navigation/app_router.dart' as app_router;
import '../../../../core/widgets/dastra_snackbar.dart' as dastra_snackbar;
import '../../../settings/controller/user_preferences_controller.dart' as user_prefs;

/// A mixin to provide standardized progress states for document controllers.
mixin DocumentProgressState on ChangeNotifier {
  SuccessScreenData? _successData;
  SuccessScreenData? get successData => _successData;
  
  ConversionResultData? _resultData;
  ConversionResultData? get resultData => _resultData;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  double _progress = 0.0;
  double get progress => _progress;

  String _statusMessage = '';
  String get statusMessage => _statusMessage;

  void setProcessingState({
    required bool isProcessing,
    double progress = 0.0,
    String statusMessage = '',
  }) {
    _isProcessing = isProcessing;
    _progress = progress;
    _statusMessage = statusMessage;
    notifyListeners();

    // Check if this is an error state (not processing, progress 0, has message)
    if (!isProcessing && progress == 0.0 && statusMessage.isNotEmpty) {
      _showNotification(statusMessage, isError: true);
    }
  }

  void updateProgress(double progress, [String? message]) {
    if (!_isProcessing) return;
    _progress = progress;
    if (message != null) {
      _statusMessage = message;
    }
    notifyListeners();
  }

  void setSuccessState(dynamic data) {
    _isProcessing = false;
    _progress = 1.0;
    _statusMessage = 'Completed';
    if (data is SuccessScreenData) {
      _successData = data;
    } else if (data is ConversionResultData) {
      _resultData = data;
    }
    notifyListeners();

    String successMessage = 'Task completed successfully';
    if (data is ConversionResultData) {
      successMessage = 'Saved as ${data.outputFilename}';
    } else if (data is SuccessScreenData) {
      successMessage = 'Saved as ${data.outputFilename}';
    }
    _showNotification(successMessage, isError: false);
  }

  void _showNotification(String message, {required bool isError}) {
    try {
      final sl = get_it.GetIt.instance;
      if (!sl.isRegistered<user_prefs.UserPreferencesController>()) return;
      
      final prefs = sl<user_prefs.UserPreferencesController>();
      final notifications = prefs.profile.notifications;
      
      if (!notifications.enabled) return;
      if (isError && !notifications.onError) return;
      if (!isError && !notifications.onSuccess) return;

      final context = app_router.AppRouter.router.routerDelegate.navigatorKey.currentContext;
      if (context != null) {
        dastra_snackbar.DastraSnackbar.show(
          context: context,
          message: message,
          isError: isError,
          icon: isError ? null : null,
        );
      }
    } catch (_) {
      // Ignore notification errors if context or services are unavailable
    }
  }

  void resetProgress() {
    _isProcessing = false;
    _progress = 0.0;
    _statusMessage = '';
    _successData = null;
    _resultData = null;
    notifyListeners();
  }
}
