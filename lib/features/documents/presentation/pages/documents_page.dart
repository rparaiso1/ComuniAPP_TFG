import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/error_dialog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/document_controller.dart';

class DocumentsPage extends ConsumerStatefulWidget {
  const DocumentsPage({super.key});

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage> {
  String? selectedCategory;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocuments();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(documentControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _loadDocuments() async {
    await ref.read(documentControllerProvider.notifier).loadDocuments(category: selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final currentUser = authState.user;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: ContentConstraint(
        child: RefreshIndicator(
          onRefresh: _loadDocuments,
          child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildHeader(context, currentUser?.role.isAdminOrPresident ?? false),
            _buildCategoryFilter(),
            if (state.isLoading && state.documents.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null && state.documents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 64, color: context.colors.textTertiary),
                        const SizedBox(height: 16),
                        Text(
                          ErrorDialog.getFriendlyMessage(context, state.error!),
                          style: TextStyle(color: context.colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _loadDocuments,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(context.l.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (state.documents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.folder_open_rounded,
                          size: 64,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.l.noDocuments,
                        style: TextStyle(
                          fontSize: 18,
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedCategory != null
                            ? context.l.noDocsInCategory
                            : context.l.docsWillAppear,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final document = state.documents[index];
                      return StaggeredListItem(
                        index: index,
                        child: _DocumentCard(
                          document: document,
                          canDelete: currentUser?.role.isAdminOrPresident ?? false,
                          canApprove: currentUser?.role.isAdminOrPresident ?? false,
                          onApprove: (approved, reason) async {
                            await ref
                                .read(documentControllerProvider.notifier)
                                .approveDocument(
                                  document.id,
                                  approved: approved,
                                  rejectionReason: reason,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    approved
                                        ? context.l.documentApproved
                                        : context.l.documentRejected,
                                  ),
                                ),
                              );
                            }
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(context.l.deleteDocument),
                                content: Text(context.l.deleteDocConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(context.l.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.colors.error,
                                      foregroundColor: context.colors.onGradient,
                                    ),
                                    child: Text(context.l.delete),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref
                                  .read(documentControllerProvider.notifier)
                                  .deleteDocument(document.id);
                            }
                          },
                        ),
                      );
                    },
                    childCount: state.documents.length,
                  ),
                ),
              ),
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool canUpload) {
    return SliverAppBar(
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
      actions: [
        if (canUpload)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.softShadow,
            ),
            child: IconButton(
              icon: Icon(Icons.upload_file, color: context.colors.onGradient),
              tooltip: context.l.uploadDocument,
              onPressed: () async {
                await _showUploadDialog(context);
              },
            ),
          ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              context.l.documentsTitle,
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
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'name': context.l.catAll, 'key': 'Todos', 'icon': Icons.folder_outlined},
      {'name': context.l.catMinutes, 'key': 'acta', 'icon': Icons.gavel_outlined},
      {'name': context.l.catRegulations, 'key': 'norma', 'icon': Icons.rule_outlined},
      {'name': context.l.catDocuments, 'key': 'documento', 'icon': Icons.description_outlined},
    ];
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final name = category['name'] as String;
              final key = category['key'] as String;
              final icon = category['icon'] as IconData;
              final isSelected = (selectedCategory == null && key == 'Todos') ||
                  selectedCategory == key;
              
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FilterChip(
                    avatar: Icon(
                      icon,
                      size: 18,
                      color: isSelected ? context.colors.onGradient : AppColors.primary,
                    ),
                    label: Text(
                      name,
                      style: TextStyle(
                        color: isSelected ? context.colors.onGradient : context.colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = key == 'Todos' ? null : key;
                      });
                      ref.read(documentControllerProvider.notifier)
                          .loadDocuments(category: selectedCategory);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: context.colors.card,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : context.colors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showUploadDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedUploadCategory;
    Uint8List? selectedFileBytes;
    String? selectedFileName;
    int? selectedFileSize;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text(context.l.uploadDocument),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- File picker area ---
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: [
                          'pdf', 'doc', 'docx', 'xls', 'xlsx',
                          'jpg', 'jpeg', 'png', 'gif', 'txt', 'csv',
                        ],
                        withData: true,
                      );
                      if (result != null && result.files.single.bytes != null) {
                        final file = result.files.single;
                        if (file.size > 10 * 1024 * 1024) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.l.fileTooLarge)),
                          );
                          return;
                        }
                        setState(() {
                          selectedFileBytes = file.bytes;
                          selectedFileName = file.name;
                          selectedFileSize = file.size;
                          // Auto-fill title with file name (without extension)
                          if (titleController.text.isEmpty) {
                            final nameNoExt = file.name.contains('.')
                                ? file.name.substring(0, file.name.lastIndexOf('.'))
                                : file.name;
                            titleController.text = nameNoExt;
                          }
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: selectedFileBytes != null
                            ? AppColors.success.withValues(alpha: 0.08)
                            : AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedFileBytes != null
                              ? AppColors.success
                              : context.colors.border,
                          width: selectedFileBytes != null ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            selectedFileBytes != null
                                ? Icons.check_circle_rounded
                                : Icons.cloud_upload_outlined,
                            size: 40,
                            color: selectedFileBytes != null
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedFileName ?? context.l.tapToSelectFile,
                            style: TextStyle(
                              fontWeight: selectedFileBytes != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: selectedFileBytes != null
                                  ? AppColors.success
                                  : context.colors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (selectedFileSize != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _formatSize(selectedFileSize!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.textTertiary,
                                ),
                              ),
                            ),
                          if (selectedFileBytes == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                context.l.maxFileSize,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.textTertiary,
                                ),
                              ),
                            ),
                          if (selectedFileBytes != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextButton.icon(
                                onPressed: () async {
                                  final result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                      'pdf', 'doc', 'docx', 'xls', 'xlsx',
                                      'jpg', 'jpeg', 'png', 'gif', 'txt', 'csv',
                                    ],
                                    withData: true,
                                  );
                                  if (result != null && result.files.single.bytes != null) {
                                    final file = result.files.single;
                                    if (file.size > 10 * 1024 * 1024) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(context.l.fileTooLarge)),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      selectedFileBytes = file.bytes;
                                      selectedFileName = file.name;
                                      selectedFileSize = file.size;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.swap_horiz, size: 18),
                                label: Text(context.l.changeFile),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // --- Title ---
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: context.l.title,
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // --- Category ---
                  DropdownButtonFormField<String>(
                    initialValue: selectedUploadCategory,
                    decoration: InputDecoration(
                      labelText: context.l.category,
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: [
                      DropdownMenuItem(value: 'acta', child: Text(context.l.catMinutes)),
                      DropdownMenuItem(value: 'norma', child: Text(context.l.catRegulations)),
                      DropdownMenuItem(value: 'documento', child: Text(context.l.catDocuments)),
                    ],
                    onChanged: (value) {
                      setState(() => selectedUploadCategory = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  // --- Description ---
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: context.l.descriptionOptional,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.l.cancel),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (selectedFileBytes == null || titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l.completeTitleFile)),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);

                  final success = await ref.read(documentControllerProvider.notifier).uploadFile(
                        fileBytes: selectedFileBytes!,
                        fileName: selectedFileName!,
                        title: titleController.text,
                        description: descriptionController.text.isNotEmpty
                            ? descriptionController.text
                            : null,
                        category: selectedUploadCategory,
                      );

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? context.l.uploadSuccess : context.l.uploadError,
                      ),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: context.colors.onGradient,
                  backgroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: Text(context.l.upload),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _DocumentCard extends ConsumerWidget {
  final dynamic document;
  final bool canDelete;
  final VoidCallback onDelete;
  final bool canApprove;
  final void Function(bool approved, String? reason)? onApprove;

  const _DocumentCard({
    required this.document,
    required this.canDelete,
    required this.onDelete,
    this.canApprove = false,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconData = _getFileIcon(document.fileType);
    final iconColor = _getFileColor(document.fileType);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: iconColor,
            width: 4,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDocument(ref),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        iconData,
                        color: iconColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  document.fileExtension,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: iconColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (document.fileSize != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  document.fileSizeFormatted,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                              if (document.category != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    document.category!.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_outlined),
                      color: AppColors.primary,
                      tooltip: context.l.downloadDocument,
                      onPressed: () => _openDocument(ref),
                    ),
                    if (canDelete)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: context.colors.error),
                        tooltip: context.l.deleteDocument,
                        onPressed: onDelete,
                      ),
                  ],
                ),
                if (document.approvalStatus != null) ...[                  
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildApprovalBadge(context),
                      const Spacer(),
                      if (canApprove && document.isPendingApproval) ...[
                        TextButton.icon(
                          onPressed: () => onApprove?.call(true, null),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: Text(context.l.approveDocument),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton.icon(
                          onPressed: () => _showRejectDialog(context),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: Text(context.l.rejectDocument),
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (document.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    document.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        document.uploadedByName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.onGradient,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      document.uploadedByName,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeago.format(document.createdAt, locale: 'es'),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalBadge(BuildContext context) {
    final Color badgeColor;
    final String badgeText;
    final IconData badgeIcon;

    if (document.isApproved) {
      badgeColor = AppColors.success;
      badgeText = context.l.approved;
      badgeIcon = Icons.check_circle;
    } else if (document.isRejected) {
      badgeColor = AppColors.error;
      badgeText = context.l.rejected;
      badgeIcon = Icons.cancel;
    } else {
      badgeColor = AppColors.warning;
      badgeText = context.l.pendingApproval;
      badgeIcon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l.rejectDocument),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: context.l.rejectionReason,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final reason = reasonController.text.trim();
              onApprove?.call(false, reason.isNotEmpty ? reason : null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onGradient,
            ),
            child: Text(context.l.rejectDocument),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _openDocument(WidgetRef ref) async {
    final authDataSource = ref.read(authRemoteDataSourceProvider);
    final token = authDataSource.accessToken ?? '';
    final path = document.fileUrl.startsWith('/')
        ? document.fileUrl
        : '/${document.fileUrl}';
    final fullUrl = '${EnvConfig.apiBaseUrl}$path?token=$token';
    final url = Uri.parse(fullUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Color _getFileColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'doc':
      case 'docx':
        return const Color(0xFF3B82F6);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF10B981);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

