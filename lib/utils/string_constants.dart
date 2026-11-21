abstract class RegisterViewConstants {
  static const String registerViewAppBarTitle = 'Create Account';
  static const String registerViewHeading = 'Get Started';
  static const String registerViewSubHeading =
      'Join and start chatting with users instantly';
  static const String registerViewNameLabel = 'Full Name';
  static const String registerViewNameHint = 'John Doe';
  static const String registerViewEmailLabel = 'Email Address';
  static const String registerViewEmailHint = 'user@example.com';
  static const String registerViewPasswordLabel = 'Password';
  static const String registerViewConfirmPasswordLabel = 'Confirm Password';
  static const String registerViewNameRequiredError = 'Please enter your name';
  static const String registerViewEmailRequiredError =
      'Please enter your email';
  static const String registerViewEmailInvalidError =
      'Please enter a valid email address';
  static const String registerViewPasswordRequiredError =
      'Please enter a password';
  static const String registerViewPasswordLengthError =
      'Password must be at least 6 characters';
  static const String registerViewConfirmPasswordRequiredError =
      'Please confirm your password';
  static const String registerViewPasswordMismatchError =
      'Passwords do not match';
  static const String registerViewAlreadyHaveAccount =
      'Already have an account? ';
  static const String registerViewLoginAction = 'Login';
  static const String registerViewFailedSnackBar =
      'Registration failed. Please try again.';
  static const String registerViewSignInAction = 'Sign in';
}

abstract class LoginViewConstants {
  static const String loginViewHeading = 'Welcome Back';
  static const String loginViewSubHeading =
      'Sign in to connect with friends in real-time';
  static const String loginViewEmailInvalidError = 'Please enter a valid email';
  static const String loginViewSubmitButton = 'Sign In';
  static const String loginViewDontHaveAccount = "Don't have an account? ";
  static const String loginViewSignUpAction = 'Sign Up';
  static const String loginViewFailedSnackBar =
      'Login failed. Please check your credentials.';
}

abstract class ChatViewConstants {
  static const String messageDateFormate = 'hh:mm a';
  static const String messageError = 'Error loading messages';
  static const String noMessage = 'No messages yet';
  static const String sayHello = 'Say hello to';
  static const String typeMessage = 'Type a message...';
}

abstract class HomeViewConstants {
  static const String homeViewAppBarTitle = 'Live Chat';
  static const String homeViewLogout = 'Logout';
  static const String homeViewLogoutConfirmMessage =
      'Are you sure you want to sign out?';
  static const String homeViewCancel = 'Cancel';
  static const String homeViewErrorLoadingUsers = 'Error loading users: ';
  static const String homeViewNoUsersHeading = 'No other users yet';
  static const String homeViewNoUsersSubHeading =
      'Register another account on a different device/tab to test live chat!';
  static const String homeViewDefaultUserInitial = 'U';
}
