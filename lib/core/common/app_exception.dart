/// The app's error vocabulary.
///
/// Every failure that can reach the UI is one of these types, and each carries
/// a user-facing [message], so screens render a small, stable set of error
/// states instead of raw exceptions. A new app adds its own cases here.
///
/// `sealed` lets the compiler check that a `switch` over an [AppException]
/// handles every subtype.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Copy that is safe to show to the user.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The (fake) network call failed.
final class NetworkException extends AppException {
  const NetworkException()
    : super("Couldn't reach the server. Check your connection and try again.");
}

/// The server's data could not be decoded (malformed JSON, unexpected types,
/// or a record that breaks the app's rules, such as a task with no title).
final class DataFormatException extends AppException {
  const DataFormatException()
    : super("The server's data looks damaged. Please try again.");
}

/// The item no longer exists (or never did: a stale link).
final class NotFoundException extends AppException {
  /// [what] names the record: "That task doesn't exist any more."
  const NotFoundException([String what = 'item'])
    : super("That $what doesn't exist any more.");
}

/// Input that breaks a rule, with what to fix ([message]). The forms show
/// the same rules under their fields; this is what a use case answers when
/// something slips past them.
final class InvalidInputException extends AppException {
  const InvalidInputException(super.message);
}

/// Anything unexpected that isn't one of the cases above.
final class UnknownException extends AppException {
  const UnknownException() : super('Something went wrong. Please try again.');
}
