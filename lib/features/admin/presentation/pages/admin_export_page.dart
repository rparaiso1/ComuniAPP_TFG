import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/web_download_stub.dart'
    if (dart.library.html) '../../../../core/utils/web_download_web.dart';

/// Page for admin/president to export community data as CSV.
class AdminExportPage extends ConsumerStatefulWidget {
  const AdminExportPage({super.key});

  @override
  ConsumerState<AdminExportPage> createState() => _AdminExportPageState();
}

class _AdminExportPageState extends ConsumerState<AdminExportPage> {
  String? _downloadingResource;

  Map<String, dynamic> _decodeJsonSafe(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  String _extractErrorMessage(String body) {
    final parsed = _decodeJsonSafe(body);
    final detail = parsed['detail']?.toString();
    final message = parsed['message']?.toString();
    final error = parsed['error']?.toString();
    return detail ?? message ?? error ?? context.l.unexpectedError;
  }

  Future<dynamic> _getWithRetry(
    Uri url,
    Map<String, String> headers, {
    required String timeoutMessage,
    required String fallbackMessage,
  }) async {
    final client = ref.read(httpClientProvider);
    Exception? lastError;
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        return await client
            .get(url, headers: headers)
            .timeout(const Duration(seconds: 30));
      } on TimeoutException {
        lastError = Exception(timeoutMessage);
      } on Exception catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? Exception(fallbackMessage);
  }

  Future<void> _downloadCsv(String resource) async {
    setState(() => _downloadingResource = '${resource}_csv');
    final exportError = context.l.exportError;

    try {
      final exportWebOnly = context.l.exportWebOnly;
      final exportSuccess = context.l.exportSuccess;
      final noPermissions = context.l.noPermissions;
      final requestTimeout = context.l.requestTimeout;
      final unexpectedError = context.l.unexpectedError;

      final headers = ref.read(authHeadersProvider);
      final baseUrl = EnvConfig.apiBaseUrl;
      final url = Uri.parse('$baseUrl/api/admin/export/$resource?format=csv');

      final response = await _getWithRetry(
        url,
        headers,
        timeoutMessage: requestTimeout,
        fallbackMessage: unexpectedError,
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final filename = '${resource}_export.csv';

        if (!kIsWeb) {
          throw Exception(exportWebOnly);
        }
        downloadBytesAsFile(bytes, filename, 'text/csv');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exportSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        if (!mounted) return;
        final detail = response.statusCode == 403
            ? noPermissions
          : _extractErrorMessage(response.body);
        throw Exception(detail);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$exportError: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloadingResource = null);
    }
  }

  Future<void> _downloadPdf(String resource, String label) async {
    setState(() => _downloadingResource = '${resource}_pdf');
    final exportError = context.l.exportError;

    try {
      final exportWebOnly = context.l.exportWebOnly;
      final exportSuccess = context.l.exportSuccess;
      final noPermissions = context.l.noPermissions;
      final requestTimeout = context.l.requestTimeout;
      final unexpectedError = context.l.unexpectedError;
      final pdfTitle = context.l.pdfExportTitle(label);

      final headers = ref.read(authHeadersProvider);
      final baseUrl = EnvConfig.apiBaseUrl;
      final url = Uri.parse('$baseUrl/api/admin/export/$resource?format=json');

      final response = await _getWithRetry(
        url,
        headers,
        timeoutMessage: requestTimeout,
        fallbackMessage: unexpectedError,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! List<dynamic>) {
          throw Exception(unexpectedError);
        }
        final List<dynamic> jsonData = decoded;
        final rows = jsonData
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        if (!mounted) return;
        final config = PdfExportService.getResourceConfig(context, resource);
        final pdfHeaders = config['headers'] ?? [];
        final pdfKeys = config['keys'] ?? [];

        final pdfBytes = await PdfExportService.generate(
          title: pdfTitle,
          headers: pdfHeaders,
          keys: pdfKeys,
          rows: rows,
        );

        final filename = '${resource}_export.pdf';
        if (!kIsWeb) {
          throw Exception(exportWebOnly);
        }
        downloadBytesAsFile(pdfBytes, filename, 'application/pdf');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exportSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        if (!mounted) return;
        final detail = response.statusCode == 403
            ? noPermissions
          : _extractErrorMessage(response.body);
        throw Exception(detail);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$exportError: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloadingResource = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resources = [
      _ExportItem(
        resource: 'users',
        label: context.l.exportUsers,
        icon: Icons.people_outline,
        color: AppColors.primary,
      ),
      _ExportItem(
        resource: 'bookings',
        label: context.l.exportBookings,
        icon: Icons.calendar_today_outlined,
        color: const Color(0xFF10B981),
      ),
      _ExportItem(
        resource: 'incidents',
        label: context.l.exportIncidents,
        icon: Icons.warning_amber_outlined,
        color: const Color(0xFFF59E0B),
      ),
      _ExportItem(
        resource: 'documents',
        label: context.l.exportDocuments,
        icon: Icons.folder_outlined,
        color: const Color(0xFF3B82F6),
      ),
      _ExportItem(
        resource: 'zones',
        label: context.l.exportZones,
        icon: Icons.place_outlined,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      body: ContentConstraint(
        child: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.softShadow,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: context.colors.onGradient),
                tooltip: context.l.goBack,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.goNamed('home'),
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                    context.l.exportData,
                    style: TextStyle(
                      color: context.colors.onGradient,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),

          // Description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                context.l.exportDescription,
                style: TextStyle(
                  fontSize: 15,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),

          // Export cards
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = resources[index];
                  final isCsvLoading =
                      _downloadingResource == '${item.resource}_csv';
                  final isPdfLoading =
                      _downloadingResource == '${item.resource}_pdf';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: context.colors.cardShadow,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child:
                                Icon(item.icon, color: item.color, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'CSV / PDF',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildDownloadButton(
                            label: 'CSV',
                            icon: Icons.table_chart_outlined,
                            color: item.color,
                            isLoading: isCsvLoading,
                            onPressed: () => _downloadCsv(item.resource),
                          ),
                          const SizedBox(width: 8),
                          _buildDownloadButton(
                            label: 'PDF',
                            icon: Icons.picture_as_pdf_outlined,
                            color: AppColors.error,
                            isLoading: isPdfLoading,
                            onPressed: () =>
                                _downloadPdf(item.resource, item.label),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: resources.length,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDownloadButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    if (isLoading) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
      );
    }
    return SizedBox(
      height: 36,
      child: FilledButton.icon(
        onPressed: _downloadingResource != null ? null : onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: Size.zero,
        ),
      ),
    );
  }
}

class _ExportItem {
  final String resource;
  final String label;
  final IconData icon;
  final Color color;

  const _ExportItem({
    required this.resource,
    required this.label,
    required this.icon,
    required this.color,
  });
}
