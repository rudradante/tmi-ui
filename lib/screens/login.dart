import 'package:flutter/material.dart';
import 'package:tmiui/custom_widgets/text_field.dart';
import 'package:tmiui/helpers/file_system.dart';
import 'package:tmiui/models.dart/login_user.dart';
import 'package:tmiui/screens/my_account.dart';
import 'package:tmiui/screens/plan_dashboard.dart';

import '../config/config_provider.dart';
import '../custom_widgets/custom_flat_button.dart';
import '../custom_widgets/custom_scaffold.dart';
import '../extensions/color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // Simulate login call
    var loginUser = await LoginUser.login(usernameController.text.trim(),
        passwordController.text.trim(), context);

    setState(() => isLoading = false);

    //if (loginUser == null) return;
    // Navigate on successful login (dummy logic)
    PlanDashboardRoute.push(context);
  }

  void checkLoggedIn() async {
    var refreshToken = AppFile.readAsString("refresh_token");
    if (refreshToken != null && refreshToken.isNotEmpty) {
      var lu = await LoginUser.refresh(refreshToken, context);
      if (lu != null) {
        await PlanDashboardRoute.push(context);
      } else {
        AppFile.delete("refresh_token");
      }
    }
  }

  void goToSignup() {
    MyAccountRoute.push(context, true);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Login",
      leadingAppbarWidget: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset("assets/icons/empty.png", width: 16, height: 16),
      ),
      showBackButton: false,
      appBarTitleSize: 32,
      appBarBackgroundColor: HexColor.fromHex(
          ConfigProvider.getThemeConfig().scaffoldBackgroundColor),
      scaffoldBackgroundColor: Colors.white,
      centerWidget: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/empty.png", width: 128, height: 128),
              SizedBox(height: 20),
              CustomTextField(controller: usernameController, label: "Email"),
              Padding(padding: EdgeInsets.all(8)),
              CustomTextField(
                  hiddenText: true,
                  controller: passwordController,
                  label: "Password"),
              const SizedBox(height: 10),
              CustomFlatButton(
                  isOutlined: false,
                  text: 'Login',
                  color: HexColor.fromHex(
                      ConfigProvider.getThemeConfig().primaryButtonColor),
                  onTap: login),
              const SizedBox(height: 10),
              TextButton(
                onPressed: goToSignup,
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
