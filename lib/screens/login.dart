import 'package:flutter/material.dart';
import 'package:tmiui/models.dart/login_user.dart';
import 'package:tmiui/screens/plan_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void checkLoggedIn() async {
    LoginUser.currentLoginUser = LoginUser("test", "testusername");
    PlanDashboardRoute.push(context);
  }
}
