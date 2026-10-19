import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:amanah_healthcare/core/auth/amanah_auth_session_manager.dart';
import 'package:amanah_healthcare/core/notifications/amanah_push_service.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_bottom_banner.dart';
import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_logger.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/data/datasources/google_auth_service.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/restore_session.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/sign_out.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_closed_view.dart';
import 'package:amanah_healthcare/features/authentication/presentation/organisms/auth_modal_sheet.dart';
import 'package:amanah_healthcare/features/authentication/presentation/screen/staff_onboarding_screen.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/amanah_home_shell.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/data/amanah_permission_store.dart';
import 'package:amanah_healthcare/features/queue/presentation/state/amanah_queue_store.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/helpers/global_vars.dart';

class AuthBottomSheetScreen extends StatefulWidget {
  const AuthBottomSheetScreen({
    super.key,
    this.backgroundAsset = 'assets/amanah/auth/auth_background.png',
    this.repository = const AmanahAuthRepository(),
    RestoreSessionUseCase? restoreSessionUseCase,
    SignOutUseCase? signOutUseCase,
    this.onAuthenticated,
  })  : _restoreSessionUseCase = restoreSessionUseCase,
        _signOutUseCase = signOutUseCase;

  final String backgroundAsset;
  final AuthRepository repository;
  final RestoreSessionUseCase? _restoreSessionUseCase;
  final SignOutUseCase? _signOutUseCase;
  final ValueChanged<AmanahAuthUser>? onAuthenticated;

  RestoreSessionUseCase get restoreSessionUseCase =>
      _restoreSessionUseCase ?? RestoreSessionUseCase(repository);

  SignOutUseCase get signOutUseCase =>
      _signOutUseCase ?? SignOutUseCase(repository);

  @override
  State<AuthBottomSheetScreen> createState() => _AuthBottomSheetScreenState();
}

class _AuthBottomSheetScreenState extends State<AuthBottomSheetScreen>
    with WidgetsBindingObserver {
  AmanahAuthUser? _authenticatedUser;
  bool _showOnboardingScreen = true;
  bool _isRestoringSession = true;
  StreamSubscription<AuthSessionEvent>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToSessionEvents();
    _restoreSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionSubscription?.cancel();
    super.dispose();
  }

  void _listenToSessionEvents() {
    _sessionSubscription = AmanahAuthSessionManager.instance.eventStream
        .listen((AuthSessionEvent event) {
      if (event == AuthSessionEvent.expired && mounted) {
        _handleSessionExpired();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _authenticatedUser != null) {
      AmanahAuthLogger.logLifecycle('App resumed: verifying session validity');
      unawaited(
        AmanahAuthSessionManager.instance.verifySessionValidity(
          authRepository: widget.repository,
        ),
      );
    }
  }

  Future<void> _handleSessionExpired() async {
    AmanahAuthLogger.logLifecycle(
      'Session expired event received: redirecting to auth screen',
    );

    // Pop any child screens on top of navigator back to root
    GlobalVars.navigatorKey.currentState
        ?.popUntil((Route<dynamic> r) => r.isFirst);

    await _handleLogout();

    if (mounted) {
      AmanahBottomBanner.warning(
        context,
        message: 'Sesi Anda telah kedaluwarsa. Silakan masuk kembali.',
      );
    }
  }

  Future<void> _restoreSession() async {
    AmanahAuthLogger.logLifecycle('Initiating cold startup session check');
    try {
      final AmanahAuthUser? user =
          await widget.restoreSessionUseCase(const NoParams());
      if (user != null && mounted) {
        AmanahAuthLogger.logLifecycle(
          'Active session restored successfully',
          details: <String, dynamic>{
            'userId': user.id,
            'name': user.fullName,
            'role': user.role.name,
            'needsOnboarding': user.needsOnboarding,
          },
        );
        setState(() {
          _authenticatedUser = user;
          _showOnboardingScreen = true;
          _isRestoringSession = false;
        });
        widget.onAuthenticated?.call(user);
        unawaited(AmanahPushService.instance.registerDeviceWithBackend());
      } else if (mounted) {
        setState(() {
          _isRestoringSession = false;
        });
      }
    } catch (e) {
      AmanahAuthLogger.logLifecycle('Session restoration check error: $e');
      if (mounted) {
        setState(() {
          _isRestoringSession = false;
        });
      }
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  Future<void> _handleLogout() async {
    await widget.signOutUseCase(const NoParams());
    try {
      await const GoogleAuthService().signOut();
    } catch (_) {}
    AmanahScheduleStore.instance.reset();
    AmanahNotificationStore.instance.reset();
    AmanahPermissionStore.instance.reset();
    AmanahQueueStore.instance.reset();
    if (mounted) {
      setState(() {
        _authenticatedUser = null;
        _showOnboardingScreen = true;
      });
    }
  }

  void _onAuthenticated(AmanahAuthUser user) {
    widget.onAuthenticated?.call(user);
    setState(() {
      _authenticatedUser = user;
      _showOnboardingScreen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoringSession) {
      return const Scaffold(
        backgroundColor: AmanahColorTokens.canvasDark,
        body: SizedBox.expand(),
      );
    }

    final AmanahAuthUser? user = _authenticatedUser;
    if (user != null) {
      if (user.needsOnboarding && _showOnboardingScreen) {
        return StaffOnboardingScreen(
          user: user,
          repository: widget.repository,
          onBack: () => setState(() => _showOnboardingScreen = false),
          onOnboardingComplete: (AmanahAuthUser updatedUser) {
            setState(() {
              _authenticatedUser = updatedUser;
              _showOnboardingScreen = false;
            });
            widget.onAuthenticated?.call(updatedUser);
          },
          onLogout: _handleLogout,
        );
      }

      if (!user.needsOnboarding) {
        return AmanahHomeShell(
          user: user,
          onLogout: _handleLogout,
        );
      }
    }

    final bool hasPendingOnboarding = user != null && user.needsOnboarding;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AuthBackground(assetPath: widget.backgroundAsset),
          const AuthBackgroundScrim(),
          AuthClosedActions(
            hasPendingOnboarding: hasPendingOnboarding,
            onResumeOnboarding: () =>
                setState(() => _showOnboardingScreen = true),
            onSignIn: () => AuthModalSheet.show(
              context,
              repository: widget.repository,
              onAuthenticated: _onAuthenticated,
            ),
          ),
        ],
      ),
    );
  }
}
