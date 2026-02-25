import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
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
  // Basic Info
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _adviceCtrl = TextEditingController();

  // Dropdown States
  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  // Past History
  List<String> _selectedPastHistory = [];
  final List<String> _pastHistoryOptions = [
    'APD',
    'HTN',
    'Asthma',
    'DM2',
    'Hypothyroid',
    'Drug Allergy',
    'Fever',
    'Cough',
    'Respiratory Distress',
    'None',
    'Other'
  ];
  final _customPastHistoryCtrl = TextEditingController();

  // Diet
  String? _selectedDiet;
  final List<String> _dietOptions = [
    'High Protein Diet',
    'Low Salt Diet',
    'Diabetic Diet',
    'Soft Diet',
    'Liquid Diet',
    'Normal Diet',
    'Other'
  ];
  final _customDietCtrl = TextEditingController();

  // Investigations
  String? _selectedInvestigation;
  final List<String> _investigationOptions = [
    'CBC',
    'ESR',
    'CRP',
    'LFT',
    'KFT',
    'RFT',
    'Lipid Profile',
    'Thyroid Profile',
    'HbA1c',
    'Blood Sugar (Fasting)',
    'Blood Sugar (PP)',
    'Urine Routine',
    'Urine Culture',
    'X-ray',
    'MRI',
    'CT Scan',
    'Ultrasound',
    'ECG',
    'ECHO',
    'TMT',
    'Vitamin D',
    'Vitamin B12',
    'Dengue Test',
    'Malaria Test',
    'Typhoid Test',
    'Sputum AFB',
    'Mantoux Test',
    'Other'
  ];
  List<String> _selectedInvestigations = [];
  final _customInvestigationCtrl = TextEditingController();

  // Medicine Table States
  final _medNameCtrl = TextEditingController();

  String _selectedFrequency = '1-0-0';
  final List<String> _frequencyOptions = [
    '1-0-0',
    '0-1-0',
    '0-0-1',
    '1-1-0',
    '1-0-1',
    '0-1-1',
    '1-1-1',
    'SOS',
    'Other'
  ];
  final _customFrequencyCtrl = TextEditingController();

  String _selectedDoses = '1 Tablet';

  final List<String> _dosesOptions = [
    '1/2 Tablet',
    '1 Tablet',
    '1.5 Tablets',
    '2 Tablets',
    '1 Capsule',
    '2 Capsules',
    '2.5 ml',
    '5 ml (1 tsp)',
    '10 ml (2 tsp)',
    '15 ml (1 tbsp)',
    '1 Drop',
    '2 Drops',
    '1 Puff',
    '2 Puffs',
    '1 Sachet',
    'As directed',
    'Other'
  ];

  final _customDosesCtrl = TextEditingController();

  String _selectedTiming = 'After Food';
  final List<String> _timingOptions = [
    'Before Food',
    'After Food',
    'Empty Stomach',
    'Other'
  ];
  final _customTimingCtrl = TextEditingController();

  // ADDED "Other" TO DURATION
  String _selectedDuration = '5 Days';
  final List<String> _durationOptions = [
    '3 Days',
    '5 Days',
    '7 Days',
    '10 Days',
    '15 Days',
    '1 Month',
    'Other'
  ];
  final _customDurationCtrl = TextEditingController();

  List<Map<String, String>> medicines = [];
  List<Map<String, String>> emptyStomachMedicines = [];

  // Next Visit
  DateTime? _nextVisitDate;

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
      String finalFreq = _selectedFrequency == 'Other'
          ? _customFrequencyCtrl.text
          : _selectedFrequency;
      String finalDoses =
          _selectedDoses == 'Other' ? _customDosesCtrl.text : _selectedDoses;
      String finalTiming =
          _selectedTiming == 'Other' ? _customTimingCtrl.text : _selectedTiming;
      String finalDuration = _selectedDuration == 'Other'
          ? _customDurationCtrl.text
          : _selectedDuration;

      if (finalFreq.isEmpty) finalFreq = '-';
      if (finalDoses.isEmpty) finalDoses = '-';
      if (finalTiming.isEmpty) finalTiming = '-';
      if (finalDuration.isEmpty) finalDuration = '-';

      setState(() {
        var newMed = {
          'name': _medNameCtrl.text,
          'frequency': finalFreq,
          'doses': finalDoses,
          'timing': finalTiming,
          'duration': finalDuration,
        };

        if (finalTiming.toLowerCase() == 'empty stomach') {
          emptyStomachMedicines.add(newMed);
        } else {
          medicines.add(newMed);
        }

        // Clear fields safely
        _medNameCtrl.clear();
        _customFrequencyCtrl.clear();
        _customDosesCtrl.clear();
        _customTimingCtrl.clear();
        _customDurationCtrl.clear();
        if (_selectedFrequency == 'Other') _selectedFrequency = '100';
        if (_selectedDoses == 'Other') _selectedDoses = '1 Tablet';
        if (_selectedTiming == 'Other') _selectedTiming = 'After Food';
        if (_selectedDuration == 'Other') _selectedDuration = '5 Days';
      });
      _onDataChanged();
    }
  }

  void _saveToDb() {
    LocalDb.saveSuggestion('patient_names', _nameCtrl.text);
    LocalDb.saveSuggestion('diagnoses', _diagnosisCtrl.text);
    LocalDb.saveSuggestion('advices', _adviceCtrl.text);
    for (var med in medicines)
      LocalDb.saveSuggestion('medicines', med['name']!);
    for (var med in emptyStomachMedicines)
      LocalDb.saveSuggestion('medicines', med['name']!);
  }

  Map<String, dynamic> _getFormData() {
    String finalPastHistory = _selectedPastHistory.contains('Other')
        ? [
            ..._selectedPastHistory.where((e) => e != 'Other'),
            _customPastHistoryCtrl.text
          ].join(', ')
        : _selectedPastHistory.join(', ');

    String finalDiet =
        _selectedDiet == 'Other' ? _customDietCtrl.text : (_selectedDiet ?? '');

    return {
      'date': DateFormat('dd MMM yyyy').format(DateTime.now()),
      'patientName': _nameCtrl.text,
      'age': _ageCtrl.text,
      'gender': _selectedGender,
      'bp': _bpCtrl.text,
      'weight': _weightCtrl.text,
      'diagnosis': _diagnosisCtrl.text,
      'pastHistory': finalPastHistory,
      'diet': finalDiet,
      'investigations': _selectedInvestigations.join(', '),
      'advice': _adviceCtrl.text,
      'medicines': medicines,
      'emptyStomachMedicines': emptyStomachMedicines,
      'nextVisitDate': _nextVisitDate != null
          ? DateFormat('dd MMM yyyy').format(_nextVisitDate!)
          : '',
    };
  }

  void _clearForm() {
    setState(() {
      _nameCtrl.clear();
      _ageCtrl.clear();
      _selectedGender = 'Male';
      _bpCtrl.clear();
      _weightCtrl.clear();
      _diagnosisCtrl.clear();
      _adviceCtrl.clear();
      _selectedPastHistory.clear();
      _selectedDiet = null;
      _selectedInvestigations.clear();
      medicines.clear();
      emptyStomachMedicines.clear();
      _customPastHistoryCtrl.clear();
      _customDietCtrl.clear();
      _customInvestigationCtrl.clear();
      _customDurationCtrl.clear();
      _nextVisitDate = null;
    });
    _onDataChanged();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PinLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _savePdfToFile(Uint8List pdfBytes, String patientName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String safeName =
          patientName.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      if (safeName.isEmpty) safeName = "Patient_Rx";

      String basePath = '${directory.path}/$safeName';
      File file = File('$basePath.pdf');

      int counter = 1;
      while (await file.exists()) {
        file = File('${basePath}_$counter.pdf');
        counter++;
      }

      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                    'Saved to Documents: ${file.path.split(Platform.pathSeparator).last}'),
              ],
            ),
            backgroundColor: const Color(0xFF0F766E),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error saving file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 900;

    Widget formWidget = SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. PATIENT PROFILE CARD
          _buildCard(
            title: 'Patient Details',
            icon: Icons.person_outline,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: AutoSuggestField(
                        controller: _nameCtrl,
                        label: 'Patient Name',
                        dbKey: 'patient_names',
                        onChanged: _onDataChanged)),
                const SizedBox(width: 16),
                Expanded(
                    flex: 1,
                    child: TextField(
                        controller: _ageCtrl,
                        onChanged: (_) => _onDataChanged(),
                        decoration: const InputDecoration(labelText: 'Age'))),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: _genderOptions
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedGender = v!);
                      _onDataChanged();
                    },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.05),

          // 2. CLINICAL FINDINGS CARD
          _buildCard(
              title: 'Clinical Findings & History',
              icon: Icons.monitor_heart_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: _bpCtrl,
                              onChanged: (_) => _onDataChanged(),
                              decoration: const InputDecoration(
                                  labelText: 'Blood Pressure (mmHg)'))),
                      const SizedBox(width: 16),
                      Expanded(
                          child: TextField(
                              controller: _weightCtrl,
                              onChanged: (_) => _onDataChanged(),
                              decoration: const InputDecoration(
                                  labelText: 'Weight (kg)'))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AutoSuggestField(
                      controller: _diagnosisCtrl,
                      label: 'Primary Diagnosis / Symptoms',
                      dbKey: 'diagnoses',
                      maxLines: 2,
                      onChanged: _onDataChanged),
                  const SizedBox(height: 24),
                  Text("Past History / Co-morbidities",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.blueGrey.shade700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _pastHistoryOptions.map((option) {
                      bool isSelected = _selectedPastHistory.contains(option);
                      return FilterChip(
                        label: Text(option,
                            style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF1E40AF)
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        selected: isSelected,
                        backgroundColor: const Color(0xFFF8FAFC),
                        selectedColor: const Color(0xFFDBEAFE),
                        checkmarkColor: const Color(0xFF1E40AF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF93C5FD)
                                    : const Color(0xFFE2E8F0))),
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
                  ),
                  if (_selectedPastHistory.contains('Other')) ...[
                    const SizedBox(height: 12),
                    TextField(
                        controller: _customPastHistoryCtrl,
                        onChanged: (_) => _onDataChanged(),
                        decoration: const InputDecoration(
                            labelText: 'Specify Other Disease', isDense: true)),
                  ]
                ],
              )).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),

          // 3. MEDICINES CARD
          _buildCard(
              title: 'Rx Medications',
              icon: Icons.medication_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          flex: 4,
                          child: AutoSuggestField(
                              controller: _medNameCtrl,
                              label: 'Medicine Name',
                              dbKey: 'medicines')),
                      const SizedBox(width: 12),
                      Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedFrequency,
                              decoration:
                                  const InputDecoration(labelText: 'Frequency'),
                              items: _frequencyOptions
                                  .map((v) => DropdownMenuItem(
                                      value: v, child: Text(v, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (v) {
                                setState(() => _selectedFrequency = v!);
                                _onDataChanged();
                              })),
                      const SizedBox(width: 12),
                      Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedDoses,
                              decoration:
                                  const InputDecoration(labelText: 'Doses'),
                              items: _dosesOptions
                                  .map((v) => DropdownMenuItem(
                                      value: v, child: Text(v, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (v) {
                                setState(() => _selectedDoses = v!);
                                _onDataChanged();
                              })),
                    ],
                  ),
                  // Conditional Custom Inputs (Row 1)
                  if (_selectedFrequency == 'Other' ||
                      _selectedDoses == 'Other') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_selectedFrequency == 'Other')
                          Expanded(
                              child: TextField(
                                  controller: _customFrequencyCtrl,
                                  decoration: const InputDecoration(
                                      labelText: 'Specify Frequency'))),
                        if (_selectedFrequency == 'Other' &&
                            _selectedDoses == 'Other')
                          const SizedBox(width: 12),
                        if (_selectedDoses == 'Other')
                          Expanded(
                              child: TextField(
                                  controller: _customDosesCtrl,
                                  decoration: const InputDecoration(
                                      labelText: 'Specify Dose'))),
                      ],
                    )
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedTiming,
                              decoration:
                                  const InputDecoration(labelText: 'Timing'),
                              items: _timingOptions
                                  .map((v) => DropdownMenuItem(
                                      value: v, child: Text(v, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (v) {
                                setState(() => _selectedTiming = v!);
                                _onDataChanged();
                              })),
                      const SizedBox(width: 12),
                      Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _selectedDuration,
                              decoration:
                                  const InputDecoration(labelText: 'Duration'),
                              items: _durationOptions
                                  .map((v) => DropdownMenuItem(
                                      value: v, child: Text(v, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (v) {
                                setState(() => _selectedDuration = v!);
                                _onDataChanged();
                              })),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: _addMedicine,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 16),
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF2563EB),
                                Color(0xFF1E40AF)
                              ]),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF2563EB)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4))
                              ]),
                          child: const Row(children: [
                            Icon(Icons.add, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text("ADD",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ]),
                        ),
                      )
                    ],
                  ),
                  // Conditional Custom Inputs (Row 2)
                  if (_selectedTiming == 'Other' ||
                      _selectedDuration == 'Other') ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      if (_selectedTiming == 'Other')
                        Expanded(
                            child: TextField(
                                controller: _customTimingCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Specify Timing'))),
                      if (_selectedTiming == 'Other' &&
                          _selectedDuration == 'Other')
                        const SizedBox(width: 12),
                      if (_selectedDuration == 'Other')
                        Expanded(
                            child: TextField(
                                controller: _customDurationCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Specify Duration'))),
                    ])
                  ],

                  // Empty Stomach List
                  if (emptyStomachMedicines.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6)),
                      child: const Text("EMPTY STOMACH MEDICINES",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                              fontSize: 12,
                              letterSpacing: 1.0)),
                    ),
                    const SizedBox(height: 12),
                    ...emptyStomachMedicines
                        .asMap()
                        .entries
                        .map((entry) =>
                            _buildMedRow(entry.key, entry.value, true))
                        .toList()
                  ],
                  // Regular Med List
                  if (medicines.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6)),
                      child: const Text("REGULAR MEDICINES",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              fontSize: 12,
                              letterSpacing: 1.0)),
                    ),
                    const SizedBox(height: 12),
                    ...medicines
                        .asMap()
                        .entries
                        .map((entry) =>
                            _buildMedRow(entry.key, entry.value, false))
                        .toList()
                  ]
                ],
              )).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

          // 4. RECOMMENDATIONS CARD
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
                          decoration: const InputDecoration(
                              labelText: 'Diet Suggestion'),
                          items: _dietOptions
                              .map((v) =>
                                  DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedDiet = v);
                            _onDataChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedInvestigation,
                          decoration: const InputDecoration(
                              labelText: 'Add Investigation'),
                          items: _investigationOptions
                              .map((v) =>
                                  DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedInvestigation = v);
                            if (v != null &&
                                v != 'Other' &&
                                !_selectedInvestigations.contains(v)) {
                              _selectedInvestigations.add(v);
                              _selectedInvestigation = null;
                            }
                            _onDataChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_selectedDiet == 'Other') ...[
                    const SizedBox(height: 12),
                    TextField(
                        controller: _customDietCtrl,
                        onChanged: (_) => _onDataChanged(),
                        decoration: const InputDecoration(
                            labelText: 'Specify Diet Recommendation',
                            isDense: true)),
                  ],
                  if (_selectedInvestigation == 'Other') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: TextField(
                                controller: _customInvestigationCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Specify Investigation',
                                    isDense: true))),
                        const SizedBox(width: 12),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E40AF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            onPressed: () {
                              if (_customInvestigationCtrl.text.isNotEmpty &&
                                  !_selectedInvestigations.contains(
                                      _customInvestigationCtrl.text)) {
                                setState(() {
                                  _selectedInvestigations
                                      .add(_customInvestigationCtrl.text);
                                  _customInvestigationCtrl.clear();
                                  _selectedInvestigation = null;
                                });
                                _onDataChanged();
                              }
                            },
                            child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text('Add Investigation')))
                      ],
                    )
                  ],
                  if (_selectedInvestigations.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _selectedInvestigations
                          .map((inv) => Chip(
                              label: Text(inv,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F766E))),
                              backgroundColor: const Color(0xFFCCFBF1),
                              deleteIconColor: const Color(0xFF0F766E),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: const BorderSide(
                                      color: Color(0xFF99F6E4))),
                              onDeleted: () {
                                setState(
                                    () => _selectedInvestigations.remove(inv));
                                _onDataChanged();
                              }))
                          .toList(),
                    )
                  ],
                  const SizedBox(height: 24),
                  AutoSuggestField(
                      controller: _adviceCtrl,
                      label: 'Custom Advice / Clinical Notes',
                      dbKey: 'advices',
                      maxLines: 3,
                      onChanged: _onDataChanged),
                ],
              )).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),

          // 5. NEXT VISIT CARD
          _buildCard(
              title: 'Next Visit & Follow-up',
              icon: Icons.calendar_month_outlined,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text("Select Date"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFFCBD5E1)))),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _nextVisitDate ??
                              DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) => Theme(
                                data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF1E40AF))),
                                child: child!,
                              ));
                      if (pickedDate != null) {
                        setState(() => _nextVisitDate = pickedDate);
                        _onDataChanged();
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  if (_nextVisitDate != null)
                    Chip(
                      backgroundColor: const Color(0xFFFFFBEB), // Amber 50
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: Color(0xFFFDE68A))),
                      label: Text(
                          'Next Visit: ${DateFormat('dd MMM yyyy').format(_nextVisitDate!)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E))),
                      onDeleted: () {
                        setState(() => _nextVisitDate = null);
                        _onDataChanged();
                      },
                    )
                ],
              )).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
        ],
      ),
    );

    Widget previewWidget = Container(
      decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFFE2E8F0), width: 1))),
      child: PdfPreview(
        build: (format) =>
            PdfGenerator.generatePdfBytes(_getFormData(), format),
        allowPrinting: true,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        scrollViewDecoration:
            const BoxDecoration(color: Color(0xFFCBD5E1)), // Slate 300
      ),
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC), // Ultra modern Slate 50 background
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.health_and_safety, color: Color(0xFF1E40AF)),
          SizedBox(width: 10),
          Text('Rx Workspace',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5)),
        ]),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE2E8F0), height: 1)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
            label: const Text("Logout",
                style: TextStyle(
                    color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            onPressed: _logout,
          ),
          const SizedBox(width: 12),
          if (isWide)
            TextButton.icon(
              icon: Icon(
                  _showPreview ? Icons.dock_rounded : Icons.picture_as_pdf,
                  color: const Color(0xFF0F766E)),
              label: Text(_showPreview ? "Hide Preview" : "Show Preview",
                  style: const TextStyle(
                      color: Color(0xFF0F766E), fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() => _showPreview = !_showPreview);
                _onDataChanged();
              },
            ),
          const SizedBox(width: 12),
          TextButton.icon(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
            label: const Text("Clear",
                style: TextStyle(
                    color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            onPressed: _clearForm,
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download, size: 18),
              label: const Text('SAVE PDF',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                _saveToDb();
                final pdfBytes = await PdfGenerator.generatePdfBytes(
                    _getFormData(), PdfPageFormat.a4);
                await _savePdfToFile(pdfBytes, _nameCtrl.text);
              },
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding:
                const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.print, size: 18),
              label: const Text('PRINT',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                _saveToDb();
                final pdfBytes = await PdfGenerator.generatePdfBytes(
                    _getFormData(), PdfPageFormat.a4);
                await Printing.layoutPdf(
                  onLayout: (format) async => pdfBytes,
                  name: 'Rx_${_nameCtrl.text}',
                );
              },
            ),
          )
        ],
      ),
      body: isWide
          ? Row(children: [
              Expanded(flex: 5, child: formWidget),
              if (_showPreview)
                Expanded(
                    flex: 4,
                    child: previewWidget
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.1, end: 0))
            ])
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                      tabs: [
                        Tab(text: "Edit Prescription"),
                        Tab(text: "Live Preview")
                      ],
                      labelColor: Color(0xFF1E40AF),
                      indicatorColor: Color(0xFF1E40AF),
                      labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                      child: TabBarView(children: [formWidget, previewWidget]))
                ],
              ),
            ),
    );
  }

  // ULTRA MODERN MEDICINE ROW UI
  Widget _buildMedRow(int index, Map<String, String> med, bool isEmptyStomach) {
    final Color mainColor =
        isEmptyStomach ? const Color(0xFFDC2626) : const Color(0xFF1E40AF);
    final Color bgColor =
        isEmptyStomach ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Text('${index + 1}',
                style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med['name']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMedTag(Icons.medication, '${med['doses']}'),
                    _buildMedTag(Icons.schedule, '${med['frequency']}'),
                    _buildMedTag(Icons.restaurant, '${med['timing']}'),
                    _buildMedTag(Icons.calendar_today, '${med['duration']}'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            tooltip: 'Remove',
            onPressed: () {
              setState(() {
                isEmptyStomach
                    ? emptyStomachMedicines.removeAt(index)
                    : medicines.removeAt(index);
              });
              _onDataChanged();
            },
          )
        ],
      ),
    );
  }

  // TAG STYLING FOR MEDICINE DETAILS
  Widget _buildMedTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ULTRA MODERN CARD UI
  Widget _buildCard(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF94A3B8).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: const Color(0xFF1E40AF), size: 22),
            ),
            const SizedBox(width: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5))
          ]),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child:
                  Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 2)),
          child,
        ],
      ),
    );
  }
}
