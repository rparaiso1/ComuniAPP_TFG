import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../utils/l10n_extension.dart';

/// Service for generating PDF reports from exported data.
///
/// Uses the `pdf` package to create tables with headers,
/// styled with the app's brand colors.
class PdfExportService {
  static const PdfColor _brandPrimary = PdfColor.fromInt(0xFF6C63FF);
  static const PdfColor _headerBg = PdfColor.fromInt(0xFF6C63FF);
  static const PdfColor _headerText = PdfColors.white;
  static const PdfColor _rowAlt = PdfColor.fromInt(0xFFF5F5FF);

  /// Generate a PDF document from tabular data.
  ///
  /// [title] — displayed at the top of the PDF.
  /// [headers] — column header labels (display names).
  /// [keys] — JSON keys corresponding to each column.
  /// [rows] — list of maps containing the data.
  static Future<Uint8List> generate({
    required String title,
    required List<String> headers,
    required List<String> keys,
    required List<Map<String, dynamic>> rows,
    String? subtitle,
  }) async {
    final pdf = pw.Document(
      title: title,
      author: 'ComuniApp',
      creator: 'ComuniApp PDF Export',
    );

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final now = dateFormat.format(DateTime.now());

    // Build table data — header row + data rows
    final tableHeaders = headers
        .map(
          (h) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
            child: pw.Text(
              h,
              style: pw.TextStyle(
                color: _headerText,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
        )
        .toList();

    final tableRows = <List<pw.Widget>>[];
    for (final row in rows) {
      tableRows.add(
        keys.map((key) {
          final value = row[key]?.toString() ?? '';
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 5,
            ),
            child: pw.Text(
              _formatCellValue(value),
              style: const pw.TextStyle(fontSize: 8),
            ),
          );
        }).toList(),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _buildHeader(title, subtitle, now),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            context: context,
            headers: tableHeaders,
            data: tableRows,
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 0.5,
            ),
            headerDecoration: const pw.BoxDecoration(color: _headerBg),
            headerAlignments: {
              for (int i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft,
            },
            rowDecoration: const pw.BoxDecoration(),
            oddRowDecoration: const pw.BoxDecoration(color: _rowAlt),
            cellAlignments: {
              for (int i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft,
            },
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            '${rows.length} registros',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    String title,
    String? subtitle,
    String date,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ComuniApp',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: _brandPrimary,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    subtitle,
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
            pw.Text(
              date,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: _brandPrimary, thickness: 1.5),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'ComuniApp — Exportación automática',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
        pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
        ),
      ],
    );
  }

  /// Formats a cell value for nicer display in PDF.
  static String _formatCellValue(String value) {
    if (value.isEmpty) return '—';

    // Try to format ISO dates
    if (value.length >= 19 && value.contains('T')) {
      try {
        final dt = DateTime.parse(value);
        return DateFormat('dd/MM/yyyy HH:mm').format(dt);
      } catch (_) {
        return value;
      }
    }

    // Translate boolean values
    if (value == 'true') return 'Sí';
    if (value == 'false') return 'No';

    return value;
  }

  /// Helper to get localized column headers for a resource.
  static Map<String, List<String>> getResourceConfig(
    BuildContext context,
    String resource,
  ) {
    final l = context.l;
    switch (resource) {
      case 'users':
        return {
          'headers': [
            'Email',
            l.fullName,
            l.phone,
            l.dwellingLabel,
            l.roleLabel,
            l.status,
          ],
          'keys': [
            'email',
            'full_name',
            'phone',
            'dwelling',
            'role',
            'is_active',
          ],
        };
      case 'bookings':
        return {
          'headers': [
            l.zone,
            l.userName,
            l.startTime,
            l.endTime,
            l.status,
            l.notes,
          ],
          'keys': [
            'zone_name',
            'user_name',
            'start_time',
            'end_time',
            'status',
            'notes',
          ],
        };
      case 'incidents':
        return {
          'headers': [
            l.title,
            l.description,
            l.priority,
            l.status,
            l.reportedBy,
            l.location,
            l.createdAt,
          ],
          'keys': [
            'title',
            'description',
            'priority',
            'status',
            'reporter_name',
            'location',
            'created_at',
          ],
        };
      case 'documents':
        return {
          'headers': [
            l.title,
            l.category,
            l.status,
            l.uploadedBy,
            l.createdAt,
          ],
          'keys': [
            'title',
            'category',
            'approval_status',
            'uploaded_by',
            'created_at',
          ],
        };
      default:
        return {'headers': [], 'keys': []};
    }
  }
}
