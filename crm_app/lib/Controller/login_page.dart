import 'package:crm_app/app/dashboard.dart';
import 'package:crm_app/utilities/user_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/app/forgot_password.dart';
import 'package:crm_app/API/auth_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color kPrimaryBlue = Color(0xFF1D648B);
const Color kDarkText = Color(0xFF333333);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _showPassword = false;
  bool _rememberMe = false;

  final _authService =
  AuthApiService('https://dashboard.reachinternational.co.in/development/api');

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  // ------------------------------------------------------------------
  // LOAD SAVED CREDENTIALS
  // ------------------------------------------------------------------
  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    _rememberMe = prefs.getBool("remember_me") ?? false;

    if (_rememberMe) {
      emailController.text = prefs.getString("saved_email") ?? "";
      passwordController.text = prefs.getString("saved_password") ?? "";
    }

    setState(() {});
  }

  // ------------------------------------------------------------------
  // SAVE CREDENTIALS
  // ------------------------------------------------------------------
  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    if (_rememberMe) {
      await prefs.setBool("remember_me", true);
      await prefs.setString("saved_email", email);
      await prefs.setString("saved_password", password);
    } else {
      await prefs.remove("remember_me");
      await prefs.remove("saved_email");
      await prefs.remove("saved_password");
    }
  }

  // ------------------------------------------------------------------
  // LOGIN
  // ------------------------------------------------------------------
  Future<void> doLogin() async {
    try {
      final res = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.success == 1 && res.data != null) {
        await UserLocalStorage.saveUserLocally(res.data!, res.token);

        // SAVE OR CLEAR CREDENTIALS 😊
        await saveCredentials(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        await saveLoginTime();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        _showError(res.message ?? "Something went wrong");
      }
    } catch (e) {
      print('Login exception: $e');
      _showError("Login failed. Try again.");
    }
  }

  Future<void> saveLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset('assets/logo-reach-site.jpg'),
                const SizedBox(height: 50),

                // ================= EMAIL =====================
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Username or Email',
                    prefixIcon: Icon(Icons.person, color: kDarkText),
                  ),
                  validator: (value) =>
                  value!.trim().isEmpty ? "Email cannot be empty" : null,
                ),
                const SizedBox(height: 20),

                // ================= PASSWORD =====================
                TextFormField(
                  controller: passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: kDarkText),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: kDarkText,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: (value) =>
                  value!.trim().isEmpty ? "Password cannot be empty" : null,
                ),
                const SizedBox(height: 10),

                // ================= REMEMBER ME =====================
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: kPrimaryBlue,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text("Remember Me"),
                  ],
                ),
                const SizedBox(height: 10),

                // ================= LOGIN BUTTON =====================
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      doLogin();
                    }
                  },
                  child: const Text('LOG IN'),
                ),

                const SizedBox(height: 20),

                // ================= FORGOT PASSWORD =====================
                TextButton(
                  onPressed: () {
                    if (emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter email first")),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text('Forgot Password?',
                      style: TextStyle(color: kPrimaryBlue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}