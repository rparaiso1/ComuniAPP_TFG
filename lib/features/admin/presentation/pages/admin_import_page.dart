import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';

class AdminImportPage extends ConsumerStatefulWidget {
  const AdminImportPage({super.key});

  @override
  ConsumerState<AdminImportPage> createState() => _AdminImportPageState();
}

class _AdminImportPageState extends ConsumerState<AdminImportPage> {
  bool _isUploading = false;
  Map<String, dynamic>? _lastResult;
  String? _selectedFileName;

  Map<String, String> get _authHeaders => ref.read(authHeadersProvider);

  Map<String, dynamic> _decodeJsonSafe(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  String _extractErrorMessage(http.Response response) {
    final body = _decodeJsonSafe(response.body);
    final detail = body['detail']?.toString();
    final message = body['message']?.toString();
    final error = body['error']?.toString();
    return detail ?? message ?? error ?? context.l.serverError;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.colors.backgroundGradient,
        ),
        child: SafeArea(
          child: ContentConstraint(
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
                    onPressed: () => context.canPop() ? context.pop() : context.goNamed('home'),
                  ),
                ),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Text(
                        context.l.importTitle,
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

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.l.importDescription,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Import users section
                      _ImportSection(
                        title: context.l.importUsers,
                        subtitle: context.l.importUsersSubtitle,
                        icon: Icons.people_outlined,
                        color: AppColors.primary,
                        columns: [
                          context.l.colEmail,
                          context.l.colName,
                          context.l.colRole,
                          context.l.colPhone,
                          context.l.colDwelling,
                          context.l.colPassword,
                        ],
                        isUploading: _isUploading,
                        onImport: () => _importFile('users'),
                      ),
                      const SizedBox(height: 16),

                      // Import zones section
                      _ImportSection(
                        title: context.l.importZones,
                        subtitle: context.l.importZonesSubtitle,
                        icon: Icons.place_outlined,
                        color: AppColors.success,
                        columns: [
                          context.l.colZoneName,
                          context.l.colZoneType,
                          context.l.colZoneDesc,
                          context.l.colZoneCapacity,
                          context.l.colZoneApproval,
                        ],
                        isUploading: _isUploading,
                        onImport: () => _importFile('zones'),
                      ),
                      const SizedBox(height: 24),

                      // Results
                      if (_lastResult != null) ...[
                        Text(
                          context.l.importResult,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ResultCard(result: _lastResult!, fileName: _selectedFileName),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Future<void> _importFile(String type) async {
    try {
      final requestTimeout = context.l.requestTimeout;
      final serverError = context.l.serverError;

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l.fileReadError),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() {
        _isUploading = true;
        _lastResult = null;
        _selectedFileName = file.name;
      });

      final uri = Uri.parse('${EnvConfig.apiBaseUrl}/api/admin/import/$type');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_authHeaders)
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );

      http.Response? response;
      Exception? lastError;
      for (var attempt = 1; attempt <= 2; attempt++) {
        try {
          final streamedResponse = await request
              .send()
              .timeout(const Duration(seconds: 30));
          response = await http.Response.fromStream(streamedResponse);
          break;
        } on TimeoutException {
          lastError = Exception(requestTimeout);
        } on Exception catch (e) {
          lastError = e;
        }
      }

      if (response == null) {
        throw lastError ?? Exception(serverError);
      }

      if (response.statusCode == 200) {
        final data = _decodeJsonSafe(response.body);
        setState(() {
          _lastResult = data;
          _isUploading = false;
        });
      } else {
        final errorMessage = _extractErrorMessage(response);
        setState(() {
          _isUploading = false;
          _lastResult = {
            'total_rows': 0,
            'imported': 0,
            'errors': [errorMessage],
          };
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _lastResult = {
          'total_rows': 0,
          'imported': 0,
          'errors': [e.toString()],
        };
      });
    }
  }
}

class _ImportSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> columns;
  final bool isUploading;
  final VoidCallback onImport;

  const _ImportSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.columns,
    required this.isUploading,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            context.l.expectedColumns,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...columns.map(
            (col) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: color.withValues(alpha: 0.6)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      col,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isUploading ? null : onImport,
              icon: isUploading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.onGradient,
                      ),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(isUploading ? context.l.importing : context.l.selectFile),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: context.colors.onGradient,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final String? fileName;

  const _ResultCard({required this.result, this.fileName});

  @override
  Widget build(BuildContext context) {
    final totalRows = result['total_rows'] ?? 0;
    final imported = result['imported'] ?? 0;
    final errors = (result['errors'] as List?) ?? [];
    final hasErrors = errors.isNotEmpty;
    final allSuccess = imported > 0 && errors.isEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.colors.softShadow,
        border: Border.all(
          color: allSuccess
              ? AppColors.success.withValues(alpha: 0.3)
              : hasErrors
                  ? AppColors.warning.withValues(alpha: 0.3)
                  : AppColors.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fileName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, size: 18, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    fileName!,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              _ResultStat(
                label: context.l.totalRows,
                value: totalRows.toString(),
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              _ResultStat(
                label: context.l.imported,
                value: imported.toString(),
                color: AppColors.success,
              ),
              const SizedBox(width: 16),
              _ResultStat(
                label: context.l.errors,
                value: errors.length.toString(),
                color: errors.isNotEmpty ? AppColors.error : AppColors.textTertiary,
              ),
            ],
          ),
          if (hasErrors) ...[
            const SizedBox(height: 16),
            Text(
              context.l.errorDetails,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: errors
                      .map<Widget>(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber, size: 14, color: AppColors.warning),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  e.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
