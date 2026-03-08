import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/client_model.dart';

class PdfService {
  static Future<void> generateAndPrintPdf(ClientModel client) async {
    final pdf = pw.Document();

    // PDF ka design
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header (Letterhead Style)
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'AMIN GILL LAW ASSOCIATES',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Advocates & Legal Consultants',
                        style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                      ),
                      pw.Divider(thickness: 2, color: PdfColors.amber),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Case Details Heading
                pw.Text(
                  'CASE RECORD & CLIENT DETAILS',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
                pw.SizedBox(height: 20),

                // Data Table / Details
                _buildDetailRow('Client/Case Name:', client.name),
                pw.SizedBox(height: 10),
                _buildDetailRow('Case Category:', client.email),
                pw.SizedBox(height: 10),
                _buildDetailRow('Hearing Number:', client.age.toString()),

                pw.SizedBox(height: 40),

                // Footer / Signature Area
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Date Generated: ${DateTime.now().toString().split(' ')[0]}'),
                    pw.Column(
                      children: [
                        pw.Container(width: 100, height: 1, color: PdfColors.black),
                        pw.SizedBox(height: 4),
                        pw.Text('Authorized Signature'),
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

    // PDF ko screen par show karna aur print/share ka option dena
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${client.name}_Case_Record',
    );
  }

  // Helper widget PDF ke andar text rows design karne ke liye
  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
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
    );
  }
}