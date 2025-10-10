import 'package:aplikasi_monitoring/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aplikasi_monitoring/presentation/pages/register_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isBiometricAvailable = false;
  String _lastUserEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  // Fungsi untuk memuat sesi terakhir dari local storage
  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEmail = prefs.getString('lastUserEmail');
    if (lastEmail != null && lastEmail.isNotEmpty) {
      setState(() {
        _emailController.text = lastEmail;
        _lastUserEmail = lastEmail;
        _isBiometricAvailable = true;
      });
    }
  }

  // Fungsi untuk menyimpan sesi setelah login berhasil
  Future<void> _saveUserSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastUserEmail', email);
  }

  void _login() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      await authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      // Simpan sesi email setelah berhasil login
      await _saveUserSession(_emailController.text);
      // Navigasi selanjutnya akan ditangani oleh AuthGate secara otomatis
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Login Gagal'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loginWithBiometrics() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final didAuthenticate = await authService.authenticateWithBiometrics();
    
    // NOTE: Logika ini disederhanakan.
    // Login biometrik yang aman seharusnya menggunakan token yang disimpan di Secure Storage,
    // bukan password. Untuk saat ini, kita hanya akan memvalidasi sidik jari.
    // Jika berhasil, AuthGate akan mendeteksi sesi login Firebase yang sudah ada
    // dari startup aplikasi sebelumnya dan melanjutkan.
    if (didAuthenticate) {
        // Cukup biarkan AuthGate yang bekerja jika user sudah login.
        // Jika tidak, tampilkan pesan.
        if (FirebaseAuth.instance.currentUser == null) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                content: Text('Sesi tidak ditemukan. Silakan login dengan password terlebih dahulu.'),
                backgroundColor: Colors.orange,
                ),
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.eco, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              if (_lastUserEmail.isNotEmpty)
                Text(
                  _lastUserEmail,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Login'),
                    ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                // Tombol akan nonaktif jika _isBiometricAvailable bernilai false
                onPressed: _isBiometricAvailable ? _loginWithBiometrics : null,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Login dengan Sidik Jari'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[200], // Warna saat nonaktif
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum punya akun?"),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ));
                    },
                    child: const Text('Daftar di sini'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}