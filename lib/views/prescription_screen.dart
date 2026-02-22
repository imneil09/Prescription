import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/pdf_generator.dart';
import '../utils/local_db.dart';
import '../widgets/auto_suggest_field.dart';
import 'login_screen.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _adviceCtrl = TextEditingController();

  // Dropdown States
  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  List<String> _selectedPastHistory = [];
  final List<String> _pastHistoryOptions = ['APD', 'HTN', 'Asthma', 'DM2', 'Hypothyroid', 'Drug Allergy', 'Fever', 'Cough', 'Respiratory Distress', 'None'];

  String? _selectedDiet;
  final List<String> _dietOptions = ['High Protein Diet', 'Low Salt Diet', 'Diabetic Diet', 'Soft Diet', 'Liquid Diet', 'Normal Diet'];

  String? _selectedInvestigation;
  final List<String> _investigationOptions = ['CBC', 'ESR', 'CRP', 'X-ray', 'MRI', 'CT Scan', 'LFT', 'KFT', 'Blood Sugar (Fasting)', 'Blood Sugar (PP)', 'HbA1c'];
  List<String> _selectedInvestigations = [];

  // Medicine Table States
  final _medNameCtrl = TextEditingController();
  final _medDoseCtrl = TextEditingController(); // Frequency (e.g. 1-0-1)

  String _selectedTiming = 'After Food';
  final List<String> _timingOptions = ['Before Food', 'After Food', 'Empty Stomach'];

  String _selectedQuantity = '1';
  final List<String> _quantityOptions = ['1', '1/2', '2', '5 ml', '10 ml', '1 tsp', '2 tsp'];

  String _selectedDuration = '5 Days';
  final List<String> _durationOptions = ['3 Days', '5 Days', '7 Days', '10 Days', '15 Days', '1 Month'];

  List<Map<String, String>> medicines = [];
  List<Map<String, String>> emptyStomachMedicines = [];

  Timer? _debounce;
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
        var newMed = {
          'name': _medNameCtrl.text,
          'dose': _medDoseCtrl.text,
          'quantity': _selectedQuantity,
          'timing': _selectedTiming,
          'duration': _selectedDuration,
        };

        if (_selectedTiming == 'Empty Stomach') {
          emptyStomachMedicines.add(newMed);
        } else {
          medicines.add(newMed);
        }

        _medNameCtrl.clear();
        _medDoseCtrl.clear();
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
    }
    for (var med in emptyStomachMedicines) {
      LocalDb.saveSuggestion('medicines', med['name']!);
      LocalDb.saveSuggestion('doses', med['dose']!);
    }
  }

  Map<String, dynamic> _getFormData() {
    return {
      'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
      'patientName': _nameCtrl.text,
      'age': _ageCtrl.text,
      'gender': _selectedGender,
      'bp': _bpCtrl.text,
      'weight': _weightCtrl.text,
      'diagnosis': _diagnosisCtrl.text,
      'pastHistory': _selectedPastHistory.join(', '),
      'diet': _selectedDiet ?? '',
      'investigations': _selectedInvestigations.join(', '),
      'advice': _adviceCtrl.text,
      'medicines': medicines,
      'emptyStomachMedicines': emptyStomachMedicines,
    };
  }

  void _clearForm() {
    setState(() {
      _nameCtrl.clear(); _ageCtrl.clear(); _selectedGender = 'Male';
      _bpCtrl.clear(); _weightCtrl.clear(); _diagnosisCtrl.clear();
      _adviceCtrl.clear(); _selectedPastHistory.clear();
      _selectedDiet = null; _selectedInvestigations.clear();
      medicines.clear(); emptyStomachMedicines.clear();
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
          // PATIENT PROFILE
          _buildCard(
            title: 'Patient Profile',
            icon: Icons.person_outline,
            child: Row(
              children: [
                Expanded(flex: 3, child: AutoSuggestField(controller: _nameCtrl, label: 'Patient Name', dbKey: 'patient_names', onChanged: _onDataChanged)),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: TextField(controller: _ageCtrl, onChanged: (_) => _onDataChanged(), decoration: const InputDecoration(labelText: 'Age'))),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: _genderOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    onChanged: (v) { setState(() => _selectedGender = v!); _onDataChanged(); },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideX(),

          // CLINICAL FINDINGS & PAST HISTORY
          _buildCard(
              title: 'Clinical Findings & History',
              icon: Icons.monitor_heart_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 16),
                  Text("Past History:", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _pastHistoryOptions.map((option) {
                      return FilterChip(
                        label: Text(option),
                        selected: _selectedPastHistory.contains(option),
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        onSelected: (bool selected) {
                          setState(() {
                            if (option == 'None' && selected) {
                              _selectedPastHistory = ['None'];
                            } else {
                              if (selected) {
                                _selectedPastHistory.remove('None');
                                _selectedPastHistory.add(option);
                              } else {
                                _selectedPastHistory.remove(option);
                              }
                            }
                          });
                          _onDataChanged();
                        },
                      );
                    }).toList(),
                  )
                ],
              )
          ).animate().fadeIn(delay: 100.ms).slideX(),

          // MEDICINES
          _buildCard(
              title: 'Rx Medications',
              icon: Icons.medication_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 3, child: AutoSuggestField(controller: _medNameCtrl, label: 'Medicine', dbKey: 'medicines')),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: AutoSuggestField(controller: _medDoseCtrl, label: 'Freq (1-0-1)', dbKey: 'doses')),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: DropdownButtonFormField<String>(value: _selectedQuantity, decoration: const InputDecoration(labelText: 'Qty'), items: _quantityOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _selectedQuantity = v!))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(flex: 3, child: DropdownButtonFormField<String>(value: _selectedTiming, decoration: const InputDecoration(labelText: 'Timing'), items: _timingOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _selectedTiming = v!))),
                      const SizedBox(width: 12),
                      Expanded(flex: 3, child: DropdownButtonFormField<String>(value: _selectedDuration, decoration: const InputDecoration(labelText: 'Duration'), items: _durationOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => _selectedDuration = v!))),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: _addMedicine,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                          child: const Text("ADD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),

                  // EMPTY STOMACH TABLE
                  if (emptyStomachMedicines.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Align(alignment: Alignment.centerLeft, child: Text("EMPTY STOMACH", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 16))),
                    const SizedBox(height: 8),
                    ...emptyStomachMedicines.asMap().entries.map((entry) => _buildMedRow(entry.key, entry.value, true)).toList()
                  ],

                  // REGULAR MEDICINES TABLE
                  if (medicines.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Align(alignment: Alignment.centerLeft, child: Text("REGULAR MEDICINES", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 16))),
                    const SizedBox(height: 8),
                    ...medicines.asMap().entries.map((entry) => _buildMedRow(entry.key, entry.value, false)).toList()
                  ]
                ],
              )
          ).animate().fadeIn(delay: 200.ms).slideX(),

          // ADVICE, DIET & INVESTIGATIONS
          _buildCard(
              title: 'Recommendations & Investigations',
              icon: Icons.lightbulb_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDiet,
                          decoration: const InputDecoration(labelText: 'Diet Suggestion'),
                          items: _dietOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: (v) { setState(() => _selectedDiet = v); _onDataChanged(); },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedInvestigation,
                          decoration: const InputDecoration(labelText: 'Add Investigation'),
                          items: _investigationOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: (v) {
                            if (v != null && !_selectedInvestigations.contains(v)) {
                              setState(() => _selectedInvestigations.add(v));
                              _onDataChanged();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_selectedInvestigations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      children: _selectedInvestigations.map((inv) => Chip(
                          label: Text(inv),
                          onDeleted: () { setState(() => _selectedInvestigations.remove(inv)); _onDataChanged(); }
                      )).toList(),
                    )
                  ],
                  const SizedBox(height: 16),
                  AutoSuggestField(controller: _adviceCtrl, label: 'Custom Advice / Notes', dbKey: 'advices', maxLines: 2, onChanged: _onDataChanged),
                ],
              )
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
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Prescription Workspace', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onPressed: _logout,
          ),
          const SizedBox(width: 16),
          if (isWide)
            TextButton.icon(
              icon: Icon(_showPreview ? Icons.dock_rounded : Icons.picture_as_pdf, color: Theme.of(context).colorScheme.primary),
              label: Text(_showPreview ? "Hide Preview" : "Show Preview", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              onPressed: () { setState(() => _showPreview = !_showPreview); _onDataChanged(); },
            ),
          const SizedBox(width: 16),
          TextButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            label: const Text("Clear", style: TextStyle(color: Colors.grey)),
            onPressed: _clearForm,
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('SAVE & PRINT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
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
            Expanded(flex: 5, child: formWidget),
            if (_showPreview) Expanded(flex: 4, child: previewWidget.animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0))
          ])
          : DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(tabs: [Tab(text: "Edit Prescription"), Tab(text: "Live Preview")], labelColor: Colors.blue),
            Expanded(child: TabBarView(children: [formWidget, previewWidget]))
          ],
        ),
      ),
    );
  }

  Widget _buildMedRow(int index, Map<String, String> med, bool isEmptyStomach) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: isEmptyStomach ? Colors.red.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white, child: Text('${index + 1}')),
        title: Text(med['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Sig: ${med['dose']} (${med['quantity']}) • ${med['timing']} • For ${med['duration']}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            setState(() {
              if (isEmptyStomach) { emptyStomachMedicines.removeAt(index); } else { medicines.removeAt(index); }
            });
            _onDataChanged();
          },
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))], border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800))]),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}