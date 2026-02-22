import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generateAndPrintPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('DR. JOHN DOE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('MBBS, MD (Internal Medicine)', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Reg. No: 123456789', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('City Central Clinic', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text('123 Health Avenue, Medical District', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Phone: +1 234 567 8900', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.blue900, thickness: 2),
              pw.SizedBox(height: 10),

              // Patient Info Strip
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Patient: ${data['patientName'] ?? ''}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Age/Sex: ${data['age']} / ${data['gender']}'),
                  pw.Text('Date: ${data['date']}'),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Text('BP: ${data['bp']} mmHg  |  Weight: ${data['weight']} kg', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Diagnosis
              if (data['diagnosis'] != null && data['diagnosis'].toString().isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Diagnosis / Symptoms:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                      pw.SizedBox(height: 5),
                      pw.Text(data['diagnosis']),
                    ],
                  ),
                ),

              // Medicines
              pw.Text('Rx', style: pw.TextStyle(fontSize: 28, fontStyle: pw.FontStyle.italic, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 15),

              ...(data['medicines'] as List<Map<String, String>>).asMap().entries.map((entry) {
                int idx = entry.key + 1;
                var med = entry.value;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 15),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('$idx. ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(med['name']!, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Sig: ${med['dose']}  --  For ${med['duration']}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey800)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),

              pw.Spacer(),

              // Advice
              if (data['advice'] != null && data['advice'].toString().isNotEmpty)
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Advice / Investigations:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text(data['advice']),
                    ]
                ),

              pw.SizedBox(height: 40),

              // Footer
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.SizedBox(height: 40, width: 100, child: pw.Divider(color: PdfColors.black)),
                    pw.Text('Signature', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('DR. JOHN DOE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Prescription_${data['patientName']}',
    );
  }
}