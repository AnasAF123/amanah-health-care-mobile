class PasswordRequirement {
  const PasswordRequirement({
    required this.label,
    required this.errorMessage,
    required this.isMet,
  });

  final String label;
  final String errorMessage;
  final bool Function(String password) isMet;
}

class PasswordRequirementEvaluation {
  const PasswordRequirementEvaluation({
    required this.completedCount,
    required this.totalCount,
    required this.firstUnmet,
  });

  final int completedCount;
  final int totalCount;
  final PasswordRequirement? firstUnmet;

  bool get isComplete => completedCount == totalCount;
}

class AmanahPasswordRequirements {
  const AmanahPasswordRequirements._();

  static const int minLength = 8;

  static final List<PasswordRequirement> rules = <PasswordRequirement>[
    PasswordRequirement(
      label: 'Minimal 8 karakter',
      errorMessage: 'Password minimal 8 karakter.',
      isMet: (String password) => password.length >= minLength,
    ),
    PasswordRequirement(
      label: 'Gunakan huruf besar dan kecil',
      errorMessage: 'Gunakan huruf besar dan kecil.',
      isMet: (String password) =>
          RegExp('[a-z]').hasMatch(password) &&
          RegExp('[A-Z]').hasMatch(password),
    ),
    PasswordRequirement(
      label: 'Tambahkan angka',
      errorMessage: 'Tambahkan minimal satu angka.',
      isMet: (String password) => RegExp('[0-9]').hasMatch(password),
    ),
    PasswordRequirement(
      label: 'Tambahkan simbol',
      errorMessage: 'Tambahkan minimal satu simbol.',
      isMet: (String password) => RegExp(
        r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~']''',
      ).hasMatch(password),
    ),
  ];

  static PasswordRequirementEvaluation evaluate(String password) {
    final int completedCount = rules
        .where((PasswordRequirement requirement) => requirement.isMet(password))
        .length;
    PasswordRequirement? firstUnmet;
    for (final PasswordRequirement requirement in rules) {
      if (!requirement.isMet(password)) {
        firstUnmet = requirement;
        break;
      }
    }

    return PasswordRequirementEvaluation(
      completedCount: completedCount,
      totalCount: rules.length,
      firstUnmet: firstUnmet,
    );
  }

  static String? validate(String? value, {required String requiredMessage}) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return requiredMessage;
    }

    final PasswordRequirementEvaluation evaluation = evaluate(password);
    return evaluation.firstUnmet?.errorMessage;
  }
}
