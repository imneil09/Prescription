import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/local_db.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDb.init(); // Initialize local storage
  runApp(const DoctorPrescriptionApp());
}

class DoctorPrescriptionApp extends StatelessWidget {
  const DoctorPrescriptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dr. Rx Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const PinLoginScreen(),
    );
  }
}