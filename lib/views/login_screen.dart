import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'prescription_screen.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  final String _correctPin = "1234";
  String _errorMessage = "";
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (_pinController.text == _correctPin) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const PrescriptionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      setState(() {
        _errorMessage = "Invalid Access PIN";
        _isLoading = false;
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(48.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 60, spreadRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.health_and_safety, size: 64, color: Theme.of(context).colorScheme.primary),
                  ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  const Text("Dr. Rx Portal", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)).animate().fadeIn(delay: 300.ms),
                  Text("Secure Offline Workspace", style: TextStyle(color: Colors.grey.shade600)).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, letterSpacing: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '••••',
                      hintStyle: TextStyle(color: Colors.grey.shade300, letterSpacing: 16),
                    ),
                    onSubmitted: (_) => _login(),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)).animate().shake(),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("AUTHENTICATE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
          // FOOTER
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: const Text(
                "Designed & Developed by Rashi – Proudly Made in India",
                style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 0.5),
              ).animate().fadeIn(delay: 800.ms),
            ),
          )
        ],
      ),
    );
  }
}