import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/pdf_generator.dart';
import '../utils/local_db.dart';
import '../widgets/auto_suggest_field.dart';

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
    }
  }

  void _generateAndPrint() async {
    // 1. Save all typed entries to Local Database for future suggestions
    LocalDb.saveSuggestion('patient_names', _nameCtrl.text);
    LocalDb.saveSuggestion('diagnoses', _diagnosisCtrl.text);
    LocalDb.saveSuggestion('advices', _adviceCtrl.text);
    for (var med in medicines) {
      LocalDb.saveSuggestion('medicines', med['name']!);
      LocalDb.saveSuggestion('doses', med['dose']!);
      LocalDb.saveSuggestion('durations', med['duration']!);
    }

    // 2. Prepare Data for PDF
    final data = {
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

    // 3. Print
    PdfGenerator.generateAndPrintPdf(data);
  }

  void _clearForm() {
    setState(() {
      _nameCtrl.clear(); _ageCtrl.clear(); _genderCtrl.clear();
      _bpCtrl.clear(); _weightCtrl.clear(); _diagnosisCtrl.clear();
      _adviceCtrl.clear(); medicines.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Prescription', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _clearForm)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Patient Details'),
            Row(
              children: [
                Expanded(flex: 2, child: AutoSuggestField(controller: _nameCtrl, label: 'Patient Name', dbKey: 'patient_names')),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _ageCtrl, decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _genderCtrl, decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder(), isDense: true))),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Vitals & Diagnosis'),
            Row(
              children: [
                Expanded(child: TextField(controller: _bpCtrl, decoration: const InputDecoration(labelText: 'BP (mmHg)', border: OutlineInputBorder(), isDense: true))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _weightCtrl, decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder(), isDense: true))),
              ],
            ),
            const SizedBox(height: 16),
            AutoSuggestField(controller: _diagnosisCtrl, label: 'Clinical Diagnosis / Symptoms', dbKey: 'diagnoses', maxLines: 2),
            const SizedBox(height: 24),

            _buildSectionHeader('Rx - Medications'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 3, child: AutoSuggestField(controller: _medNameCtrl, label: 'Medicine Name', dbKey: 'medicines')),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: AutoSuggestField(controller: _medDoseCtrl, label: 'Dosage (e.g., 1-0-1)', dbKey: 'doses')),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: AutoSuggestField(controller: _medDurationCtrl, label: 'Duration (e.g., 5 Days)', dbKey: 'durations')),
                      const SizedBox(width: 12),
                      IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFF1E3A8A), size: 36), onPressed: _addMedicine)
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      final med = medicines[index];
                      return ListTile(
                        leading: const Icon(Icons.medication),
                        title: Text(med['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${med['dose']} | ${med['duration']}'),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => medicines.removeAt(index))),
                      );
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Advice & Investigations'),
            AutoSuggestField(controller: _adviceCtrl, label: 'General advice, diet, or lab tests', dbKey: 'advices', maxLines: 3),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                icon: const Icon(Icons.print),
                label: const Text('GENERATE & PRINT PRESCRIPTION', style: TextStyle(fontSize: 18, letterSpacing: 1.2)),
                onPressed: _generateAndPrint,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
    );
  }
}