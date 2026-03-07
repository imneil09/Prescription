import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static Future<Uint8List> generatePdfBytes(
      Map<String, dynamic> data, PdfPageFormat format) async {
    final ByteData logoData = await rootBundle.load('assets/logo2.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);
    final pdf = pw.Document();

    // ==========================================
    // PREMIUM KICK-ASS COLOR PALETTE
    // ==========================================
    final primaryDark = PdfColor.fromHex('#0F172A'); // Deep Slate (Almost Black)
    final brandBlue = PdfColor.fromHex('#1E40AF'); // Professional Royal Blue
    final brandLightBlue = PdfColor.fromHex('#E0E7FF'); // Very Light Blue
    final accentTeal = PdfColor.fromHex('#0F766E'); // Clinical Teal
    final surfaceGray = PdfColor.fromHex('#F8FAFC'); // Very Light Gray
    final borderGray = PdfColor.fromHex('#E2E8F0'); // Crisp Divider Lines
    final textMuted = PdfColor.fromHex('#64748B'); // Soft Gray for labels
    final dangerBg = PdfColor.fromHex('#FEF2F2'); // Light Red
    final dangerText = PdfColor.fromHex('#DC2626'); // Deep Red

    // ==========================================
    // PAGE THEME (Applies to EVERY page generated)
    // ==========================================
    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      buildBackground: (pw.Context context) {
        return pw.FullPage(
          ignoreMargins: false,
          child: pw.Center(
            child: pw.Transform.rotateBox(
              angle: 0.5,
              child: pw.Text('Rx',
                  style: pw.TextStyle(
                      fontSize: 300,
                      color: PdfColors.grey100,
                      fontWeight: pw.FontWeight.bold,
                      fontStyle: pw.FontStyle.italic)),
            ),
          ),
        );
      },
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,

        // ==========================================
        // HEADER: Repeats at the top of EVERY page
        // ==========================================
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                  height: 6,
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                      color: brandBlue,
                      borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(4)))),
              pw.SizedBox(height: 16),

              pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // LEFT: Appointment Info
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: pw.BoxDecoration(color: brandLightBlue, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                              child: pw.Text('CONTACT FOR APPOINTMENT', style: pw.TextStyle(fontSize: 9, color: brandBlue, fontWeight: pw.FontWeight.bold, letterSpacing: 1.0)),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text('6909097100 / 9774335071', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryDark)),
                            pw.SizedBox(height: 4),
                            pw.Text('www.appointdoctor.com', style: pw.TextStyle(fontSize: 10, color: brandBlue, decoration: pw.TextDecoration.underline)),
                            pw.SizedBox(height: 12),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: pw.BoxDecoration(color: dangerBg, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                              child: pw.Text('Sunday Closed', style: pw.TextStyle(color: dangerText, fontSize: 9, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
                            )
                          ]),
                    ),

                    // RIGHT: Doctor Info
                    pw.Expanded(
                      flex: 6,
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('DR. SHANKAR DEBROY', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: brandBlue, letterSpacing: 0.5)),
                            pw.SizedBox(height: 4),
                            pw.Text('MS(Ortho), Reg. No: 1040 (TSMC)', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryDark)),
                            pw.SizedBox(height: 4),
                            pw.Text('Assistant Professor, Dept. of Orthopaedics', style: pw.TextStyle(fontSize: 10, color: primaryDark)),
                            pw.Text('Agartala Government Medical College', style: pw.TextStyle(fontSize: 10, color: primaryDark)),
                            pw.SizedBox(height: 6),
                            pw.Text('Mail: drshankor620@gmail.com', style: pw.TextStyle(fontSize: 10, color: textMuted)),
                            pw.Text('Mob: 9233812929', style: pw.TextStyle(fontSize: 10, color: textMuted)),
                            pw.SizedBox(height: 6),
                            pw.Text('Panel Specialist for ONGC', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accentTeal)),
                          ]),
                    )
                  ]),

              pw.SizedBox(height: 16),

              // SLEEK PATIENT DATA STRIP
              pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: pw.BoxDecoration(
                      color: surfaceGray,
                      border: pw.Border.all(color: borderGray, width: 1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDataBlock('PATIENT NAME', data['patientName'] ?? '--', primaryDark, textMuted),
                        pw.Container(height: 20, width: 1, color: borderGray),
                        _buildDataBlock('AGE / SEX', '${data['age'] ?? '-'} / ${data['gender'] ?? '-'}', primaryDark, textMuted),
                        pw.Container(height: 20, width: 1, color: borderGray),
                        _buildDataBlock('DATE', data['date'] ?? '--', primaryDark, textMuted),
                        pw.Container(height: 20, width: 1, color: borderGray),
                        _buildDataBlock('VITALS', 'Wt: ${data['weight']?.isEmpty ?? true ? '-' : data['weight']}kg | BP: ${data['bp']?.isEmpty ?? true ? '-' : data['bp']}', primaryDark, textMuted),
                      ])),
              pw.SizedBox(height: 20),
            ],
          );
        },

        // ==========================================
        // FOOTER: Locks to the bottom of the page
        // ==========================================
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.SizedBox(height: 16),
              pw.Divider(color: borderGray, thickness: 1.5),
              pw.SizedBox(height: 12),

              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // LEFT: Disclaimers & Next Visit
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (data['nextVisitDate'] != null && data['nextVisitDate'].toString().isNotEmpty) ...[
                            pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: pw.BoxDecoration(color: surfaceGray, border: pw.Border.all(color: borderGray), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                                child: pw.Row(children: [
                                  pw.Text('NEXT VISIT: ', style: pw.TextStyle(fontSize: 10, color: textMuted)),
                                  pw.Text('${data['nextVisitDate']}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: brandBlue)),
                                ])),
                            pw.SizedBox(height: 12),
                          ],
                          pw.Text('* Not valid for medicolegal purpose.', style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('* Not valid without authorized signature.', style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text("Designed & Developed by ", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey900)),
                                pw.Image(logoImage, height: 10),
                                pw.Text(".Proudly Made in India.", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey900)),
                              ]),
                          pw.SizedBox(height: 4),
                          pw.Text('For technical assistance: https://about.me/theneils', style: pw.TextStyle(fontSize: 8, color: textMuted, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 6),
                          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(fontSize: 8, color: brandBlue, fontWeight: pw.FontWeight.bold)),
                        ]),

                    // RIGHT: Signature Block
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(height: 35, width: 160, decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: primaryDark, width: 1.5)))),
                        pw.SizedBox(height: 6),
                        pw.Text('Dr. Shankor Debroy', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: brandBlue)),
                        pw.Text('Signature / Seal', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                      ],
                    ),
                  ]),
            ],
          );
        },

        // ==========================================
        // BODY: Side-by-Side Partitions
        // ==========================================
        build: (pw.Context context) {

          // 1. Compile the LEFT Column Widgets
          List<pw.Widget> leftWidgets = [];
          if (data['diagnosis']?.isNotEmpty ?? false) leftWidgets.add(_buildSidebarSection('DIAGNOSIS', data['diagnosis'], accentTeal, primaryDark));
          if (data['pastHistory']?.isNotEmpty ?? false) leftWidgets.add(_buildSidebarSection('PAST HISTORY', data['pastHistory'], accentTeal, primaryDark));
          if (data['investigations']?.isNotEmpty ?? false) leftWidgets.add(_buildSidebarSection('INVESTIGATIONS', data['investigations'], accentTeal, primaryDark));
          if (data['diet']?.isNotEmpty ?? false) leftWidgets.add(_buildSidebarSection('DIET', data['diet'], accentTeal, primaryDark));
          if (data['advice']?.isNotEmpty ?? false) leftWidgets.add(_buildSidebarSection('ADVICE', data['advice'], accentTeal, primaryDark));

          // 2. Compile the RIGHT Column Widgets
          List<pw.Widget> rightWidgets = [];
          rightWidgets.add(pw.Text('Rx', style: pw.TextStyle(fontSize: 42, color: brandBlue, fontStyle: pw.FontStyle.italic, fontWeight: pw.FontWeight.bold)));
          rightWidgets.add(pw.SizedBox(height: 16));

          if (data['emptyStomachMedicines'] != null && (data['emptyStomachMedicines'] as List).isNotEmpty) {
            rightWidgets.add(
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(color: dangerBg, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
                  child: pw.Text('EMPTY STOMACH (Take before meals)', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: dangerText, letterSpacing: 0.5)),
                )
            );
            rightWidgets.add(pw.SizedBox(height: 10));
            rightWidgets.addAll(_buildKickAssMedList(data['emptyStomachMedicines'], dangerText, textMuted));
            rightWidgets.add(pw.SizedBox(height: 16));
          }

          if (data['medicines'] != null && (data['medicines'] as List).isNotEmpty) {
            rightWidgets.addAll(_buildKickAssMedList(data['medicines'], primaryDark, textMuted));
          }

          return [
            pw.Partitions(
                children: [
                  // LEFT SIDEBAR PARTITION
                  pw.Partition(
                      width: 160, // Fixed width equivalent to your old flex: 3
                      child: pw.Container(
                          padding: const pw.EdgeInsets.only(right: 20),
                          decoration: pw.BoxDecoration(
                              border: pw.Border(right: pw.BorderSide(color: borderGray, width: 1))
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: leftWidgets,
                          )
                      )
                  ),

                  // RIGHT MEDICINES PARTITION
                  pw.Partition(
                      child: pw.Container(
                          padding: const pw.EdgeInsets.only(left: 20),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: rightWidgets,
                          )
                      )
                  )
                ]
            )
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildDataBlock(String label, String value, PdfColor valueColor, PdfColor labelColor) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 7, color: labelColor, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5)),
          pw.SizedBox(height: 3),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, color: valueColor, fontWeight: pw.FontWeight.bold)),
        ]);
  }

  // Back to original sidebar section style
  static pw.Widget _buildSidebarSection(String title, String content, PdfColor accentColor, PdfColor textColor) {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            pw.Container(width: 4, height: 10, decoration: pw.BoxDecoration(color: accentColor, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)))),
            pw.SizedBox(width: 6),
            pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: accentColor, letterSpacing: 0.5)),
          ]),
          pw.SizedBox(height: 6),
          pw.Text(content, style: pw.TextStyle(fontSize: 10, color: textColor, lineSpacing: 2)),
        ])
    );
  }

  static String _getReadableFrequency(String freq) {
    switch (freq) {
      case '100': return 'Morning';
      case '010': return 'Afternoon';
      case '001': return 'Night';
      case '110': return 'Morning & Afternoon';
      case '101': return 'Morning & Night';
      case '011': return 'Afternoon & Night';
      case '111': return 'Morning, Afternoon, Night';
      case '200': return '2 Doses Morning';
      case 'SOS': return 'When Required';
      default: return freq;
    }
  }

  static List<pw.Widget> _buildKickAssMedList(List meds, PdfColor primaryDark, PdfColor textMuted) {
    return meds.asMap().entries.map((entry) {
      String humanFreq = _getReadableFrequency(entry.value['frequency']!);

      return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(width: 18, margin: const pw.EdgeInsets.only(top: 2), child: pw.Text('${entry.key + 1}.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: textMuted))),
                pw.Expanded(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(entry.value['name']!, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryDark)),
                                pw.SizedBox(width: 10),
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E0E7FF'), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)), border: pw.Border.all(color: PdfColor.fromHex('#C7D2FE'))),
                                  child: pw.Text(entry.value['frequency']!, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#3730A3'))),
                                )
                              ]),
                          pw.SizedBox(height: 4),
                          pw.Row(children: [
                            pw.Text('Take ${entry.value['doses']} ', style: pw.TextStyle(fontSize: 10, color: primaryDark, fontWeight: pw.FontWeight.bold)),
                            pw.Text(' |  $humanFreq  |  ${entry.value['timing']}  |  ', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                            pw.Text('For ${entry.value['duration']}', style: pw.TextStyle(fontSize: 10, color: primaryDark, fontWeight: pw.FontWeight.bold)),
                          ]),
                          pw.SizedBox(height: 6),
                          pw.Divider(color: PdfColor.fromHex('#F1F5F9'), thickness: 1)
                        ])),
              ]));
    }).toList();
  }
}