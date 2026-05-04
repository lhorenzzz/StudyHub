import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Make sure this import path matches your actual folder name (bloc or BLoC)
import 'package:study_hub/features/auth/BLoC/auth_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Controllers hold the text typed in each input field
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Controls whether password fields show dots or plain text
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Always dispose controllers to free memory when widget is removed
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width for responsive layout decisions
    final screenWidth = MediaQuery.of(context).size.width;

    // Breakpoints:
    // > 1100px  = large desktop (split layout with big text)
    // > 700px   = small desktop / tablet (split layout, compact)
    // <= 700px  = mobile (single column)
    final isLargeDesktop = screenWidth > 1100;
    final isDesktop = screenWidth > 700;

    return BlocProvider(
      // Create and provide the AuthBloc to all widgets below this tree
      create: (_) => AuthBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: BlocListener<AuthBloc, AuthState>(
          // BlocListener reacts to state changes without rebuilding the UI
          listener: (context, state) {
            if (state is AuthFailure) {
              // Show error message at the bottom
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.white,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  content: Text(
                    state.error,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
            }
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.white,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  content: Text(
                    state.message,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              );
              // TODO: Navigate to Dashboard
              context.go('/dashboard');
            }
          },
          // Show different layouts based on screen size
          child: isDesktop
              ? _buildDesktopLayout(isLargeDesktop)
              : _buildMobileLayout(),
        ),
      ),
    );
  }

  // ─── DESKTOP LAYOUT ──────────────────────────────────────────────────────
  // Split screen: left = branding, right = form
  Widget _buildDesktopLayout(bool isLarge) {
    return Row(
      children: [
        // Left panel — only show on large desktop
        if (isLarge)
          Expanded(
            child: Container(
              color: const Color(0xFF0D0D0D),
              padding: const EdgeInsets.all(48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(),
                  const Spacer(),
                  // Hero text
                  const Text(
                    'Your study,\nyour space.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Upload, organize, and access your\nacademic resources anytime.',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '© 2025 StudyHub',
                    style: TextStyle(color: Color(0xFF333333), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

        // Right panel — always visible on desktop
        Container(
          // Wider form panel on small desktop (no left panel), fixed width on large
          width: isLarge ? 480 : 420,
          color: const Color(0xFF111111),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLarge ? 48 : 36,
                vertical: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show logo inside form panel on small desktop
                  if (!isLarge) ...[_buildLogo(), const SizedBox(height: 40)],
                  _buildForm(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── MOBILE LAYOUT ───────────────────────────────────────────────────────
  // Single column, scrollable
  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildLogo(), const SizedBox(height: 40), _buildForm()],
        ),
      ),
    );
  }

  // ─── LOGO ─────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.book_rounded, color: Colors.black, size: 18),
        ),
        const SizedBox(width: 10),
        const Text(
          'StudyHub',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // ─── FORM ─────────────────────────────────────────────────────────────────
  // BlocBuilder rebuilds this widget every time AuthState changes
  Widget _buildForm() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Determine which form to show based on current state
        final isLogin = state is AuthInitial ? state.isLogin : true;
        // Disable button and show spinner when loading
        final isLoading = state is AuthLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form title
            Text(
              isLogin ? 'Welcome back.' : 'Create account.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isLogin
                  ? 'Sign in to continue to your hub.'
                  : 'Join StudyHub and start organizing.',
              style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
            ),
            const SizedBox(height: 40),

            // ── Name field — only shown on Register form ──
            if (!isLogin) ...[
              _buildLabel('Full Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameCtrl,
                hint: 'Juan Dela Cruz',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
            ],

            // ── Email ──
            _buildLabel('Email'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailCtrl,
              hint: 'you@email.com',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // ── Password ──
            _buildLabel('Password'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _passwordCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscure: _obscurePassword,
              // Toggle visibility of password text
              toggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),

            // ── Confirm Password — only shown on Register form ──
            if (!isLogin) ...[
              const SizedBox(height: 20),
              _buildLabel('Confirm Password'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _confirmCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                toggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ],

            // ── Forgot password — only on Login form ──
            if (isLogin) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: MouseRegion(
                  // Show pointer cursor on hover (web/desktop)
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: implement forgot password
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Submit Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: MouseRegion(
                // Show pointer cursor on hover
                cursor: isLoading
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.click,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null // Disable button while loading
                      : () {
                          if (isLogin) {
                            // Dispatch login event to the BLoC
                            context.read<AuthBloc>().add(
                              LoginSubmitted(
                                email: _emailCtrl.text.trim(),
                                password: _passwordCtrl.text,
                              ),
                            );
                          } else {
                            // Dispatch register event to the BLoC
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
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFF333333),
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
                            color: Color(0xFF666666),
                          ),
                        )
                      : Text(
                          isLogin ? 'Sign In' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Toggle between Login and Register ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin
                      ? "Don't have an account? "
                      : 'Already have an account? ',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
                MouseRegion(
                  // Pointer cursor on the clickable text
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    // Dispatch toggle event — switches Login ↔ Register
                    onTap: () => context.read<AuthBloc>().add(AuthToggleForm()),
                    child: Text(
                      isLogin ? 'Sign up' : 'Sign in',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
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
  // Small grey label above each input field
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF999999),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  // ─── TEXT FIELD ───────────────────────────────────────────────────────────
  // Reusable input field — used for email, password, name, etc.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false, // true = show dots (for passwords)
    VoidCallback? toggleObscure, // callback to toggle password visibility
    TextInputType? keyboardType, // e.g. email keyboard on mobile
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF444444), fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF555555), size: 20),
        // Show eye icon only on password fields
        suffixIcon: toggleObscure != null
            ? MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: toggleObscure,
                  child: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF555555),
                    size: 20,
                  ),
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        // Default border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        // Border when not focused
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        // Border when focused/active
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF555555)),
        ),
      ),
    );
  }
}
