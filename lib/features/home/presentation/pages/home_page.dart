import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../providers/community_provider.dart';
import '../providers/dashboard_stats_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communityControllerProvider.notifier).loadOrganizations();
    });
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l.logout,
      message: context.l.logoutConfirm,
      confirmText: context.l.logout,
      confirmColor: AppColors.error,
      icon: Icons.logout,
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final communityState = ref.watch(communityControllerProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.colors.backgroundGradient,
        ),
        child: SafeArea(
          child: ContentConstraint(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardStatsProvider);
              },
              child: CustomScrollView(
                slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: AppColors.mediumShadow,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.goNamed('profile'),
                              borderRadius: BorderRadius.circular(18),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.textPrimary,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l.hello(
                                  (authState.user != null && authState.user!.name.isNotEmpty)
                                      ? authState.user!.name
                                      : (authState.user?.email.split('@').first ?? context.l.userFallback),
                                ),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              Text(
                                authState.user?.role.localizedName(context) ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _GlassIconButton(
                          icon: Icons.notifications_outlined,
                          onTap: () => context.goNamed('notifications'),
                          badge: ref.watch(unreadNotificationsCountProvider),
                        ),
                        const SizedBox(width: 12),
                        _GlassIconButton(
                          icon: Icons.logout,
                          onTap: () => _handleLogout(context, ref),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Selector de comunidad (si tiene más de 1)
                      if (communityState.organizations.length > 1) ...[
                        Builder(builder: (context) {
                          final orgIds = communityState.organizations.map((o) => o.id).toSet();
                          final effectiveValue = (communityState.selected != null && orgIds.contains(communityState.selected!.id))
                              ? communityState.selected!.id
                              : (communityState.organizations.isNotEmpty ? communityState.organizations.first.id : null);
                          return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: context.colors.softShadow,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.apartment, color: AppColors.primary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: effectiveValue,
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.textPrimary,
                                    ),
                                    items: communityState.organizations.map((org) {
                                      return DropdownMenuItem(
                                        value: org.id,
                                        child: Text(org.name),
                                      );
                                    }).toList(),
                                    onChanged: (id) {
                                      if (id != null) {
                                        final org = communityState.organizations
                                            .where((o) => o.id == id)
                                            .firstOrNull;
                                        if (org != null) {
                                          ref.read(communityControllerProvider.notifier)
                                              .selectOrganization(org);
                                          // Refrescar stats
                                          ref.invalidate(dashboardStatsProvider);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        }),
                        const SizedBox(height: 12),
                      ] else if (communityState.organizations.length == 1) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: context.colors.softShadow,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.apartment, color: AppColors.primary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  communityState.organizations.first.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  context.l.active,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        context.l.quickActions,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      statsAsync.when(
                        data: (stats) {
                          final actionCards = _getActionCards(context, authState, stats);
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: context.responsive.gridColumns,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: actionCards.length,
                            itemBuilder: (context, index) {
                              return actionCards[index];
                            },
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, __) {
                          final actionCards = _getActionCards(context, authState, DashboardStats.empty());
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: context.responsive.gridColumns,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: actionCards.length,
                            itemBuilder: (context, index) {
                              return actionCards[index];
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getActionCards(BuildContext context, authState, DashboardStats stats) {
    final cards = <Widget>[
      _AnimatedActionCard(
        gradient: AppColors.bookingsGradient,
        icon: Icons.calendar_month_rounded,
        label: context.l.bookings,
        count: stats.bookingsCount.toString(),
        onTap: () => context.goNamed('bookings'),
        delay: 0,
      ),
      _AnimatedActionCard(
        gradient: AppColors.incidentsGradient,
        icon: Icons.warning_amber_rounded,
        label: context.l.incidents,
        count: stats.incidentsCount.toString(),
        onTap: () => context.goNamed('incidents'),
        delay: 100,
      ),
      _AnimatedActionCard(
        gradient: AppColors.boardGradient,
        icon: Icons.dashboard_rounded,
        label: context.l.board,
        count: stats.postsCount.toString(),
        onTap: () => context.goNamed('board'),
        delay: 200,
      ),
      _AnimatedActionCard(
        gradient: AppColors.documentsGradient,
        icon: Icons.description_rounded,
        label: context.l.documents,
        count: stats.documentsCount.toString(),
        onTap: () => context.goNamed('documents'),
        delay: 300,
      ),
    ];

    // Añadir tarjeta de invitaciones para admin/presidente
    if (authState.user?.role.isAdminOrPresident == true) {
      cards.add(
        _AnimatedActionCard(
          gradient: AppColors.invitationsGradient,
          icon: Icons.mail_outline,
          label: context.l.invitations,
          count: stats.pendingInvitations.toString(),
          onTap: () => context.goNamed('invitations'),
          delay: 400,
        ),
      );
      cards.add(
        _AnimatedActionCard(
          gradient: AppColors.adminGradient,
          icon: Icons.upload_file_rounded,
          label: context.l.importData,
          count: '',
          onTap: () => context.goNamed('adminImport'),
          delay: 500,
        ),
      );
      cards.add(
        _AnimatedActionCard(
          gradient: AppColors.boardGradient,
          icon: Icons.download_rounded,
          label: context.l.exportData,
          count: '',
          onTap: () => context.goNamed('adminExport'),
          delay: 600,
        ),
      );
    }

    // Presupuesto visible para todos
    cards.add(
      _AnimatedActionCard(
        gradient: AppColors.budgetGradient,
        icon: Icons.account_balance_rounded,
        label: context.l.budget,
        count: '',
        onTap: () => context.goNamed('budget'),
        delay: 700,
      ),
    );

    return cards;
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: context.colors.softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        ),
        if (badge != null && badge! > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                badge.toString(),
                style: TextStyle(
                  color: context.colors.onGradient,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _AnimatedActionCard extends StatefulWidget {
  final Gradient gradient;
  final IconData icon;
  final String label;
  final String count;
  final VoidCallback onTap;
  final int delay;

  const _AnimatedActionCard({
    required this.gradient,
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_AnimatedActionCard> createState() => _AnimatedActionCardState();
}

class _AnimatedActionCardState extends State<_AnimatedActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * (_isPressed ? 0.95 : 1.0),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.onGradientMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.count,
                    style: TextStyle(
                      color: context.colors.onGradient,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.onGradientMuted,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        color: context.colors.onGradient,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: context.colors.onGradient,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

