import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/auth/presentation/login_page.dart';
import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String fullName;
  final String email;
  final VoidCallback? onLogout;

  const ProfilePage({
    super.key,
    required this.fullName,
    required this.email,
    this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _subdomain;

  @override
  void initState() {
    super.initState();
    UserStorage.getSubdomain().then((v) {
      if (mounted) setState(() => _subdomain = v);
    });
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatId(int id) => id.toString().padLeft(6, '0');

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff8c3000), Color(0xfff08024)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            title: const Text('Mon Profil',
                style: TextStyle(fontWeight: FontWeight.bold)),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Carte membre ─────────────────────────────────────────────
            _MemberCard(
              name: widget.fullName,
              phone: widget.email,
              tenant: _subdomain ?? '—',
              user: user,
              initials: _initials(widget.fullName),
              formatDate: _formatDate,
              formatId: _formatId,
            ),

            const SizedBox(height: 24),

            // ── Infos détaillées ─────────────────────────────────────────
            _InfoCard(user: user, phone: widget.email),

            const SizedBox(height: 24),

            // ── Déconnexion ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  if (widget.onLogout != null) {
                    widget.onLogout!();
                    return;
                  }
                  await UserStorage.clear();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                label: const Text('Se déconnecter',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Carte membre physique ─────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final String name;
  final String phone;
  final String tenant;
  final User? user;
  final String initials;
  final String Function(DateTime) formatDate;
  final String Function(int) formatId;

  const _MemberCard({
    required this.name,
    required this.phone,
    required this.tenant,
    required this.user,
    required this.initials,
    required this.formatDate,
    required this.formatId,
  });

  @override
  Widget build(BuildContext context) {
    final cardW = MediaQuery.of(context).size.width - 40;

    return Container(
      width: cardW,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xfff08024).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xff7a2600), Color(0xfff08024), Color(0xfffbb870)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            top: -30,
            right: -30,
            child: _circle(130, Colors.white.withOpacity(0.06)),
          ),
          Positioned(
            bottom: -40,
            left: cardW * 0.35,
            child: _circle(160, Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: _circle(50, Colors.white.withOpacity(0.08)),
          ),

          // Contenu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Ligne 1 : avatar + nom + tenant ──────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar photo (placeholder initiales)
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tenant.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Logo app petit
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: SvgPicture.asset(
                        'assets/img/dental_icon.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ── Ligne 2 : numéro membre ───────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'N° MEMBRE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          user != null ? formatId(user!.userId) : '------',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TÉLÉPHONE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          phone.isNotEmpty ? phone : '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ── Ligne 3 : rôle + date ─────────────────────────────
                Row(
                  children: [
                    Text(
                      user?.role.name.toUpperCase() ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      user != null
                          ? 'Membre depuis ${formatDate(user!.dateInscription)}'
                          : '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ── Bloc infos détaillées ────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final User? user;
  final String phone;

  const _InfoCard({required this.user, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _tile(
            icon: Icons.person_outline_rounded,
            label: 'Nom complet',
            value: user?.username ?? '—',
          ),
          _divider(),
          _tile(
            icon: Icons.phone_android_outlined,
            label: 'Téléphone',
            value: phone.isNotEmpty ? phone : '—',
          ),
          _divider(),
          _tile(
            icon: Icons.location_on_outlined,
            label: 'Adresse',
            value: '—',
          ),
          _divider(),
          _tile(
            icon: Icons.shield_outlined,
            label: 'Rôle',
            value: user?.role.name ?? '—',
            valueColor: const Color(0xfff08024),
            bold: true,
          ),
          _divider(),
          _tile(
            icon: Icons.calendar_today_outlined,
            label: 'Membre depuis',
            value: user != null
                ? _fmt(user!.dateInscription)
                : '—',
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xfff08024).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xfff08024), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          bold ? FontWeight.bold : FontWeight.w500,
                      color: valueColor ?? const Color(0xff1a1a1a),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1, thickness: 1, indent: 66, color: Colors.grey.shade100);

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
