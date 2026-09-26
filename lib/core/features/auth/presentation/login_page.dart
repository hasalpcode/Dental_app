import 'package:dental_app/core/features/auth/data/tenant_option_model.dart';
import 'package:dental_app/core/usecases/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;

  static const _teal = Color(0xff0b5260);
  static const _tealDark = Color(0xff083d4a);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideUp = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTenant(BuildContext ctx, AuthProvider provider) async {
    final choices = provider.tenantChoices!;
    final chosen = await showModalBottomSheet<TenantOption>(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 14),
            const Text('Choisissez votre caisse',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            for (final opt in choices)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _teal.withOpacity(0.1),
                  child:
                      const Icon(Icons.domain_outlined, color: _teal, size: 18),
                ),
                title: Text(opt.tenantName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(opt.subdomain),
                onTap: () => Navigator.pop(ctx, opt),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (chosen == null || !ctx.mounted) return;
    final ok = await provider.loginWithChosenTenant(chosen);
    if (ok && ctx.mounted) {
      Navigator.pushReplacement(
          ctx, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);
    final mq = MediaQuery.of(context);
    final h = mq.size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // ── Fond dégradé plein écran ──────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff7a2600),
                    Color(0xfff08024),
                    Color(0xfffbb870),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // ── Cercles décoratifs ────────────────────────────────────
            Positioned(
              top: -h * 0.08,
              right: -60,
              child: _deco(h * 0.42, Colors.white.withOpacity(0.07)),
            ),
            Positioned(
              top: h * 0.06,
              left: -80,
              child: _deco(h * 0.22, Colors.white.withOpacity(0.05)),
            ),
            Positioned(
              bottom: h * 0.35,
              right: -40,
              child: _deco(h * 0.15, Colors.white.withOpacity(0.06)),
            ),

            // ── Contenu ───────────────────────────────────────────────
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slideUp,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        24, h * 0.04, 24, mq.viewInsets.bottom + 24),
                    child: Column(
                      children: [
                        // ── Hero : logo ───────────────────────────────
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Anneau extérieur
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2),
                              ),
                            ),
                            // Halo doux
                            Container(
                              width: 118,
                              height: 118,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            // Logo
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/img/icone_dental.jpeg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: h * 0.025),

                        // ── Titre app ─────────────────────────────────
                        const Text(
                          'DÉNTAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 10,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Gestion de votre association',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 13,
                            letterSpacing: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        SizedBox(height: h * 0.045),

                        // ── Card formulaire ───────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // En-tête card
                              // Row(
                              //   children: [
                              //     // Container(
                              //     //   padding: const EdgeInsets.all(8),
                              //     //   decoration: BoxDecoration(
                              //     //     color: _teal.withOpacity(0.1),
                              //     //     borderRadius: BorderRadius.circular(10),
                              //     //   ),
                              //     //   child: const Icon(Icons.login_rounded,
                              //     //       color: _teal, size: 20),
                              //     // ),
                              //     const SizedBox(width: 12),
                              //     Column(
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.center,
                              //       children: [
                              //         const Text(
                              //           'Connexion',
                              //           style: TextStyle(
                              //             fontSize: 18,
                              //             fontWeight: FontWeight.bold,
                              //             color: Color(0xff1a1a1a),
                              //           ),
                              //         ),
                              //         Text(
                              //           'Accédez à votre espace',
                              //           style: TextStyle(
                              //             fontSize: 12,
                              //             color: Colors.grey.shade500,
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ],
                              // ),

                              const SizedBox(height: 5),
                              _divider(),
                              const SizedBox(height: 24),

                              // Champ téléphone
                              _inputLabel('Numéro de téléphone'),
                              const SizedBox(height: 8),
                              _field(
                                controller: _phoneCtrl,
                                hint: '7XXXXXXXX',
                                icon: Icons.phone_android_outlined,
                                keyboardType: TextInputType.number,
                                formatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(9),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // Champ mot de passe
                              _inputLabel('Mot de passe'),
                              const SizedBox(height: 8),
                              _field(
                                controller: _passCtrl,
                                hint: '• • • •',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscure,
                                keyboardType: TextInputType.number,
                                formatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),

                              // Message d'erreur
                              if (provider.error != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.red.shade400, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          provider.error!,
                                          style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Bouton connexion
                              GestureDetector(
                                onTap: provider.isLoading
                                    ? null
                                    : () async {
                                        final ok = await provider.login(
                                          _phoneCtrl.text,
                                          _passCtrl.text,
                                        );
                                        if (ok && context.mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const MainScreen()),
                                          );
                                          return;
                                        }
                                        if (context.mounted &&
                                            provider.tenantChoices != null) {
                                          await _pickTenant(context, provider);
                                        }
                                      },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 54,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: provider.isLoading
                                        ? null
                                        : const LinearGradient(
                                            colors: [_teal, _tealDark],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                    color: provider.isLoading
                                        ? _teal.withOpacity(0.5)
                                        : null,
                                    boxShadow: provider.isLoading
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: _teal.withOpacity(0.45),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                  ),
                                  child: Center(
                                    child: provider.isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Se connecter',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 18),
                                            ],
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Liens secondaires
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey.shade500,
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Mot de passe oublié ?',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  // TextButton(
                                  //   onPressed: () => Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (_) => const SignupPage()),
                                  //   ),
                                  //   style: TextButton.styleFrom(
                                  //     foregroundColor: _teal,
                                  //     padding: EdgeInsets.zero,
                                  //     tapTargetSize:
                                  //         MaterialTapTargetSize.shrinkWrap,
                                  //   ),
                                  //   child: const Text('Créer une caisse →',
                                  //       style: TextStyle(
                                  //           fontSize: 12,
                                  //           fontWeight: FontWeight.w700)),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: h * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers UI ────────────────────────────────────────────────────────────

  Widget _deco(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _divider() => Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade200)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('vos identifiants',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ),
          Expanded(child: Divider(color: Colors.grey.shade200)),
        ],
      );

  Widget _inputLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xff2a2a2a),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      inputFormatters: formatters,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xff0b5260), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xfff7f8fa),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff0b5260), width: 1.5),
        ),
      ),
    );
  }
}
