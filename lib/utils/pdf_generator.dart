import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  // Returns bytes for the Live Preview and Printing
  static Future<Uint8List> generatePdfBytes(Map<String, dynamic> data, PdfPageFormat format) async {
    final pdf = pw.Document();

    // Premium Medical Colors (Fixed: Explicit hex colors instead of opacity)
    final primaryColor = PdfColor.fromHex('#1E3A8A'); // Deep Navy
    final primaryBgColor = PdfColor.fromHex('#EBF0F9'); // Very Light Navy (replaces 0.1 opacity)

    final accentColor = PdfColor.fromHex('#14B8A6'); // Teal
    final accentBgColor = PdfColor.fromHex('#F0FDFB'); // Very Light Teal (replaces 0.05 opacity)
    final accentBorderColor = PdfColor.fromHex('#99F6E4'); // Soft Teal Border (replaces 0.5 opacity)

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Stack(
              children: [
                // Watermark Background
                pw.Positioned.fill(
                    child: pw.Center(
                        child: pw.Transform.rotateBox(
                          angle: 0.5,
                          child: pw.Text(
                            'Rx',
                            style: pw.TextStyle(
                                fontSize: 200,
                                color: PdfColors.grey200,
                                fontWeight: pw.FontWeight.bold,
                                fontStyle: pw.FontStyle.italic
                            ),
                          ),
                        )
                    )
                ),

                // Foreground Content
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('DR. ALEX MERCER', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                            pw.SizedBox(height: 4),
                            pw.Text('MBBS, MD (Internal Medicine), FACP', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                            pw.Text('Reg. No: MED-774892', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: pw.BoxDecoration(
                              color: primaryBgColor, // Fixed
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('Apex Care Clinic', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                              pw.Text('100 Health Blvd, Suite 2A', style: const pw.TextStyle(fontSize: 10)),
                              pw.Text('+1 (555) 123-4567', style: const pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Divider(color: accentColor, thickness: 2),
                    pw.SizedBox(height: 15),

                    // --- PATIENT INFO STRIP ---
                    pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: const pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(6))
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(child: pw.Text('Patient: ${data['patientName'] ?? '--'}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14))),
                            pw.Expanded(child: pw.Text('Age/Sex: ${data['age'] ?? '-'} / ${data['gender'] ?? '-'}', textAlign: pw.TextAlign.center)),
                            pw.Expanded(child: pw.Text('Date: ${data['date']}', textAlign: pw.TextAlign.right)),
                          ],
                        )
                    ),
                    pw.SizedBox(height: 10),

                    // --- VITALS ---
                    pw.Row(
                        children: [
                          if (data['bp'] != null && data['bp'].toString().isNotEmpty)
                            pw.Padding(padding: const pw.EdgeInsets.only(right: 20), child: pw.Text('BP: ${data['bp']} mmHg', style: const pw.TextStyle(fontSize: 11))),
                          if (data['weight'] != null && data['weight'].toString().isNotEmpty)
                            pw.Text('Weight: ${data['weight']} kg', style: const pw.TextStyle(fontSize: 11)),
                        ]
                    ),
                    pw.SizedBox(height: 15),

                    // --- DIAGNOSIS ---
                    if (data['diagnosis'] != null && data['diagnosis'].toString().isNotEmpty)
                      pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 20),
                          padding: const pw.EdgeInsets.only(left: 10),
                          decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3))),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Diagnosis / Clinical Notes:', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                                pw.SizedBox(height: 4),
                                pw.Text(data['diagnosis'], style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                              ]
                          )
                      ),

                    // --- MEDICINES (Rx) ---
                    pw.Text('Rx', style: pw.TextStyle(fontSize: 36, color: primaryColor, fontStyle: pw.FontStyle.italic, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 15),

                    ...(data['medicines'] as List<Map<String, String>>).asMap().entries.map((entry) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 16),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(
                                width: 20,
                                child: pw.Text('${entry.key + 1}.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14))
                            ),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(entry.value['name']!, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                  pw.SizedBox(height: 3),
                                  pw.Row(
                                      children: [
                                        pw.Text('Dosage: ', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                                        pw.Text('${entry.value['dose']}    ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                                        pw.Text('Duration: ', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                                        pw.Text('${entry.value['duration']}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                                      ]
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),

                    pw.Spacer(),

                    // --- ADVICE ---
                    if (data['advice'] != null && data['advice'].toString().isNotEmpty)
                      pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                              color: accentBgColor, // Fixed
                              border: pw.Border.all(color: accentBorderColor), // Fixed
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))
                          ),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Advice & Lifestyle:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor)),
                                pw.SizedBox(height: 6),
                                pw.Text(data['advice']),
                              ]
                          )
                      ),

                    pw.SizedBox(height: 40),

                    // --- SIGNATURE FOOTER ---
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Valid only when digitally or physically signed.', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Container(height: 30, width: 120, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)))),
                              pw.SizedBox(height: 5),
                              pw.Text('Doctor\'s Signature', style: const pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                        ]
                    ),
                  ],
                ),
              ]
          );
        },
      ),
    );

    return pdf.save();
  }
}