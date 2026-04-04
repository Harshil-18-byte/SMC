import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smc/data/models/inspection_record.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  static final PdfColor industrialAmber = PdfColor.fromInt(0xFFF59E0B);
  static final PdfColor industrialSlate = PdfColor.fromInt(0xFF1E293B);
  static final PdfColor deepSteel = PdfColor.fromInt(0xFF0F172A);

  Future<void> generateAndPrintReport(InspectionRecord record) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/fonts/Outfit-Regular.ttf").catchError((_) => rootBundle.load("packages/google_fonts/fonts/Outfit-Regular.ttf"));
    final boldFontData = await rootBundle.load("assets/fonts/Outfit-Bold.ttf").catchError((_) => rootBundle.load("packages/google_fonts/fonts/Outfit-Bold.ttf"));
    
    final pw.Font ttf = pw.Font.ttf(fontData);
    final pw.Font ttfBold = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(32),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: industrialAmber, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(record),
                pw.SizedBox(height: 32),
                _buildAssetSection(record),
                pw.SizedBox(height: 24),
                _buildDiagnosticSection(record),
                pw.SizedBox(height: 24),
                _buildAnalysisDetails(record),
                pw.Spacer(),
                _buildFooter(record),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'SMC_Internal_Report_${record.id}.pdf',
    );
  }

  pw.Widget _buildHeader(InspectionRecord record) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('BHARAT INFRA SMC', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: industrialAmber)),
            pw.Text('OFFICIAL STRUCTURAL AUDIT CERTIFICATE', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, letterSpacing: 1.2)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('REPORT ID: ${record.id}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text('DATE: ${DateFormat('yyyy-MM-dd').format(record.inspectionDate)}', style: pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildAssetSection(InspectionRecord record) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _row('ASSET NAME', record.assetName),
          _row('ASSET TYPE', record.assetType.name.toUpperCase()),
          _row('COORDINATES', '${record.latitude.toStringAsFixed(6)}, ${record.longitude.toStringAsFixed(6)}'),
          _row('ADDRESS', record.address),
        ],
      ),
    );
  }

  pw.Widget _buildDiagnosticSection(InspectionRecord record) {
    final Map<String, dynamic> ai = record.aiAnalysisResult;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('DIAGNOSTIC VERDICT', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: industrialAmber)),
        pw.Divider(color: industrialAmber),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PATTERN MATCH: ${ai['patternId'] ?? 'N/A'}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text('FINDING: ${ai['finding'] ?? 'Structural Anomaly'}', style: pw.TextStyle(fontSize: 14)),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(color: industrialAmber, borderRadius: pw.BorderRadius.circular(4)),
              child: pw.Text(ai['severity'] ?? 'UNKNOWN', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildAnalysisDetails(InspectionRecord record) {
    final Map<String, dynamic> ai = record.aiAnalysisResult;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('ENGINE ANALYSIS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(ai['description'] ?? record.notes, style: pw.TextStyle(fontSize: 11, lineSpacing: 2)),
        pw.SizedBox(height: 16),
        pw.Text('RECOMMENDED MITIGATION', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(ai['recommendation'] ?? 'Monitor site weekly.', style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic)),
      ],
    );
  }

  pw.Widget _buildFooter(InspectionRecord record) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INSPECTOR SIGNATURE', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
            pw.SizedBox(height: 4),
            pw.Text(record.inspectorId, style: const pw.TextStyle(fontSize: 14, color: PdfColors.black)),
          ],
        ),
        pw.Container(
          width: 80, height: 80,
          decoration: pw.BoxDecoration(border: pw.Border.all(color: industrialAmber, width: 2), shape: pw.BoxShape.circle),
          child: pw.Center(child: pw.Text('SMC\nSEAL', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: industrialAmber))),
        ),
      ],
    );
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 100, child: pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }
}
