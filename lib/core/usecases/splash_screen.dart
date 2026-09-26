import 'package:dental_app/core/features/auth/presentation/login_page.dart';
import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/usecases/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animations ──────────────────────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  bool _showSecondPage = false;
  late final Future<bool> _autoLoginFuture;

  @override
  void initState() {
    super.initState();

    // Stage 1 : logo fade + élastique
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn),
    );
    _logoScale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );

    // Stage 2 : texte slide + fade
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );
    _textSlide = Tween(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    // Lance l'auto-login EN PARALLÈLE des animations
    _autoLoginFuture =
        Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Retire le splash natif OS dès que Flutter est prêt
    FlutterNativeSplash.remove();

    // ── Page 1 : logo ────────────────────────────────────────────────────────
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));

    // ── Page 2 : texte + tagline ─────────────────────────────────────────────
    if (!mounted) return;
    setState(() => _showSecondPage = true);
    await _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));

    // Attend que l'auto-login soit terminé (si pas encore fait)
    final isLoggedIn = await _autoLoginFuture;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            isLoggedIn ? const MainScreen() : const LoginPage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeIn,
        child: _showSecondPage ? _buildPage2() : _buildPage1(),
      ),
    );
  }

  // ── Page 1 : logo centré sur fond teal ───────────────────────────────────────

  Widget _buildPage1() {
    return Container(
      key: const ValueKey('p1'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff083d4a), Color(0xff0b5260), Color(0xff137a8f)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            top: -80,
            right: -80,
            child: _circle(260, Colors.white.withOpacity(0.04)),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _circle(200, Colors.white.withOpacity(0.04)),
          ),

          Center(
            child: FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        'assets/img/dental_icon.svg',
                        height: 100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Page 2 : logo + nom + tagline + loader ───────────────────────────────────

  Widget _buildPage2() {
    return Container(
      key: const ValueKey('p2'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff052e38), Color(0xff0b5260), Color(0xff137a8f)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Déco cercles
          Positioned(
            top: -60,
            left: -60,
            child: _circle(220, Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _circle(300, Colors.white.withOpacity(0.05)),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo (déjà visible depuis la transition)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/img/dental_icon.svg',
                    height: 80,
                  ),
                ),

                const SizedBox(height: 32),

                // Nom + tagline animés
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        const Text(
                          'DÉNTAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gestion de votre association',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 72),

                // Loader discret
                FadeTransition(
                  opacity: _textFade,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                          Colors.white.withOpacity(0.5)),
                    ),
                  ),
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
