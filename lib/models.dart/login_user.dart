class LoginUser {
  String userId, username;
  LoginUser(this.userId, this.username);

  static LoginUser currentLoginUser = LoginUser("", "");
}
