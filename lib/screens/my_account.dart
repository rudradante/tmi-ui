// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tmiui/config/config_provider.dart';
import 'package:tmiui/custom_widgets/custom_scaffold.dart';
import 'package:tmiui/custom_widgets/custom_text.dart';
import 'package:tmiui/custom_widgets/message_dialog.dart';
import 'package:tmiui/custom_widgets/text_field.dart';
import 'package:tmiui/helpers/file_system.dart';
import 'package:tmiui/models.dart/tmi_datetime.dart';
import 'package:tmiui/screens/plan_dashboard.dart';
import 'package:tmiui/screens/review.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../custom_widgets/custom_flat_button.dart';
import '../extensions/color.dart';
import '../models.dart/account.dart';
import '../models.dart/plan.dart';
import 'login.dart';

class MyAccountScreen extends StatefulWidget {
  final bool isSignUpFlow;
  final List<Plan> plans;
  final Account? account; // true if during signup
  const MyAccountScreen(
      {super.key,
      this.isSignUpFlow = false,
      required this.plans,
      required this.account});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  int _selectedIndex = 0;
  bool _isTermsAccepted = false;

  // Common Controllers for both flows
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool isOtpVisible = false;
  bool isEmailVerified = false;
  bool isVerifying = false;
  bool emailFieldEnabled = true;

  @override
  void initState() {
    super.initState();
    _firstName.text = widget.account?.firstName ?? "";
    _lastName.text = widget.account?.lastName ?? "";
    _email.text = widget.account?.email ?? "";

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      isVerifying = true;
    });

    var loginUser = await Account.createAccount(
        _firstName.text.trim(),
        _lastName.text.trim(),
        _email.text.trim(),
        _otp.text.trim(),
        _password.text.trim(),
        context);

    if (loginUser != null) {
      setState(() {
        isEmailVerified = true;
        isOtpVisible = false;
        emailFieldEnabled = false;
        isVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified successfully!')),
      );
    } else {
      setState(() {
        isVerifying = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP.')),
      );
    }
  }

  dynamic validateAndInitiateAccountSignup() async {
    if (_firstName.text.trim().isEmpty) {
      return showMessageDialog(
          "Invalid details", "First name cannot be empty", context);
    }
    if (_lastName.text.trim().isEmpty) {
      return showMessageDialog(
          "Invalid details", "Last name cannot be empty", context);
    }
    if (_password.text.trim().length < 8) {
      return showMessageDialog("Invalid details",
          "Password must be at least of 8 characters", context);
    }
    if (_password.text.trim() != _confirmPassword.text.trim()) {
      return showMessageDialog(
          "Invalid details", "Passwords do not match", context);
    }
    if (!_email.text.contains('@')) {
      return showMessageDialog(
          "Invalid details", "Please enter correct email", context);
    }
    var sent = await Account.initiateSignUp(_firstName.text.trim(),
        _lastName.text.trim(), _email.text.trim(), context);
    if (!sent) return;
    setState(() {
      isOtpVisible = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP sent to ${_email.text}')),
    );
  }

  Widget _buildPersonalInfoTab() {
    if (!widget.isSignUpFlow) {
      isEmailVerified = true;
    }
    return Container(
      constraints: BoxConstraints(maxWidth: 640),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(controller: _firstName, label: 'First Name'),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _lastName,
                label: 'Last Name ',
              ),
              const SizedBox(height: 10),
              widget.isSignUpFlow
                  ? CustomTextField(
                      controller: _password,
                      label: 'Password',
                      hiddenText: true,
                      toggleView: true,
                    )
                  : SizedBox(),
              const SizedBox(height: 10),
              widget.isSignUpFlow
                  ? CustomTextField(
                      controller: _confirmPassword,
                      label: 'Confirm Password',
                      hiddenText: true,
                      toggleView: true,
                    )
                  : SizedBox(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _email,
                      readOnly: isEmailVerified,
                      label: 'Email',
                      suffixIcon: isEmailVerified
                          ? const Icon(Icons.verified, color: Colors.green)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  isEmailVerified
                      ? SizedBox()
                      : CustomFlatButton(
                          isOutlined: true,
                          text: isOtpVisible ? 'Resend OTP' : 'Send OTP',
                          color: HexColor.fromHex(
                              ConfigProvider.getThemeConfig()
                                  .primaryButtonColor),
                          onTap: validateAndInitiateAccountSignup,
                        ),
                ],
              ),
              if (isOtpVisible) ...[
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _otp,
                  maxLength: 6,
                  label: 'Enter 6-digit OTP',
                ),
                const SizedBox(height: 8),
                CustomFlatButton(
                  isOutlined: false,
                  text: 'Verify OTP',
                  color: HexColor.fromHex(
                      ConfigProvider.getThemeConfig().primaryButtonColor),
                  onTap: isVerifying ? null : _verifyOtp,
                ),
              ],
              const SizedBox(height: 30),
              if (widget.isSignUpFlow) ...[
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isTermsAccepted,
                      onChanged: (bool? value) {
                        setState(() {
                          _isTermsAccepted = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // You can navigate to a Terms & Conditions screen here if needed
                          launchUrlString("https://www.google.com");
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: 'I agree to the ',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black87),
                            children: [
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              CustomFlatButton(
                  isOutlined: false,
                  text: 'Save & Continue',
                  color: HexColor.fromHex(
                      ConfigProvider.getThemeConfig().primaryButtonColor),
                  onTap: () {
                    if (!_isTermsAccepted && widget.isSignUpFlow) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please accept Terms & Conditions first.')),
                      );
                      return 1;
                    }
                    if (_formKey.currentState!.validate()) {
                      if (widget.isSignUpFlow && !isEmailVerified) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please verify your email.')),
                        );
                      } else if (widget.isSignUpFlow) {
                        PlanDashboardRoute.push(context);
                      } else {
                        if (_firstName.text.trim().isEmpty) {
                          return showMessageDialog("Invalid details",
                              "First name cannot be empty", context);
                        }
                        if (_lastName.text.trim().isEmpty) {
                          return showMessageDialog("Invalid details",
                              "Last name cannot be empty", context);
                        }
                        Account.updateAccount(
                            _firstName.text, _lastName.text, context);
                      }
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    Color titleColor =
        HexColor.fromHex(ConfigProvider.getThemeConfig().primaryButtonColor);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search plans by title...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Tabs
          TabBar(
            labelColor: titleColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: titleColor,
            tabs: [
              Tab(text: 'Upcoming Plans'),
              Tab(text: 'Completed Plans'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPlanList(true), // Upcoming
                _buildPlanList(false), // Completed
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanList(bool upcoming) {
    final now = TmiDateTime.now().getMillisecondsSinceEpoch();
    final filteredPlans = widget.plans.where((plan) {
      final titleMatch =
          plan.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final isUpcoming = plan.startTime.getMillisecondsSinceEpoch() > now;
      return titleMatch && (upcoming ? isUpcoming : !isUpcoming);
    }).toList();

    if (filteredPlans.isEmpty) {
      return Center(child: Text('No matching plans found.'));
    }

    return ListView(
      children: filteredPlans.map((e) => PlanCard(plan: e)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showTabs = !widget.isSignUpFlow;

    return CustomScaffold(
      title: widget.isSignUpFlow ? 'Sign Up' : 'My Account',
      appBarTitleSize: 32,
      appBarBackgroundColor: HexColor.fromHex(
          ConfigProvider.getThemeConfig().scaffoldBackgroundColor),
      scaffoldBackgroundColor: Colors.white,
      actions: [
        !widget.isSignUpFlow
            ? InkWell(
                onTap: onPressed,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  CustomText(
                      text: "Logout",
                      size: 12,
                      color: HexColor.fromHex(ConfigProvider.getThemeConfig()
                          .appBarForegroundColor)),
                  SizedBox(width: 4),
                  Icon(Icons.logout,
                      color: HexColor.fromHex(ConfigProvider.getThemeConfig()
                          .appBarForegroundColor)),
                  SizedBox(width: 4)
                ]),
              )
            : SizedBox()
      ],
      centerWidget: SizedBox(
          height: CustomScaffold.bodyHeight,
          child: _selectedIndex == 0
              ? _buildPersonalInfoTab()
              : _buildDashboardTab()),
      bottomAppBar: showTabs
          ? BottomNavigationBar(
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              selectedLabelStyle:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              unselectedLabelStyle: TextStyle(color: Colors.white),
              backgroundColor: HexColor.fromHex(
                  ConfigProvider.getThemeConfig().scaffoldBackgroundColor),
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.person, color: Colors.white),
                    label: 'Personal Info',
                    backgroundColor: HexColor.fromHex(
                        ConfigProvider.getThemeConfig()
                            .scaffoldBackgroundColor)),
                BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard, color: Colors.white),
                    label: 'My Dashboard',
                    backgroundColor: HexColor.fromHex(
                        ConfigProvider.getThemeConfig()
                            .scaffoldBackgroundColor)),
              ],
            )
          : null,
    );
  }

  void onPressed() {
    AppFile.delete("refresh_token");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false);
  }
}

class PlanCard extends StatelessWidget {
  final Plan plan;

  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final bool isReviewed = plan.review != null;
    String duration = plan.startTime.getTimeDifferenceInDuration(plan.endTime);
    final bool isUpcomingPlan = plan.startTime.getMillisecondsSinceEpoch() >
        TmiDateTime.now().getMillisecondsSinceEpoch();
    return InkWell(
      onTap: () async {
        if (isUpcomingPlan) {
          await PlanDashboardRoute.push(context, selectedPlan: plan);
        } else {
          await ReviewPlansRoute.push(context, [],
              initialDateTime: plan.startTime.toMinDate());
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade100,
              Colors.purple.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        "🕒 Start: ${plan.startTime.getTimeAsString()}, ${plan.startTime.getDateAsString()}",
                        style: TextStyle(color: Colors.grey[800])),
                    Text(
                        "🕔 End: ${plan.endTime.getTimeAsString()}, ${plan.endTime.getDateAsString()}",
                        style: TextStyle(color: Colors.grey[800])),
                    Text("⏳ Duration: $duration",
                        style: TextStyle(color: Colors.grey[800])),
                  ],
                ),
              ),
              isUpcomingPlan
                  ? SizedBox()
                  :
                  // Review Badge
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isReviewed ? Colors.green[600] : Colors.red[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isReviewed
                            ? '${plan.review!.percentage.toStringAsFixed(0)}%'
                            : 'Not Reviewed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAccountRoute {
  static Future push(BuildContext context, bool isSignUpFlow) async {
    List<Plan> plans = [];
    Account? account;
    if (!isSignUpFlow) {
      plans = await Plan.getAllPlans(null, context);
      plans.sort((a, b) => b.startTime
          .getMillisecondsSinceEpoch()
          .compareTo(a.startTime.getMillisecondsSinceEpoch()));
      account = await Account.getAccountDetails(context);
      if (account == null) return;
    }
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyAccountScreen(
                isSignUpFlow: isSignUpFlow, plans: plans, account: account)));
  }
}
