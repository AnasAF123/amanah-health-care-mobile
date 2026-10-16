/// Core contract for Clean Architecture Use Cases.
/// Every application business transaction implements this contract.
abstract interface class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Represents the absence of parameters for a UseCase.
final class NoParams {
  const NoParams();
}
