import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:study_hub/features/auth/BLoC/auth_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Brand palette ──────────────────────────────────────────────────────
  static const _bgDeep = Color(0xFF08041A);
  static const _bgLeft = Color(0xFF0D0829);
  static const _bgPanel = Color(0xFF0A051F);
  static const _bgCard = Color(0xFF130B2E);
  static const _border = Color(0xFF2A1A55);
  static const _violet = Color(0xFF7C3AED);
  static const _violet2 = Color(0xFF9F5FFF);
  static const _pink = Color(0xFFEC4899);
  static const _textSub = Color(0xFF8B72B8);
  static const _glow = Color(0xFFC084FC);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isLarge = w > 1100;
    final isDesktop = w > 700;

    return BlocProvider(
      create: (_) => AuthBloc(),
      child: Scaffold(
        backgroundColor: _bgDeep,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF2A1A55),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  content: Text(
                    state.error,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _violet,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  content: Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
              if (state.role == 'admin') {
                context.go('/admin');
              } else {
                context.go('/dashboard');
              }
            }
          },
          child: isDesktop
              ? _buildDesktopLayout(isLarge)
              : _buildMobileLayout(),
        ),
      ),
    );
  }

  // ─── DESKTOP ──────────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(bool isLarge) {
    return Row(
      children: [
        // ── Left hero panel ──
        if (isLarge)
          Expanded(
            child: Container(
              color: _bgLeft,
              child: Stack(
                children: [
                  // Violet orb top-left
                  Positioned(
                    top: -100,
                    left: -60,
                    child: _glowOrb(280, _violet.withOpacity(0.22)),
                  ),
                  // Pink orb bottom-right
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: _glowOrb(200, _pink.withOpacity(0.12)),
                  ),
                  // Dot grid
                  Positioned.fill(
                    child: CustomPaint(painter: _DotGridPainter()),
                  ),
                  // Lamp warm glow (cone of light on desk)
                  Positioned(
                    right: 30,
                    bottom: 60,
                    child: _glowOrb(
                      280,
                      const Color(0xFFFDE68A).withOpacity(0.10),
                    ),
                  ),
                  // Lamp scene — right side
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: LayoutBuilder(
                      builder: (_, c) {
                        final side = c.maxHeight;
                        return SizedBox(
                          width: side * 0.8,
                          height: side,
                          child: CustomPaint(painter: _LampScenePainter()),
                        );
                      },
                    ),
                  ),
                  // Text content — left side
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(48, 48, 0, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLogo(),
                          const SizedBox(height: 56),
                          ShaderMask(
                            shaderCallback: (b) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFC084FC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(b),
                            child: const Text(
                              'Your study,\nyour space.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 46,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Upload, organize, and access your\nacademic resources anytime.',
                            style: TextStyle(
                              color: _textSub,
                              fontSize: 15,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 36),
                          // Feature items — matching reference layout
                          Wrap(
                            spacing: 20,
                            runSpacing: 16,
                            children: const [
                              _FeatureItem(
                                icon: Icons.auto_awesome_rounded,
                                title: 'Organize',
                                subtitle: 'Keep everything\nin one place',
                              ),
                              _FeatureItem(
                                icon: Icons.crop_square_rounded,
                                title: 'Access',
                                subtitle: 'Anywhere,\nanytime',
                              ),
                              _FeatureItem(
                                icon: Icons.location_on_outlined,
                                title: 'Achieve',
                                subtitle: 'Focus more,\nachieve more',
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '© ${DateTime.now().year} StudyHub',
                            style: const TextStyle(
                              color: Color(0xFF2A1A55),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Right form panel ──
        Container(
          width: isLarge ? 460 : 400,
          decoration: BoxDecoration(
            color: _bgPanel,
            border: Border(left: BorderSide(color: _border.withOpacity(0.5))),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLarge ? 48 : 36,
                vertical: 48,
              ),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isLarge) ...[
                        _buildLogo(),
                        const SizedBox(height: 40),
                      ],
                      _buildForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── MOBILE ───────────────────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D0829), Color(0xFF08041A)],
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -60,
          child: _glowOrb(220, _violet.withOpacity(0.2)),
        ),
        Positioned(
          bottom: 0,
          right: -40,
          child: _glowOrb(180, _pink.withOpacity(0.12)),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 40),
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── LOGO ─────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_violet, _violet2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _violet.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.book_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        const Text(
          'StudyHub',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // ─── FORM ─────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLogin = state is AuthInitial ? state.isLogin : true;
        final isLoading = state is AuthLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLogin ? 'Welcome back.' : 'Create account.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isLogin
                  ? 'Sign in to continue to your hub.'
                  : 'Join StudyHub and start organizing.',
              style: const TextStyle(color: _textSub, fontSize: 14),
            ),
            const SizedBox(height: 36),

            if (!isLogin) ...[
              _buildLabel('Full Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameCtrl,
                hint: 'Juan Dela Cruz',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 18),
            ],

            _buildLabel('Email'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailCtrl,
              hint: 'you@email.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),

            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscure: _obscurePassword,
              toggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),

            if (!isLogin) ...[
              const SizedBox(height: 18),
              _buildLabel('Confirm Password'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _confirmCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscure: _obscureConfirm,
                toggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ],

            if (isLogin) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: _glow,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // ── Submit button ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: MouseRegion(
                cursor: isLoading
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.click,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: isLoading
                        ? null
                        : const LinearGradient(
                            colors: [_violet, _pink],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    color: isLoading ? _border : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isLoading
                        ? null
                        : [
                            BoxShadow(
                              color: _violet.withOpacity(0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (isLogin) {
                              context.read<AuthBloc>().add(
                                LoginSubmitted(
                                  email: _emailCtrl.text.trim(),
                                  password: _passwordCtrl.text,
                                ),
                              );
                            } else {
                              context.read<AuthBloc>().add(
                                RegisterSubmitted(
                                  name: _nameCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  password: _passwordCtrl.text,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          )
                        : Text(
                            isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin
                      ? "Don't have an account? "
                      : 'Already have an account? ',
                  style: const TextStyle(color: _textSub, fontSize: 14),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.read<AuthBloc>().add(AuthToggleForm()),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: _glow,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ─── LABEL ────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF9B7DC4),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }

  // ─── TEXT FIELD ───────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: _glow,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF3D2560), fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF5B3D8A), size: 20),
        suffixIcon: toggleObscure != null
            ? MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: toggleObscure,
                  child: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF5B3D8A),
                    size: 20,
                  ),
                ),
              )
            : null,
        filled: true,
        fillColor: _bgCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _violet2, width: 1.5),
        ),
      ),
    );
  }

  Widget _glowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

// ─── FEATURE ITEM ─────────────────────────────────────────────────────────
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1E0A3C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF3D1D78), width: 0.8),
          ),
          child: Icon(icon, color: const Color(0xFF9F5FFF), size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF7B5FA0),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── LAMP SCENE PAINTER ───────────────────────────────────────────────────
// Paints the desk lamp (right-side), stacked books, and mug
// matching the reference image layout.
class _LampScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Table surface ──────────────────────────────────────────────────────
    final tableY = h * 0.74;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.02, tableY, w * 0.96, h * 0.07),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF160930),
    );

    // ── Warm cone of light on table ────────────────────────────────────────
    final coneShader = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.35, 0.0),
        radius: 0.75,
        colors: [
          const Color(0xFFFDE68A).withOpacity(0.22),
          const Color(0xFFF59E0B).withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), coneShader);

    // ── BOOK STACK (center-right, under lamp) ──────────────────────────────
    final bkW = [w * 0.40, w * 0.34, w * 0.27];
    final bkH = [h * 0.055, h * 0.047, h * 0.040];
    final bkC = [
      const Color(0xFF2D1B69),
      const Color(0xFF3D2280),
      const Color(0xFF4C2B8F),
    ];
    final bkLeft = w * 0.30;
    double bkY = tableY - bkH[0];

    for (int i = 0; i < 3; i++) {
      final bx = bkLeft + (bkW[0] - bkW[i]) / 2;
      // book body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, bkY, bkW[i], bkH[i]),
          const Radius.circular(3),
        ),
        Paint()..color = bkC[i],
      );
      // left spine shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, bkY, 4, bkH[i]),
          const Radius.circular(2),
        ),
        Paint()..color = Colors.black.withOpacity(0.28),
      );
      // right page edge
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx + bkW[i] - 5, bkY + 2, 4, bkH[i] - 4),
          const Radius.circular(1),
        ),
        Paint()..color = Colors.white.withOpacity(0.07),
      );
      // warm glow on top book surface
      if (i == 2) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx, bkY, bkW[i], bkH[i] * 0.45),
            const Radius.circular(3),
          ),
          Paint()..color = const Color(0xFFFDE68A).withOpacity(0.18),
        );
      }
      if (i < 2) bkY -= bkH[i + 1];
    }

    // ── MUG (left of books) ────────────────────────────────────────────────
    final mgX = w * 0.06;
    final mgY = tableY - h * 0.13;
    final mgW = w * 0.15;
    final mgH = h * 0.13;

    // body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(mgX, mgY, mgW, mgH),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF1A0A35),
    );
    // rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(mgX - 1, mgY - 4, mgW + 2, 7),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF2D1B55),
    );
    // handle
    final handle = Path()
      ..moveTo(mgX + mgW, mgY + mgH * 0.22)
      ..cubicTo(
        mgX + mgW + w * 0.08,
        mgY + mgH * 0.22,
        mgX + mgW + w * 0.08,
        mgY + mgH * 0.78,
        mgX + mgW,
        mgY + mgH * 0.78,
      );
    canvas.drawPath(
      handle,
      Paint()
        ..color = const Color(0xFF2D1B55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round,
    );
    // steam
    final steamP = Paint()
      ..color = const Color(0xFFA855F7).withOpacity(0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int s = 0; s < 2; s++) {
      final sx = mgX + mgW * (0.28 + s * 0.42);
      final sp = Path()
        ..moveTo(sx, mgY - 5)
        ..cubicTo(sx + 4, mgY - 13, sx - 4, mgY - 21, sx, mgY - 30);
      canvas.drawPath(sp, steamP);
    }

    // ── LAMP ──────────────────────────────────────────────────────────────
    // Lamp is positioned in the upper-right of the scene
    final lampBX = w * 0.68; // base center X

    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lampBX - w * 0.07, tableY - 6, w * 0.14, 9),
        const Radius.circular(4),
      ),
      Paint()
        ..shader =
            LinearGradient(
              colors: [const Color(0xFF3D1D78), const Color(0xFF2A1055)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromLTWH(lampBX - w * 0.07, tableY - 6, w * 0.14, 9),
            ),
    );

    // Vertical pole
    final poleTop = h * 0.38;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lampBX - 4, poleTop, 8, tableY - 6 - poleTop),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF5B2FBF),
    );

    // Arm curving to shade (upper-left direction)
    final shadeCX = lampBX - w * 0.28;
    final shadeCY = poleTop - h * 0.04;
    final arm = Path()
      ..moveTo(lampBX, poleTop)
      ..cubicTo(
        lampBX,
        poleTop - h * 0.10,
        shadeCX + w * 0.05,
        poleTop - h * 0.14,
        shadeCX,
        shadeCY,
      );
    canvas.drawPath(
      arm,
      Paint()
        ..color = const Color(0xFF6D28D9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );

    // Shade trapezoid (pointing left/down like ref image)
    final shadePath = Path()
      ..moveTo(shadeCX - w * 0.18, shadeCY + h * 0.06) // bottom-left
      ..lineTo(shadeCX - w * 0.07, shadeCY - h * 0.09) // top-left
      ..lineTo(shadeCX + w * 0.07, shadeCY - h * 0.09) // top-right
      ..lineTo(shadeCX + w * 0.17, shadeCY + h * 0.06) // bottom-right
      ..close();
    canvas.drawPath(
      shadePath,
      Paint()
        ..shader =
            LinearGradient(
              colors: [const Color(0xFF4C1D95), const Color(0xFF3B0F7A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(
              Rect.fromLTWH(
                shadeCX - w * 0.18,
                shadeCY - h * 0.09,
                w * 0.35,
                h * 0.15,
              ),
            ),
    );
    // shade bottom rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(shadeCX - w * 0.185, shadeCY + h * 0.05, w * 0.37, 6),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF6D28D9),
    );
    // shade top rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(shadeCX - w * 0.075, shadeCY - h * 0.095, w * 0.15, 5),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF7C3AED),
    );

    // ── Bulb + glow ────────────────────────────────────────────────────────
    final bulbX = shadeCX + w * 0.01;
    final bulbY = shadeCY - h * 0.01;

    // large soft halo
    canvas.drawCircle(
      Offset(bulbX, bulbY),
      w * 0.10,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                const Color(0xFFFDE68A).withOpacity(0.45),
                const Color(0xFFF59E0B).withOpacity(0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.45, 1.0],
            ).createShader(
              Rect.fromCircle(center: Offset(bulbX, bulbY), radius: w * 0.10),
            ),
    );
    // bright core
    canvas.drawCircle(
      Offset(bulbX, bulbY),
      w * 0.025,
      Paint()..color = const Color(0xFFFFFBEB),
    );

    // light rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFDE68A).withOpacity(0.10)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final rays = [
      Offset(bulbX - w * 0.20, tableY),
      Offset(bulbX - w * 0.05, tableY),
      Offset(bulbX + w * 0.10, tableY),
      Offset(bulbX - w * 0.28, shadeCY + h * 0.15),
    ];
    for (final r in rays) {
      canvas.drawLine(Offset(bulbX, bulbY), r, rayPaint);
    }
  }

  @override
  bool shouldRepaint(_LampScenePainter _) => false;
}

// ─── DOT GRID PAINTER ─────────────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF3D1D78).withOpacity(0.18);
    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}
