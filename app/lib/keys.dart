import 'package:flutter/foundation.dart';

typedef K = Keys;

class Keys {
  const Keys();

  static const usernameTextField = Key('usernameTextField');
  static const passwordTextField = Key('passwordTextField');
  static const loginButton = Key('loginButton');
  static const forgotPasswordButton = Key('forgotPasswordButton');
  static const privacyPolicyLink = Key('privacyPolicyLink');
}
