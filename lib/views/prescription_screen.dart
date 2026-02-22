import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/pdf_generator.dart';
import '../utils/local_db.dart';
import '../widgets/auto_suggest_field.dart';
import 'login_screen.dart'; // Imported to enable Logout navigation

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _medNameCtrl = TextEditingController();
  final _medDoseCtrl = TextEditingController();
  final _medDurationCtrl = TextEditingController();
  final _adviceCtrl = TextEditingController();

  List<Map<String, String>> medicines = [];
  Timer? _debounce;

  // NEW: Controls the visibility of the PDF Preview
  bool _showPreview = false;

  void _onDataChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() {});
    });
  }

  void _addMedicine() {
    if (_medNameCtrl.text.isNotEmpty) {
      setState(() {
        medicines.add({
          'name': _medNameCtrl.text,
          'dose': _medDoseCtrl.text,
          'duration': _medDurationCtrl.text,
        });
        _medNameCtrl.clear();
        _medDoseCtrl.clear();
        _medDurationCtrl.clear();
      });
      _onDataChanged();
    }
  }

  void _saveToDb() {
    LocalDb.saveSuggestion('patient_names', _nameCtrl.text);
    LocalDb.saveSuggestion('diagnoses', _diagnosisCtrl.text);
    LocalDb.saveSuggestion('advices', _adviceCtrl.text);
    for (var med in medicines) {
      LocalDb.saveSuggestion('medicines', med['name']!);
      LocalDb.saveSuggestion('doses', med['dose']!);
      LocalDb.saveSuggestion('durations', med['duration']!);
    }
  }

  Map<String, dynamic> _getFormData() {
    return {
      'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
      'patientName': _nameCtrl.text,
      'age': _ageCtrl.text,
      'gender': _genderCtrl.text,
      'bp': _bpCtrl.text,
      'weight': _weightCtrl.text,
      'diagnosis': _diagnosisCtrl.text,
      'medicines': medicines,
      'advice': _adviceCtrl.text,
    };
  }

  void _clearForm() {
    setState(() {
      _nameCtrl.clear(); _ageCtrl.clear(); _genderCtrl.clear();
      _bpCtrl.clear(); _weightCtrl.clear(); _diagnosisCtrl.clear();
      _adviceCtrl.clear(); medicines.clear();
    });
    _onDataChanged();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PinLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 900;

    Widget formWidget = SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            title: 'Patient Profile',
            icon: Icons.person_outline,
            child: Row(
              children: [
                Expanded(flex: 3, child: AutoSuggestField(controller: _nameCtrl, label: 'Patient Name', dbKey: 'patient_names', onChanged: _onDataChanged)),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: TextField(controller: _ageCtrl, onChanged: (_) => _onDataChanged(), decoration: const InputDecoration(labelText: 'Age'))),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: TextField(controller: _genderCtrl, onChanged: (_) => _onDataChanged(), decoration: const InputDecoration(labelText: 'Gender'))),
              ],
            ),
          ).animate().fadeIn().slideX(),

          _buildCard(
              title: 'Clinical Findings',
              icon: Icons.monitor_heart_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _bpCtrl, onChanged: (_) => _onDataChanged(), decoration: const InputDecoration(labelText: 'Blood Pressure (mmHg)'))),
                      const SizedBox(width: 16),
                      Expanded(child: TextField(controller: _weightCtrl, onChanged: (_) => _onDataChanged(), decoration: const InputDecoration(labelText: 'Weight (kg)'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AutoSuggestField(controller: _diagnosisCtrl, label: 'Primary Diagnosis / Symptoms', dbKey: 'diagnoses', maxLines: 2, onChanged: _onDataChanged),
                ],
              )
          ).animate().fadeIn(delay: 100.ms).slideX(),

          _buildCard(
              title: 'Rx Medications',
              icon: Icons.medication_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 3, child: AutoSuggestField(controller: _medNameCtrl, label: 'Medicine', dbKey: 'medicines')),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: AutoSuggestField(controller: _medDoseCtrl, label: 'Dose', dbKey: 'doses')),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: AutoSuggestField(controller: _medDurationCtrl, label: 'Duration', dbKey: 'durations')),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: _addMedicine,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  if (medicines.isNotEmpty) const SizedBox(height: 16),
                  ...medicines.asMap().entries.map((entry) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.white, child: Text('${entry.key + 1}')),
                      title: Text(entry.value['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${entry.value['dose']} • ${entry.value['duration']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () { setState(() => medicines.removeAt(entry.key)); _onDataChanged(); },
                      ),
                    ),
                  )).toList()
                ],
              )
          ).animate().fadeIn(delay: 200.ms).slideX(),

          _buildCard(
            title: 'Recommendations',
            icon: Icons.lightbulb_outline,
            child: AutoSuggestField(controller: _adviceCtrl, label: 'Advice, Diet, or Investigations', dbKey: 'advices', maxLines: 3, onChanged: _onDataChanged),
          ).animate().fadeIn(delay: 300.ms).slideX(),
        ],
      ),
    );

    Widget previewWidget = Container(
      color: Colors.grey.shade200,
      child: PdfPreview(
        build: (format) => PdfGenerator.generatePdfBytes(_getFormData(), format),
        allowPrinting: true,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        scrollViewDecoration: BoxDecoration(color: Colors.grey.shade200),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 50
      appBar: AppBar(
        title: const Text('Prescription Workspace', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // 1. LOGOUT BUTTON
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onPressed: _logout,
          ),
          const SizedBox(width: 16),

          // 2. TOGGLE PREVIEW BUTTON (Only on Desktop/Wide Screens)
          if (isWide)
            TextButton.icon(
              icon: Icon(_showPreview ? Icons.dock_rounded : Icons.picture_as_pdf, color: Theme.of(context).colorScheme.primary),
              label: Text(_showPreview ? "Hide Preview" : "Show Preview", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              onPressed: () {
                setState(() => _showPreview = !_showPreview);
                _onDataChanged(); // Force update preview rendering
              },
            ),
          const SizedBox(width: 16),

          // 3. CLEAR BUTTON
          TextButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            label: const Text("Clear", style: TextStyle(color: Colors.grey)),
            onPressed: _clearForm,
          ),
          const SizedBox(width: 16),

          // 4. SAVE & PRINT BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('SAVE & PRINT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6), // Teal
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () async {
                _saveToDb();
                await Printing.layoutPdf(
                  onLayout: (format) => PdfGenerator.generatePdfBytes(_getFormData(), format),
                  name: 'Rx_${_nameCtrl.text}',
                );
              },
            ),
          )
        ],
      ),
      body: isWide
          ? Row(
          children: [
            // Form takes up 100% width if preview is hidden, otherwise takes 55%
            Expanded(flex: 5, child: formWidget),
            // Preview Panel (Animates in when toggled)
            if (_showPreview)
              Expanded(flex: 4, child: previewWidget.animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0))
          ])
          : DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [Tab(text: "Edit Prescription"), Tab(text: "Live Preview")],
              labelColor: Colors.blue,
            ),
            Expanded(child: TabBarView(children: [formWidget, previewWidget]))
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: Colors.grey.shade100)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}