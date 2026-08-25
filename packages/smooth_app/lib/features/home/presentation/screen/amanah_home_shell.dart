import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_bottom_navigation_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_home_app_bar.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AmanahHomeShell extends StatefulWidget {
  const AmanahHomeShell({required this.user, super.key});

  final AmanahAuthUser user;

  @override
  State<AmanahHomeShell> createState() => _AmanahHomeShellState();
}

class _AmanahHomeShellState extends State<AmanahHomeShell> {
  AmanahHomeTab _selectedTab = AmanahHomeTab.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: <Widget>[
          if (_selectedTab == AmanahHomeTab.home)
            const Positioned.fill(child: _AmanahHomeAuroraBackground()),
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _AmanahPlaceholderPage(
                key: ValueKey<AmanahHomeTab>(_selectedTab),
                tab: _selectedTab,
                user: widget.user,
                onNotificationTap: () {
                  setState(() => _selectedTab = AmanahHomeTab.notifications);
                },
                onProfileTap: () {
                  setState(() => _selectedTab = AmanahHomeTab.account);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AmanahBottomNavigationBar(
        selectedTab: _selectedTab,
        onTabSelected: (AmanahHomeTab tab) {
          setState(() => _selectedTab = tab);
        },
      ),
    );
  }
}

class _AmanahPlaceholderPage extends StatelessWidget {
  const _AmanahPlaceholderPage({
    required this.tab,
    required this.user,
    required this.onNotificationTap,
    required this.onProfileTap,
    super.key,
  });

  final AmanahHomeTab tab;
  final AmanahAuthUser user;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _AmanahPageCopy copy = _copyFor(tab);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 126),
      children: <Widget>[
        if (tab == AmanahHomeTab.home)
          AmanahHomeAppBar(
            user: user,
            onNotificationTap: onNotificationTap,
            onProfileTap: onProfileTap,
          )
        else
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Amanah Healthcare',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: VERY_SMALL_SPACE),
                    Text(
                      copy.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                  ],
                ),
              ),
              _AmanahUserAvatar(user: user),
            ],
          ),
        const SizedBox(height: 28),
        Text(
          copy.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        _AmanahFeaturePlaceholder(copy: copy),
      ],
    );
  }

  _AmanahPageCopy _copyFor(AmanahHomeTab tab) {
    return switch (tab) {
      AmanahHomeTab.home => const _AmanahPageCopy(
        title: 'Home',
        description:
            'Ringkasan layanan klinik, jadwal, presensi, dan informasi harian akan ditempatkan di sini.',
        icon: Icons.home_rounded,
      ),
      AmanahHomeTab.schedule => const _AmanahPageCopy(
        title: 'Jadwal',
        description:
            'Daftar jadwal praktik, shift, dan cuti akan dibangun pada tahap berikutnya.',
        icon: Icons.calendar_today_rounded,
      ),
      AmanahHomeTab.scan => const _AmanahPageCopy(
        title: 'Presensi QR',
        description:
            'Pengalaman scan QR presensi akan disambungkan setelah struktur navigasi selesai.',
        icon: Icons.qr_code_2_rounded,
      ),
      AmanahHomeTab.notifications => const _AmanahPageCopy(
        title: 'Notifikasi',
        description:
            'Pemberitahuan layanan, jadwal, dan status permohonan akan muncul di halaman ini.',
        icon: Icons.notifications_rounded,
      ),
      AmanahHomeTab.account => const _AmanahPageCopy(
        title: 'Akun',
        description:
            'Profil pengguna, informasi kontak, dan pengaturan akun akan ditempatkan di sini.',
        icon: Icons.person_rounded,
      ),
    };
  }
}

class _AmanahHomeAuroraBackground extends StatelessWidget {
  const _AmanahHomeAuroraBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _AmanahHomeAuroraPainter()),
    );
  }
}

class _AmanahHomeAuroraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect topMask = Rect.fromLTWH(0, 0, size.width, 360);
    canvas.saveLayer(topMask, Paint());

    final Paint blueGlow = Paint()
      ..color = const Color(0xFF0A44FF).withValues(alpha: 0.90)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 78);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.30, -18),
        width: size.width * 1.28,
        height: 300,
      ),
      blueGlow,
    );

    final Paint cyanGlow = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.78)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.90, 78),
        width: size.width * 0.92,
        height: 220,
      ),
      cyanGlow,
    );

    final Paint fadePaint = Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Colors.black, Colors.black, Colors.transparent],
        stops: <double>[0, 0.42, 1],
      ).createShader(topMask);
    canvas.drawRect(topMask, fadePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AmanahHomeAuroraPainter oldDelegate) => false;
}

class _AmanahUserAvatar extends StatelessWidget {
  const _AmanahUserAvatar({required this.user});

  final AmanahAuthUser user;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String name = user.fullName.trim();
    final String initial = name.isEmpty
        ? 'A'
        : name.substring(0, 1).toUpperCase();

    return Semantics(
      label: 'Profil ${user.fullName}',
      child: CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
        child: Text(
          initial,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AmanahFeaturePlaceholder extends StatelessWidget {
  const _AmanahFeaturePlaceholder({required this.copy});

  final _AmanahPageCopy copy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.52),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(copy.icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: LARGE_SPACE),
            Text(
              'Placeholder ${copy.title}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: SMALL_SPACE),
            Text(
              'Konten halaman ini akan diisi setelah struktur navigasi final.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmanahPageCopy {
  const _AmanahPageCopy({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
