import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

class UploadAvatarParams {
  const UploadAvatarParams({
    this.fileBytes,
    this.filePath,
    this.fileName = 'avatar.jpg',
    this.useAuthAlias = false,
  });

  final List<int>? fileBytes;
  final String? filePath;
  final String fileName;
  final bool useAuthAlias;
}

class UploadAvatarUseCase implements UseCase<UserAvatar, UploadAvatarParams> {
  const UploadAvatarUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<UserAvatar> call(UploadAvatarParams params) {
    return _repository.uploadAvatar(
      fileBytes: params.fileBytes,
      filePath: params.filePath,
      fileName: params.fileName,
      useAuthAlias: params.useAuthAlias,
    );
  }
}
