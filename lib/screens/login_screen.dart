import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // untuk deteksi web
import '../utils/app_colors.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ================= EMAIL & PASSWORD LOGIN =================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      _navigateToDashboard();
    } on FirebaseAuthException catch (e) {
      String message = "Login gagal";
      if (e.code == 'user-not-found')
        message = "Email tidak terdaftar";
      else if (e.code == 'wrong-password')
        message = "Password salah";
      _showError(message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= GOOGLE LOGIN =================
  Future<void> _loginWithGoogle() async {
    try {
      setState(() => _isLoading = true);

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb
            ? "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com" // <-- Ganti dengan Web Client ID Firebase
            : null,
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return; // user batal login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      _navigateToDashboard();
    } catch (e) {
      _showError("Login Google gagal: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Selamat Datang 👋",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Login untuk melanjutkan",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "Email tidak boleh kosong"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "Password tidak boleh kosong"
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // LOGIN BUTTON
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Login"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text("atau"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // GOOGLE LOGIN BUTTON
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _loginWithGoogle,
                      icon: Image.asset("assets/images/google.png", width: 22),
                      label: const Text("Login dengan Google"),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
