import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart';
import 'package:smc/data/models/citizen_model.dart';

class PdfService {
  /// Generates and opens a Health ID Card PDF
  static Future<void> generateHealthIDCard(Citizen citizen) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: 400,
              height: 250,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue900,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('HEALTH IDENTITY CARD',
                              style: pw.TextStyle(
                                  color: PdfColors.white, fontSize: 10)),
                          pw.SizedBox(height: 10),
                          pw.Text(citizen.name,
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.Container(
                        width: 40,
                        height: 40,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.white,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildSimpleInfo('HEALTH ID', citizen.healthId),
                            pw.SizedBox(height: 10),
                            pw.Row(
                              children: [
                                _buildSimpleInfo('BLOOD', citizen.bloodGroup),
                                pw.SizedBox(width: 20),
                                _buildSimpleInfo('AGE', '${citizen.age}'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await _saveAndOpenPdf(pdf, 'HealthID_${citizen.id}.pdf');
  }

  /// Generates and opens a Vaccination Certificate PDF
  static Future<void> generateVaccinationCertificate({
    required String citizenName,
    required String vaccineName,
    required String dose,
    required String date,
    required String hospital,
    required String certificateId,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Bharat MUNICIPAL CORPORATION',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Department of Public Health',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.blue700),
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Center(
                  child: pw.Text(
                    'VACCINATION CERTIFICATE',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ),
                pw.SizedBox(height: 60),
                _buildInfoRow('Citizen Name:', citizenName),
                _buildInfoRow('Vaccine:', vaccineName),
                _buildInfoRow('Dose:', dose),
                _buildInfoRow('Date of Vaccination:', date),
                _buildInfoRow('Vaccination Center:', hospital),
                _buildInfoRow('Certificate ID:', certificateId),
                pw.Spacer(),
                pw.Divider(color: PdfColors.grey),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Generated on: ${DateTime.now().toString().split('.')[0]}',
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey),
                    ),
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 80,
                          height: 1,
                          color: PdfColors.black,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Authorized Signatory',
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await _saveAndOpenPdf(pdf, 'Vaccination_Certificate_${certificateId}.pdf');
  }

  /// Generates and opens a General Medical Record PDF
  static Future<void> generateMedicalRecordPdf({
    required String citizenName,
    required String title,
    required String provider,
    required String date,
    required String type,
    required String description,
    required Map<String, dynamic> details,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Bharat MUNICIPAL CORPORATION',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.Text('Health Management System (HMS)',
                            style: pw.TextStyle(
                                fontSize: 12, color: PdfColors.blue600)),
                      ],
                    ),
                    pw.Text('MEDICAL REPORT',
                        style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2, color: PdfColors.blue),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Expanded(
                        child: _buildSimpleInfo('Patient Name', citizenName)),
                    pw.Expanded(child: _buildSimpleInfo('Date', date)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(child: _buildSimpleInfo('Provider', provider)),
                    pw.Expanded(
                        child: _buildSimpleInfo(
                            'Record Type', type.toUpperCase())),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text('Title: $title',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Description:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(description, style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 30),
                if (details.isNotEmpty) ...[
                  pw.Text('CLINICAL DETAILS',
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800)),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(10),
                      child: pw.Column(
                        children: details.entries
                            .map((e) => pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 4),
                                  child: pw.Row(
                                    children: [
                                      pw.Text('${e.key}: ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.Text('${e.value}'),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
                pw.Spacer(),
                pw.Divider(color: PdfColors.grey300),
                pw.Center(
                  child: pw.Text(
                      'This is a computer-generated health record from the SMC Health Portal.',
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey600)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await _saveAndOpenPdf(
        pdf, 'Medical_Record_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSimpleInfo(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static Future<void> _saveAndOpenPdf(pw.Document pdf, String fileName) async {
    try {
      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      debugPrint('PDF saved to: ${file.path}');
      await OpenFilex.open(file.path);
    } catch (e) {
      debugPrint('Error saving/opening PDF: $e');
    }
  }
}


