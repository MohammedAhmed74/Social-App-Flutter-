abstract class SocialLoginStates {}

class initialSocialLoginState extends SocialLoginStates {}

class ShowPasswordState extends SocialLoginStates {}

class LoadingLoginState extends SocialLoginStates {}

class SuccessLoginState extends SocialLoginStates {}

class ErrorLoginState extends SocialLoginStates {
  late dynamic error;
  ErrorLoginState(this.error);
}

class SuccessRegisterState extends SocialLoginStates {}

class ErrorRegisterState extends SocialLoginStates {
  late dynamic error;
  ErrorRegisterState(this.error);
}
