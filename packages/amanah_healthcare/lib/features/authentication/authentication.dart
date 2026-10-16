/// Authentication Feature Barrel Export
/// Follows Clean Architecture layer separation.
library;

// Domain
export 'domain/amanah_auth_user.dart';
export 'domain/failures/auth_failure.dart';
export 'domain/region_item.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/staff_credential_model.dart';
export 'domain/staff_onboarding_poli_option.dart';
export 'domain/user_avatar.dart';
export 'domain/usecases/change_password.dart';
export 'domain/usecases/request_password_reset.dart';
export 'domain/usecases/reset_password.dart';
export 'domain/usecases/restore_session.dart';
export 'domain/usecases/sign_in_with_email.dart';
export 'domain/usecases/sign_in_with_google.dart';
export 'domain/usecases/sign_out.dart';
export 'domain/usecases/submit_staff_onboarding.dart';
export 'domain/usecases/verify_otp.dart';

// Data
export 'data/amanah_auth_repository.dart';
export 'data/amanah_auth_token_storage.dart';
export 'data/datasources/google_auth_service.dart';
export 'data/dto/staff_onboarding_dto.dart';
export 'data/region_api_service.dart';
export 'data/staff_credential_repository.dart';

// Presentation
export 'presentation/screen/auth_bottom_sheet_screen.dart';
export 'presentation/screen/staff_onboarding_screen.dart';
export 'presentation/state/auth_ui_state.dart';
export 'presentation/state/staff_onboarding_controller.dart';
