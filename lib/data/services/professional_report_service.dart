import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:smc/data/models/inspection_record.dart';

/// Professional Report Generation Service
/// Generates high-fidelity, industrial-grade PDF inspection reports.
class ProfessionalReportService {
  
  /// Generates a PDF report for the given inspection record and returns the file path.
  Future<String> generateInspectionReport(InspectionRecord record) async {
    final pdf = pw.Document();

    // Load fonts for professional look (Simulating with default Helvetica but named for logic)
    // In a real app, we'd load 'Inter' or 'Roboto' from assets.

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(record),
        footer: (context) => _buildFooter(context, record),
        build: (context) => [
          _buildHeroSection(record),
          pw.SizedBox(height: 20),
          _buildAssetDetails(record),
          pw.SizedBox(height: 20),
          _buildDefectAnalysis(record),
          pw.SizedBox(height: 20),
          _buildAiAssessment(record),
          pw.SizedBox(height: 30),
          _buildSignatureSection(),
        ],
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/Report_${record.id}.pdf");
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }

  pw.Widget _buildHeader(InspectionRecord record) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('BHARAT INFRA INSPECT', 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey700)),
            pw.Text('OFFICIAL INSPECTION LOG', 
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          ],
        ),
        pw.Text('ID: ${record.id}', style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context, InspectionRecord record) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount} | Generated on ${DateTime.now().toIso8601String()}',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
      ),
    );
  }

  pw.Widget _buildHeroSection(InspectionRecord record) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Inspection Summary Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Divider(thickness: 2, color: PdfColors.blue800),
          pw.SizedBox(height: 10),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Status: ${record.status.name.toUpperCase()}',
                    style: pw.TextStyle(
                        color: _getPdfStatusColor(record.status),
                        fontWeight: pw.FontWeight.bold)),
                pw.Text('Date: ${record.inspectionDate.toString().split(' ')[0]}'),
              ]),
        ],
      ),
    );
  }

  pw.Widget _buildAssetDetails(InspectionRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Asset Information',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            _buildTableRow('Asset Name', record.assetName),
            _buildTableRow('Asset Type', record.assetType.name.toUpperCase()),
            _buildTableRow('Location', record.address),
            _buildTableRow('GPS Coordinates',
                '${record.latitude.toStringAsFixed(6)}, ${record.longitude.toStringAsFixed(6)}'),
            _buildTableRow('Inspector ID', record.inspectorId),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  pw.Widget _buildDefectAnalysis(InspectionRecord record) {
    if (record.defects.isEmpty) {
      return pw.Text('No major structural defects identified.');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Detailed Defect Log',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: record.defects.map((defect) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey200),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('${defect.type} - ${defect.component}',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(defect.description, style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(defect.severity.name.toUpperCase(),
                          style: pw.TextStyle(
                              color: _getPdfSeverityColor(defect.severity),
                              fontWeight: pw.FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildAiAssessment(InspectionRecord record) {
    final ai = record.aiAnalysisResult;
    if (ai.isEmpty) return pw.SizedBox();

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('AI COMPLIANCE ASSESSMENT',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.Text('Confidence: ${ai['confidence'] ?? 'N/A'}',
                  style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(ai['description'] ?? 'No AI description available.',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text('Recommended Action: ${ai['recommendation'] ?? 'Monitor and verify.'}',
              style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildSignatureSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 150, 
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey700))
              ),
            ),
            pw.Text('Digital Field Signature', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Inspectorate System Authenticated', style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              width: 150, 
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey700))
              ),
            ),
            pw.Text('Reviewing Authority', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('QR Code Placeholder', style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    );
  }

  PdfColor _getPdfStatusColor(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant: return PdfColors.green800;
      case ComplianceStatus.nonCompliant: return PdfColors.orange800;
      case ComplianceStatus.critical: return PdfColors.red800;
      case ComplianceStatus.pendingReview: return PdfColors.blue800;
    }
  }

  PdfColor _getPdfSeverityColor(InspectionSeverity severity) {
    switch (severity) {
      case InspectionSeverity.low: return PdfColors.green800;
      case InspectionSeverity.medium: return PdfColors.orange700;
      case InspectionSeverity.high: return PdfColors.red700;
      case InspectionSeverity.extreme: return PdfColors.red900;
    }
  }
}
